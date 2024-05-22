//
//  OpenAITranslator+Evaluation.swift
//
//
//  Created by Jonas Bromö on 2024-05-17.
//

import Foundation
import OpenAI
import Rainbow
import SwiftStringCatalog


extension OpenAITranslator: EvaluationService {

    func evaluateQuality(_ string: String, translation: String, in targetLanguage: Language, comment: String?) async throws -> EvaluationResult {
        guard string.isEmpty == translation.isEmpty else {
            return EvaluationResult(quality: .bad, explanation: "")
        }
        guard string.rangeOfCharacter(from: .letters) != nil else {
            return EvaluationResult(
                quality: string == translation ? .good : .bad,
                explanation: ""
            )
        }

        let result = try await openAI.chats(
            query: chatQuery(for: string, translation: translation, targetLanguage: targetLanguage, comment: comment)
        )

        // Extract the function call
        guard let function = result.choices.first?.message.toolCalls?.first?.function,
              function.name == evaluateQualityFunction.name else {
            throw SwiftTranslateError.unexpectedTranslationResponse
        }
        guard let data = function.arguments.data(using: .utf8) else {
            throw SwiftTranslateError.failedToParseTranslationResponse("No data")
        }

        // Parse the function response
        let response: OpenAIEvaluationResult
        do {
            response = try JSONDecoder().decode(OpenAIEvaluationResult.self, from: data)
        } catch {
            throw SwiftTranslateError.failedToParseTranslationResponse(error.localizedDescription)
        }

        let quality: TranslationQuality
        switch response.quality {
        case .good:
            quality = .good
        case .poor:
            quality = .poor
        case .bad:
            quality = .bad
        }

        return EvaluationResult(
            quality: quality,
            explanation: response.explanation
        )
    }

    // MARK: Helpers

    private func chatQuery(for source: String, translation: String, targetLanguage: Language, comment: String?) -> ChatQuery {
        let systemPrompt = """
            You are a helpful assistant designed to output JSON.
            """

        var userPrompt = """
            Evaluate the quality of the following translation by categorizing it as good, poor or bad.
            Also provide a brief explanation of how the quality was decided.

            Requirements of a good translation:
            - Be in the correct language, the language with ISO 639-1 code: \(targetLanguage.rawValue).
            - If the source text contains argument placeholders (%arg, @arg1, %lld, etc), it's important they are present in the translated text.
            - Any leading or trailing whitespace should be matched in the translation.

            Other instructions:
            - Read the source string and translated string exactly as it appears wihtin the 6 backticks (``````).
            """
        if let comment {
            userPrompt += """
                - Take into account the following context when evaluating the translation: \(comment)
                """
        }
        userPrompt += """

            Source (English): ``````\(source)``````
            Translation: ``````\(translation)``````
            """

        return ChatQuery(
            messages: [
                .system(.init(content: systemPrompt)),
                .user(.init(content: .string(userPrompt)))
            ],
            model: model,
            responseFormat: .jsonObject,
            toolChoice: .function(evaluateQualityFunction.name),
            tools: [.init(function: evaluateQualityFunction)]
        )
    }

}

private let evaluateQualityFunction = ChatQuery.ChatCompletionToolParam.FunctionDefinition(
    name: "evaluateQuality",
    description: "Evaluate the quality of the translated text.",
    parameters: .init(
        type: .object,
        properties: [
            "source": .init(
                type: .string,
                description: "The source of the translation."
            ),
            "sourceLanguageCode": .init(
                type: .string,
                description: "The ISO 639-1 language code of the source text (e.g., 'en' for English)."
            ),
            "targetLanguageCode": .init(
                type: .string,
                description: "The ISO 639-1 language code of the target language (e.g., 'sv' for Swedish)."
            ),
            "translation": .init(
                type: .string,
                description: "The translated text."
            ),
            "quality": .init(
                type: .string,
                description: "The quality of the translation: 'good', 'poor' or 'bad'.",
                enum: ["good", "poor", "bad"]
            ),
            "explanation": .init(
                type: .string,
                description: "A brief explanation of how the quality was decided."
            )
        ],
        required: ["source", "sourceLanguageCode", "targetLanguageCode", "translation", "quality"]
    )
)

private struct OpenAIEvaluationResult: Codable {
    let source: String
    let sourceLanguageCode: String
    let translation: String
    let targetLanguageCode: String
    let quality: Quality
    let explanation: String

    enum Quality: String, Codable {
        case good, poor, bad
    }
}
