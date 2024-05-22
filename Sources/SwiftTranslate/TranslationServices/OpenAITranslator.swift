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
            """

        var userPrompt =
            """
            Translate the source text within the 6 backticks (``````) into the language with ISO 639-1 code: \(targetLanguage.rawValue).

            Instructions:
            - Read the source text exactly as it appears wihtin the 6 backticks (``````).
            - Don not include the 6 backticks (``````) in the translation.
            - Provide a success or failure status indicating the translation outcome.

            Requirements:
            - Any argument placeholders (%arg, @arg1, %lld, etc) in the source must be still be present in the translation.
            - Any leading or trailing whitespace in the source must be preserved in the translation.
            """

        if let comment {
            userPrompt += """
                - Take into account the following context when translating: \(comment)
                """
        }
        userPrompt += """
            
            Source (English): ``````\(inputText)``````
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
        guard string.rangeOfCharacter(from: .letters) != nil else {
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
            throw SwiftTranslateError.failedToParseTranslationResponse((error as NSError).debugDescription)
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
    description: "Translate the source text to the specified target language.",
    parameters: .init(
        type: .object,
        properties: [
            "source": .init(
                type: .string,
                description: "The text to be translated."
            ),
            "sourceLanguageCode": .init(
                type: .string,
                description: "The ISO 639-1 language code of the source text (e.g., 'en' for English)."
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
        required: ["source", "sourceLanguageCode", "targetLanguageCode", "translation", "status"]
    )
)

private struct TranslationFunctionResponse: Codable {
    let source: String
    let sourceLanguageCode: String
    let targetLanguageCode: String
    let translation: String
    let status: Status

    enum Status: String, Codable {
        case success, failure
    }
}
