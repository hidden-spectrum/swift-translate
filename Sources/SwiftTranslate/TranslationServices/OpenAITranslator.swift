//
//  Copyright © 2024-2025 Hidden Spectrum, LLC.
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
            
            Ensure capitalization, punctuation, and special characters (or lack thereof) are consistent with the input text.
            DO NOT translate technical terms, acronyms, brand names, or proper nouns unless they are commonly translated in the target language.
            
            The translated text should be as concise as the input text while maintaining the intended meaning and context.
            """
        if let comment {
            systemPrompt +=
                """
                
                Finally, take into consideration the following developer comment when translating to help disambuigate words that may have multiple meanings:
                \(comment)
                
                """
        } else {
            systemPrompt +=
                """
                
                Finally, if the input text is too short to provide sufficient context for accurate translation, flag as such and provide a reason (in English).
                """
        }
        return systemPrompt
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
        let response = try await openAI.responses.createResponse(query: query)
        
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
