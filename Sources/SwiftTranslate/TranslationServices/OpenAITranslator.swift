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
    
    // MARK: Lifecycle
    
    init(with apiToken: String, model: OpenAIModel = .gpt3_5TurboInstruct) {
        self.openAI = OpenAI(apiToken: apiToken)
        self.model = model
    }
    
    // MARK: Helpers
    
    private func completionQuery(for translatableText: String, targetLanguage: Language, comment: String?) -> CompletionsQuery {
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
        
        return CompletionsQuery(
            model: model.rawValue,
            prompt: prompt,
            temperature: 0.75,
            maxTokens: 2048,
            frequencyPenalty: 0,
            presencePenalty: 0
        )
    }
}

extension OpenAITranslator: TranslationService {
    
    // MARK: Translate
    
    func translate(_ string: String, to targetLanguage: Language, comment: String?) async throws -> String {
        let result = try await openAI.completions(
            query: completionQuery(for: string, targetLanguage: targetLanguage, comment: comment)
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
