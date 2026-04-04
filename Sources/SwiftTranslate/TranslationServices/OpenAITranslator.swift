//
//  Copyright © 2024-2026 Hidden Spectrum, LLC.
//

import Foundation
import OpenAI
import Rainbow
import SwiftStringCatalog


struct OpenAITranslator {
    
    // MARK: Private
    
    private let openAI: OpenAI
    private let model: OpenAIModel
    private let reasoningEffort: OpenAIReasoningEffort
    private let enableConfidenceReview: Bool
    
    // MARK: Lifecycle
    
    init(
        with apiToken: String,
        model: OpenAIModel,
        reasoningEffort: OpenAIReasoningEffort,
        enableConfidenceReview: Bool,
        timeoutInterval: Int
    ) {
        self.openAI = OpenAI(configuration: OpenAI.Configuration(token: apiToken, timeoutInterval: TimeInterval(timeoutInterval)))
        self.model = model
        self.reasoningEffort = reasoningEffort
        self.enableConfidenceReview = enableConfidenceReview
    }
    
    // MARK: Helpers
    
    private func responseQuery(for translatableText: String, targetLanguage: Language, comment: String?) -> CreateModelResponseQuery {
        let systemPrompt = SystemPrompt(
            targetLanguage: targetLanguage,
            comment: comment,
            enableConfidenceReview: enableConfidenceReview
        )
        
        return CreateModelResponseQuery(
            input: .textInput(translatableText),
            model: model.rawValue,
            instructions: systemPrompt.build(),
            reasoning: .init(effort: reasoningEffort.sdkValue, summary: nil),
            text: .jsonSchema(
                .init(
                    name: "translation",
                    schema: .derivedJsonSchema(TranslationResponse.self),
                    description: nil,
                    strict: true
                )
            )
        )
    }
    
}

extension TranslationResponse: JSONSchemaConvertible {
    public static var example: Self {
        return .init(
            "Löschen",
            inputAmbiguous: true,
            ambiguityReason: "There are multiple meanings for 'clear', including 'delete' and 'transparent'"
        )
    }
}

extension OpenAITranslator: TranslationService {
    
    // MARK: Translate
    
    func translate(_ string: String, to targetLanguage: Language, comment: String?) async throws -> TranslationResponse {
        if string.isEmpty {
            return .init("", inputAmbiguous: true, ambiguityReason: "Empty string provided")
        }
        
        let query = responseQuery(for: string, targetLanguage: targetLanguage, comment: comment)
        let response: ResponseObject
        do {
            response = try await openAI.responses.createResponse(query: query)
        } catch {
            throw SwiftTranslateError(openAIError: error) ?? error
        }
        
        for output in response.output {
            switch output {
            case .outputMessage(let message):
                return try getTranslation(from: message)
            default:
                break
            }
        }
        
        throw SwiftTranslateError.noOutputFromModel
    }
    
    private func getTranslation(from message: OutputItem.Schemas.OutputMessage) throws -> TranslationResponse {
        for content in message.content {
            switch content {
            case .OutputTextContent(let textContent):
                return try decodeOutputText(textContent.text)
            case .RefusalContent(let refusalContent):
                throw SwiftTranslateError.translationRefused(reason: refusalContent.refusal)
            }
        }
        throw SwiftTranslateError.noOutputFromModel
    }
    
    private func decodeOutputText(_ text: String) throws -> TranslationResponse {
        guard let data = text.data(using: .utf8) else {
            throw SwiftTranslateError.invalidResponseData
        }
        return try JSONDecoder().decode(TranslationResponse.self, from: data)
    }
}
