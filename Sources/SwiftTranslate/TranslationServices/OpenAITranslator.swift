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
    private let retries: Int

    // MARK: Lifecycle
    
    init(with apiToken: String, model: AIModel, retries: Int) {    
        self.openAI = OpenAI(apiToken: apiToken)
        self.model = model
        self.retries = retries
    }
    
    // MARK: Helpers
    
    private func chatQuery(for translatableText: String, targetLanguage: Language, comment: String?) -> ChatQuery {
        
        var systemPrompt =
            """
            You are a helpful professional translator designated to translate text from English to the language with ISO 639-1 code: \(targetLanguage.rawValue)
            If the input text contains argument placeholders (%arg, @arg1, %lld, etc), it's important they are preserved in the translated text.
            You should not output anything other than the translated text.
            Avoid using the same word more than once in a row.
            Avoid using the same character more than 3 times in a row.
            Trim extra spaces and the beginning and end of the translated text.
            Do not provide blank translations. Do not hallucinate. Do not provide translations that are not faithful to the original text.
            Put particular attention to languages that use different characters and symbols than English.
            """
        if let comment {
            systemPrompt += "\nTake into consideration the following context when translating, but do not completely change the translation because of it: \(comment)\n"
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

        var attempt = 0
        repeat {
            attempt += 1
            let result = try? await openAI.chats(
                query: chatQuery(for: string, targetLanguage: targetLanguage, comment: comment)
            )
            guard let result = result, let translatedText = result.choices.first?.message.content?.string, !translatedText.isEmpty else {
                continue
            }
            return translatedText
        } while attempt < retries

        throw SwiftTranslateError.noTranslationReturned
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
