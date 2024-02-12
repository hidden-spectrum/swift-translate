//
//  Copyright © 2024 Hidden Spectrum, LLC.
//

import Foundation
import OpenAI


struct OpenAITranslator {
    
    // MARK: Private
    
    private let openAI: OpenAI
    
    // MARK: Lifecycle
    
    public init(apiToken: String) {
        self.openAI = OpenAI(apiToken: apiToken)
    }
    
    // MARK: Translate
    
    public func translate(text: String, targetLanguage: String) async throws {
        let result = try await openAI.completions(
            query: completionQuery(for: text)
        )
        print(result)
    }
    
    private func completionQuery(for text: String) -> CompletionsQuery {
        return CompletionsQuery(
            model: .textCurie,
            prompt: text,
            temperature: 0.7,
            maxTokens: 1024,
            frequencyPenalty: 0,
            presencePenalty: 0
        )
    }
}
