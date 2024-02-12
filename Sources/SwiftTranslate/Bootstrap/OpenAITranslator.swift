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
    
    init(with apiToken: String) {
        self.openAI = OpenAI(apiToken: apiToken)
    }
    
    // MARK: Translate
    
    func translateStringCatalog(at url: URL, to targetLanguage: Language) async throws {
        let startDate = Date()
        
        print("Loading catalog \(url.lastPathComponent)...")
        var stringCatalog = try StringCatalog.load(from: url)
        print("Done")
        
        print("\nTranslating...")
        
        for key in stringCatalog.keys {
            if (try? stringCatalog.translation(for: key, in: targetLanguage)) != nil {
                print("Skipping translated key: `\(key)`")
                continue
            }
            let sourceLanguageValue = (try? stringCatalog.sourceLanguageValue(for: key)) ?? key
            let translation = try await _translate(text: sourceLanguageValue, to: targetLanguage)
            print("Translating key to \(targetLanguage.rawValue):\t `\(key)`")
            try stringCatalog.set(translation, for: key, in: targetLanguage)
        }
        
        print("Done")
        
        let url = URL(fileURLWithPath: "TestCatalogResult.xcstrings")
        print("Writing to file \(url.path)...")
        try stringCatalog.write(to: url)
        print("Done")
        
        print("\nFinished in \(startDate.timeIntervalSinceNow * -1) seconds.")
    }
    
    func translate(text: String, to targetLanguage: Language) async throws {
        let startDate = Date()
        print("Translating...\n")
        
        let result = try await _translate(text: text, to: targetLanguage)
        print(result)
        
        print("\nFinished in \(startDate.timeIntervalSinceNow * -1) seconds.")
    }
    
    private func _translate(text: String, to targetLanguage: Language) async throws -> String {
        let result = try await openAI.completions(
            query: completionQuery(for: text, targetLanguage: targetLanguage)
        )
        guard let translatedText = result.choices.first?.text else {
            throw SwiftTranslateError.noTranslationReturned
        }
        return translatedText.trimmingCharacters(in: .whitespacesAndNewlines)
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
