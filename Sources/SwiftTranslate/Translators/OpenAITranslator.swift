//
//  Copyright © 2024 Hidden Spectrum, LLC.
//

import Foundation
import OpenAI
import Logging
import Rainbow
import SwiftStringCatalog


struct OpenAITranslator {
    
    // MARK: Private
    
    private let openAI: OpenAI
    
    // MARK: Lifecycle
    
    init(with apiToken: String) {
        self.openAI = OpenAI(apiToken: apiToken)
    }
    
    // MARK: Helpers
    
    private func completionQuery(for translatableText: String, targetLanguage: Language) -> CompletionsQuery {
        return CompletionsQuery(
            model: "gpt-3.5-turbo-instruct",
            prompt: "Translate the following into the language with ISO code '\(targetLanguage.rawValue)': \(translatableText)",
            temperature: 0.7,
            maxTokens: 1024,
            frequencyPenalty: 0,
            presencePenalty: 0
        )
    }
}

extension OpenAITranslator: Translator {
    
    // MARK: Translate
    
    func translate(_ string: String, to targetLanguage: Language) async throws -> String {
        let result = try await openAI.completions(
            query: completionQuery(for: string, targetLanguage: targetLanguage)
        )
        guard let translatedText = result.choices.first?.text else {
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
