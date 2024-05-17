//
//  Copyright © 2024 Hidden Spectrum, LLC.
//

import Foundation
import OpenAI
import Rainbow
import SwiftStringCatalog


struct OpenAITranslator {

    let openAI: OpenAI
    let model: Model

    // MARK: Lifecycle
    
    init(with apiToken: String, model: Model) {
        let configuration = OpenAI.Configuration(
            token: apiToken,
            timeoutInterval: 60
        )
        self.openAI = OpenAI(configuration: configuration)
        self.model = model
    }
    
    // MARK: Helpers

    private func chatQuery(for inputText: String, targetLanguage: Language, comment: String?) -> ChatQuery {
        let systemPrompt = """
            You are a helpful assistant designed to output JSON.
            Your task is to translate text.
            If the input text contains argument placeholders (%arg, @arg1, %lld, etc), it's important they are preserved in the translated text.
            """

        var userPrompt =
            """
            Translate the text between the backticks (``````) from English to the language with ISO 639-1 code: \(targetLanguage.rawValue).
            """
        if let comment {
            userPrompt += """
                Take into account the following context when translating: \(comment)
                """
        }
        userPrompt += """
            ``````
            \(inputText)
            ``````
            """

        return ChatQuery(
            messages: [
                .system(.init(content: systemPrompt)),
                .user(.init(content: .string(userPrompt)))
            ],
            model: model,
            responseFormat: .jsonObject,
            toolChoice: .function(translateFunction.name),
            tools: [.init(function: translateFunction)]
        )
    }

}

extension OpenAITranslator: TranslationService {
    
    // MARK: Translate
    
    func translate(_ string: String, to targetLanguage: Language, comment: String?) async throws -> String {
        guard !string.isEmpty else {
            return string
        }

        let result = try await openAI.chats(
            query: chatQuery(for: string, targetLanguage: targetLanguage, comment: comment)
        )

        // Extract the function call
        guard let function = result.choices.first?.message.toolCalls?.first?.function,
              function.name == translateFunction.name else {
            throw SwiftTranslateError.unexpectedTranslationResponse
        }
        guard let data = function.arguments.data(using: .utf8) else {
            throw SwiftTranslateError.failedToParseTranslationResponse("No data")
        }

        // Parse the function response
        let translationResponse: TranslationFunctionResponse
        do {
            translationResponse = try JSONDecoder().decode(
                TranslationFunctionResponse.self,
                from: data
            )
        } catch {
            throw SwiftTranslateError.failedToParseTranslationResponse(error.localizedDescription)
        }
        guard translationResponse.status == .success else {
            throw SwiftTranslateError.translationFailed
        }

        return translationResponse.translation
    }

}

// TODO: Move
extension String {
    func truncatedRemovingNewlines(to length: Int) -> String {
        let newlinesRemoved = replacingOccurrences(of: "\n", with: " ")
        guard newlinesRemoved.count > length else {
            return self
        }
        return String(newlinesRemoved.prefix(length) + "...")
    }
}

/// Sources:
/// - https://platform.openai.com/docs/api-reference/chat/create
/// - https://platform.openai.com/docs/guides/text-generation/json-mode
private let translateFunction = ChatQuery.ChatCompletionToolParam.FunctionDefinition(
    name: "translate",
    description: "Translate the input text to the specified language.",
    parameters: .init(
        type: .object,
        properties: [
            "input": .init(
                type: .string,
                description: "The text to be translated."
            ),
            "inputLanguageCode": .init(
                type: .string,
                description: "The ISO 639-1 language code of the input text (e.g., 'en' for English)."
            ),
            "targetLanguageCode": .init(
                type: .string,
                description: "The ISO 639-1 language code of the target language (e.g., 'it' for Italian)."
            ),
            "translation": .init(
                type: .string,
                description: "The translated text."
            ),
            "status": .init(
                type: .string,
                description: "The status of the translation request: 'success' if successful, 'failure' otherwise.",
                enum: ["success", "failure"]
            )
        ],
        required: ["input", "inputLanguageCode", "targetLanguageCode", "translation", "status"]
    )
)

private struct TranslationFunctionResponse: Codable {
    let input: String
    let inputLanguageCode: String
    let targetLanguageCode: String
    let translation: String
    let status: Status

    enum Status: String, Codable {
        case success, failure
    }
}
