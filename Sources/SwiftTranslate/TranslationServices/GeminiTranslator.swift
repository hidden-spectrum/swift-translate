//
//  Copyright © 2024-2026 Hidden Spectrum, LLC.
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
    
    init(
        apiKey: String,
        model: GeminiModel,
        enableConfidenceReview: Bool,
        timeoutInterval: Int
    ) {
        self.apiKey = apiKey
        self.model = model
        self.enableConfidenceReview = enableConfidenceReview
        self.timeoutInterval = TimeInterval(timeoutInterval)
    }
    
    // MARK: Helpers
    
    private func generativeModel(for targetLanguage: Language, comment: String?) -> GenerativeModel {
        let systemPrompt = SystemPrompt(
            targetLanguage: targetLanguage,
            comment: comment,
            enableConfidenceReview: enableConfidenceReview
        )
        
        return GenerativeModel(
            name: model.rawValue,
            apiKey: apiKey,
            generationConfig: .init(
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
            ),
            systemInstruction: systemPrompt.build(),
            requestOptions: RequestOptions(timeout: timeoutInterval)
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
    
    // MARK: Translate
    
    func translate(_ string: String, to targetLanguage: Language, comment: String?) async throws -> TranslationResponse {
        if string.isEmpty {
            return .init("", inputAmbiguous: true, ambiguityReason: "Empty string provided")
        }
        
        if targetLanguage == .english {
            return .init(string)
        }
        
        let generativeModel = generativeModel(for: targetLanguage, comment: comment)
        let response: GenerateContentResponse
        do {
            response = try await generativeModel.generateContent(string)
        } catch {
            throw SwiftTranslateError(geminiError: error) ?? error
        }

        guard let responseText = response.text else {
            throw SwiftTranslateError.noTranslationReturned
        }

        return try decodeResponseText(responseText)
    }
}
