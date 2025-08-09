//
//  Copyright © 2024 Hidden Spectrum, LLC.
//

import Foundation
import OpenAI
import Rainbow
import SwiftStringCatalog


struct OpenAITranslator {
    
    // MARK: Private
    
    private let openAI: OpenAI
    private let model: OpenAIModel
    private let retries: Int
    
    // MARK: Lifecycle
    
    init(with apiToken: String, model: OpenAIModel, timeoutInterval: Int, retries: Int) {
        self.openAI = OpenAI(configuration: OpenAI.Configuration(token: apiToken, timeoutInterval: TimeInterval(timeoutInterval)))
        self.model = model
        self.retries = retries
    }
    
    // MARK: Helpers
    
    private func responseQuery(for translatableText: String, targetLanguage: Language, comment: String?) -> CreateModelResponseQuery {
        let systemPrompt = systemPrompt(for: targetLanguage, comment: comment)
        
        return CreateModelResponseQuery(
            input: .textInput(translatableText),
            model: model.rawValue,
            instructions: systemPrompt,
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
    
    private func systemPrompt(for targetLanguage: Language, comment: String?) -> String {
        var systemPrompt =
            """
            You are a helpful professional translator designated to translate text from English to the language with ISO 639-1 code: \(targetLanguage.rawValue)
            If the input text contains argument placeholders (%arg, @arg1, %lld, etc), it's important they are preserved in the translated text.
            
            The translated text should be faithful to the original text, maintaining its meaning, tone, and context.
            Ensure capitalization, punctuation, and special characters are preserved in the translation.
            Put particular attention to languages that use different characters and symbols than English.
            """
        if let comment {
            systemPrompt +=
            """
            
            Take into consideration the following developer comment when translating to help disambuigate words that may have multiple meanings:
            \(comment)
            """
        }
        return systemPrompt
    }
}

extension OpenAITranslator {
    struct TranslationResponse: JSONSchemaConvertible {
        let translation: String
        let confidence: Double
        
        static var example: OpenAITranslator.TranslationResponse {
            return .init(translation: "Este texto fue traducido del inglés.", confidence: 0.95)
        }
    }
}

extension OpenAITranslator: TranslationService {
    
    // MARK: Translate
    
    func translate(_ string: String, to targetLanguage: Language, comment: String?) async throws -> String {
        guard !string.isEmpty else {
            return string
        }
        
        let query = responseQuery(for: string, targetLanguage: targetLanguage, comment: comment)
        let response = try await openAI.responses.createResponse(query: query)
        
        for output in response.output {
            switch output {
            case .outputMessage(let message):
                let translation = try getTranslation(from: message)
                print("OpenAI Translation Confidence: \(translation.confidence)".green)
                return translation.translation
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
