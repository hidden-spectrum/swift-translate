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
    private let model: AIModel
    
    // MARK: Lifecycle
    
    init(with apiToken: String, model: AIModel) {
        self.openAI = OpenAI(apiToken: apiToken)
        self.model = model
    }
    
    // MARK: Helpers
    
    private func chatQuery(for translatableText: String, targetLanguage: Language, comment: String?) -> ChatQuery {
        
        var systemPrompt =
            """
            You are a helpful assistant designed to translate the given text from English to the language with ISO 639-1 code: \(targetLanguage.rawValue)
            If the input text contains argument placeholders (%arg, @arg1, %lld, etc), it's important they are preserved in the translated text.
            You should not output anything other than the translated text.
            """
        if let comment {
            systemPrompt += "\n- IMPORTANT: Take into account the following context when translating: \(comment)\n"
        }
        
        return ChatQuery(
            messages: [
                .system(.init(content: systemPrompt)),
                .user(.init(content: .string(translatableText))),
            ],
            model: model.rawValue,
            frequencyPenalty: -2,
            presencePenalty: -2,
            responseFormat: .text
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
        guard let translatedText = result.choices.first?.message.content?.string, !translatedText.isEmpty else {
            throw SwiftTranslateError.noTranslationReturned
        }
        return translatedText
    }
}

extension String {
    func truncatedRemovingNewlines(to length: Int) -> String {
        let newlinesRemoved = replacingOccurrences(of: "\n", with: " ")
        guard newlinesRemoved.count > length else {
            return self
        }
        return String(newlinesRemoved.prefix(length) + "...")
    }
}
