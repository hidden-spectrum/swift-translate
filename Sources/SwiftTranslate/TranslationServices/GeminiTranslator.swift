//
//  Copyright © 2024-2025 Hidden Spectrum, LLC.
//

import Foundation
import GoogleGenerativeAI
import SwiftStringCatalog


struct GeminiTranslator {

    // MARK: Private

    private let apiKey: String
    private let model: GeminiModel
    private let enableConfidenceReview: Bool

    // MARK: Lifecycle

    init(apiKey: String, model: GeminiModel, enableConfidenceReview: Bool) {
        self.apiKey = apiKey
        self.model = model
        self.enableConfidenceReview = enableConfidenceReview
    }

    // MARK: Helpers

    private func prompt(for translatableText: String, targetLanguage: Language, comment: String?) -> String {
        var prompt =
            """
            You are a helpful professional translator designated to translate text from English to the language with the provided BCP-47 language tag: \(targetLanguage.rawValue)

            If the input text contains argument placeholders (e.g. %arg, @arg1, %lld, %@, %d, %ld, {0}, {name}, {{name}}, ${applicationName}), they must be preserved exactly in the translated text (do not translate, remove, or reorder).

            Ensure capitalization, punctuation, and special characters (or lack thereof) are consistent with the input text.
            DO NOT translate technical terms, acronyms, brand names, or proper nouns unless they are commonly translated in the target language.

            Return only valid JSON matching this schema and nothing else:
            {
              "translation": "Translated text here",
              "inputAmbiguous": false,
              "ambiguityReason": null
            }
            """

        if let comment {
            prompt +=
                """

                Finally, take into consideration the following developer comment when translating to help disambiguate words that may have multiple meanings:
                \(comment)
                """
        }

        if enableConfidenceReview {
            prompt +=
                """

                If the input text is ambiguous or lacks sufficient context to translate accurately, set `inputAmbiguous` to true and include the reason why in `ambiguityReason` (in English).
                You should still also return the attempted translation.
                """
        } else {
            prompt +=
                """

                Always set `inputAmbiguous` to false and `ambiguityReason` to null.
                """
        }

        prompt +=
            """

            Text to translate:
            \(translatableText)
            """

        return prompt
    }

    private func decodedResponseText(from rawText: String) throws -> TranslationResponse {
        let trimmedText = rawText.trimmingCharacters(in: .whitespacesAndNewlines)
        let jsonText: String

        if trimmedText.hasPrefix("```") {
            jsonText = trimmedText
                .replacingOccurrences(of: "```json", with: "")
                .replacingOccurrences(of: "```", with: "")
                .trimmingCharacters(in: .whitespacesAndNewlines)
        } else {
            jsonText = trimmedText
        }

        guard let data = jsonText.data(using: .utf8) else {
            throw SwiftTranslateError.invalidResponseData
        }
        return try JSONDecoder().decode(TranslationResponse.self, from: data)
    }
}

extension GeminiTranslator: TranslationService {
    func translate(_ string: String, to targetLanguage: Language, comment: String?) async throws -> TranslationResponse {
        if string.isEmpty {
            return .init("", inputAmbiguous: true, ambiguityReason: "Empty string provided")
        }

        if targetLanguage == .english {
            return .init(string)
        }

        let generativeModel = GenerativeModel(
            name: model.rawValue,
            apiKey: apiKey
        )
        let response = try await generativeModel.generateContent(prompt(for: string, targetLanguage: targetLanguage, comment: comment))

        guard let responseText = response.text else {
            throw SwiftTranslateError.noTranslationReturned
        }

        return try decodedResponseText(from: responseText)
    }
}
