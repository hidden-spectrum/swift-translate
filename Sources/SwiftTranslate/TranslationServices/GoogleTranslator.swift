//
//  Copyright © 2024 Hidden Spectrum, LLC.
//

import Foundation
import Rainbow
import SwiftStringCatalog


struct GoogleTranslator {
    
    // MARK: Private
    
    private let apiKey: String
    private let apiUrl = URL(string: "https://translation.googleapis.com/language/translate/v2")!
    
    // MARK: Lifecycle
    
    init(apiKey: String) {
        self.apiKey = apiKey
    }
    
    // MARK: Utility
    
    func buildRequest(for translatableText: String, targetLanguage: Language) throws -> URLRequest {
        var request = URLRequest(url: apiUrl)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        let body = GoogleTranslationParameters(q: translatableText, target: targetLanguage.rawValue)
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        return request
    }
}

extension GoogleTranslator: TranslationService {
    func translate(_ string: String, to targetLanguage: Language, comment: String?) async throws -> String {
        let request = try buildRequest(for: string, targetLanguage: targetLanguage)
        let (data, _) = try await URLSession.shared.data(for: request)
        return ""
    }
}


struct GoogleTranslationParameters: Encodable {
    let q: String
    let target: String
}
