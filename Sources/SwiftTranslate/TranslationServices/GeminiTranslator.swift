//
//  Copyright © 2026 Hidden Spectrum, LLC.
//

import Foundation
import GoogleGenerativeAI
import SwiftStringCatalog


struct GeminiTranslator {
    
    // MARK: Private
    
    private let apiKey: String
    private let model: GeminiModel
    private let enableConfidenceReview: Bool
    private let timeoutInterval: TimeInterval
    
    // MARK: Lifecycle
    
    init(apiKey: String, model: GeminiModel, enableConfidenceReview: Bool, timeoutInterval: Int) {
        self.apiKey = apiKey
        self.model = model
        self.enableConfidenceReview = enableConfidenceReview
        self.timeoutInterval = TimeInterval(timeoutInterval)
    }
    
    // MARK: Helpers
    
    private func prompt(for translatableText: String, targetLanguage: Language, comment: String?) -> String {
        var prompt =
            """
            You are a helpful professional translator designated to translate text from English to the language with the provided BCP-47 language tag: \(targetLanguage.rawValue)
            
            If the input text contains argument placeholders (e.g. %arg, @arg1, %lld, %@, %d, %ld, {0}, {name}, {{name}}, ${applicationName}), they must be preserved exactly in the translated text (do not translate, remove, or reorder).
            
            Ensure capitalization, punctuation, and special characters (or lack thereof) are consistent with the input text.
            DO NOT translate technical terms, acronyms, brand names, or proper nouns unless they are commonly translated in the target language.
            
            Return only JSON matching the configured response schema.
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
    
    private var generationConfig: GenerationConfig {
        GenerationConfig(
            responseMIMEType: "application/json",
            responseSchema: Schema(
                type: .object,
                properties: [
                    "translation": Schema(type: .string, nullable: false),
                    "inputAmbiguous": Schema(type: .boolean, nullable: false),
                    "ambiguityReason": Schema(type: .string, nullable: true),
                ],
                requiredProperties: ["translation", "inputAmbiguous", "ambiguityReason"]
            )
        )
    }
    
    private func decodeResponseText(_ rawText: String) throws -> TranslationResponse {
        let trimmedText = rawText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let data = trimmedText.data(using: .utf8) else {
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
            apiKey: apiKey,
            generationConfig: generationConfig,
            requestOptions: RequestOptions(timeout: timeoutInterval)
        )
        let response: GenerateContentResponse
        do {
            response = try await generativeModel.generateContent(prompt(for: string, targetLanguage: targetLanguage, comment: comment))
        } catch {
            throw SwiftTranslateError(geminiError: error) ?? error
        }

        guard let responseText = response.text else {
            throw SwiftTranslateError.noTranslationReturned
        }

        return try decodeResponseText(responseText)
    }
}
