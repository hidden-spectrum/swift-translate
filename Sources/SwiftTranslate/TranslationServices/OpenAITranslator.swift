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
    private let model: Model

    // MARK: Lifecycle
    
    init(with apiToken: String, model: Model = .gpt4) {
        let configuration = OpenAI.Configuration(
            token: apiToken,
            timeoutInterval: 60
        )
        self.openAI = OpenAI(configuration: configuration)
        self.model = model
    }
    
    // MARK: Helpers
    
    private func chatQuery(for translatableText: String, targetLanguage: Language, comment: String?) -> ChatQuery {
        var prompt =
            """
            Translate the text between the backticks (``````) from English to the language with ISO code: \(targetLanguage.rawValue)
            - DO NOT translate the prompt or any other text that is not inside the backticks (``````).
            - DO NOT INCLUDE backticks (``````) in your response!
            - DO NOT REMOVE argument placeholders from your response! (%arg, @arg1, %lld, etc)
            """
        if let comment {
            prompt += "\n- IMPORTANT: Take into account the following context when translating: \(comment)\n"
        }
        prompt += 
            """
            ``````
            \(translatableText)
            ``````
            """

        return ChatQuery(
            messages: [.user(.init(content: .string(prompt)))],
            model: model
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
        guard let translatedText = result.choices.first?.message.content?.string else {
            throw SwiftTranslateError.noTranslationReturned
        }
        return translatedText.trimmingCharacters(in: .whitespacesAndNewlines)
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
