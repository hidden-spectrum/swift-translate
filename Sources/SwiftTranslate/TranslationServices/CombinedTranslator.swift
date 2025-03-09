//
//  Copyright © 2024 Hidden Spectrum, LLC.
//

import Foundation
import Rainbow
import SwiftStringCatalog


struct CombinedTranslator {

    // MARK: Private

    private let googleTranslator: GoogleTranslator
    private let openAITranslator: OpenAITranslator

    // MARK: Lifecycle

    init(google: GoogleTranslator, openAI: OpenAITranslator) {
        self.googleTranslator = google
        self.openAITranslator = openAI
    }
}

extension CombinedTranslator: TranslationService {
    func translate(_ string: String, to targetLanguage: Language, comment: String?, baseTranslation: String?) async throws -> String {
        let googleTranslation = try await googleTranslator.translate(string, to: targetLanguage, comment: comment, baseTranslation: nil)
        return try await openAITranslator.translate(string, to: targetLanguage, comment: nil, baseTranslation: googleTranslation)
    }
}
