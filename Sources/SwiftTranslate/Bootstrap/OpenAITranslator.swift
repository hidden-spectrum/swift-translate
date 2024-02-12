//
//  Copyright © 2024 Hidden Spectrum, LLC.
//

import Foundation
import OpenAI
import SwiftStringCatalog


struct OpenAITranslator {
    
    // MARK: Private
    
    private let openAI: OpenAI
    
    // MARK: Lifecycle
    
    public init(with apiToken: String) {
        self.openAI = OpenAI(apiToken: apiToken)
    }
    
    // MARK: Translate
    
    public func translate(text: String, targetLanguage: Language) async throws {
        let startDate = Date()
        print("Translating...\n")
        let result = try await openAI.completions(
            query: completionQuery(for: text, targetLanguage: targetLanguage)
        )
        guard let translatedText = result.choices.first?.text else {
            throw SwiftTranslateError.noTranslationReturned
        }
        print(translatedText.trimmingCharacters(in: .whitespacesAndNewlines))
        
        print("\nFinished in \(startDate.timeIntervalSinceNow * -1) seconds.")
    }
    
    private func completionQuery(for translatableText: String, targetLanguage: Language) -> CompletionsQuery {
        return CompletionsQuery(
            model: "gpt-3.5-turbo-instruct",
            prompt: "Translate the following into \(targetLanguage.rawValue): \(translatableText)",
            temperature: 0.7,
            maxTokens: 1024,
            frequencyPenalty: 0,
            presencePenalty: 0
        )
    }
}
