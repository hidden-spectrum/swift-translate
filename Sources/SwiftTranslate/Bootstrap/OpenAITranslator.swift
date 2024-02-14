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
    
    func translateStringCatalog(at url: URL, to targetLanguages: [Language]) async throws {
        let startDate = Date()
        
        print("Loading catalog \(url.lastPathComponent)...")
        var catalog = try StringCatalog.load(from: url)
        catalog.setTargetLanguages(targetLanguages)
        print("Done")
        
        for key in catalog.allKeys {
            print("\nTranslating key `\(key.truncated(to: 64))`...")
            let localizableStrings = try catalog.localizableStrings(for: key)
            for localizableString in localizableStrings {
                let targetLangCode = localizableString.targetLanguage.rawValue
                if localizableString.state == .translated {
                    print("\t\(targetLangCode): [Already translated]")
                    continue
                }
                do {
                    let translatedString = try await _translate(
                        text: localizableString.sourceKey,
                        to: localizableString.targetLanguage
                    )
//                    string.setTranslation(translatedValue)
                    print("\t\(targetLangCode): \(translatedString.truncated(to: 64))")
                } catch {
                    print("\t\(targetLangCode): [Error: \(error.localizedDescription)]")
                }
            }
        }
        
        print("Done")
        
//        let url = URL(fileURLWithPath: "TestCatalogResult.xcstrings")
        print("TODO: Write to file")
//        print("Write to file \(url.path)...")
//        try catalog.write(to: url)
//        print("Done")
        
        print("\nFinished in \(startDate.timeIntervalSinceNow * -1) seconds.")
    }
    
    func translate(text: String, to targetLanguages: [Language]) async throws {
        let startDate = Date()
        print("Translating...\n")
        
        for targetLanguage in targetLanguages {
            let result = try await _translate(text: text, to: targetLanguage)
            print("\(targetLanguage.rawValue): \(result)")
        }
        
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

extension String {
    func truncated(to length: Int) -> String {
        guard count > length else {
            return self
        }
        return String(prefix(length) + "...")
    }
}
