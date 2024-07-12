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
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "translation.googleapis.com"
        urlComponents.path = "/language/translate/v2"
        urlComponents.queryItems = [
            URLQueryItem(name: "key", value: apiKey),
            URLQueryItem(name: "source", value: Language.english.rawValue),
            URLQueryItem(name: "q", value: translatableText),
            URLQueryItem(name: "target", value: targetLanguage.rawValue),
            URLQueryItem(name: "format", value: "text")
        ]
        guard let url = urlComponents.url else {
            throw SwiftTranslateError.couldNotCreateGoogleTranslateURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        return request
    }
}

extension GoogleTranslator: TranslationService {
    func translate(_ string: String, to targetLanguage: Language, comment: String?) async throws -> String {
        if targetLanguage == .english {
            return string
        }
        
        let request = try buildRequest(for: string, targetLanguage: targetLanguage)
        let (data, _) = try await URLSession.shared.data(for: request)
       
        guard let response = try? JSONDecoder().decode(GoogleTranslationResponse.self, from: data) else {
            throw SwiftTranslateError.couldNotDecodeTranslationResponse
        }
        guard let translation = response.data.translations.first else {
            throw SwiftTranslateError.noTranslationReturned
        }
        
        return translation.translatedText
    }
}


struct GoogleTranslationResponse: Decodable {
    let data: Data
    
    struct Data: Decodable {
        let translations: [Translation]
        
        struct Translation: Decodable {
            let translatedText: String
        }
    }
}
