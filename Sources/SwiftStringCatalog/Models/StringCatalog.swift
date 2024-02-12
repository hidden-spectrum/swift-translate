//
//  Copyright © 2024 Hidden Spectrum, LLC.
//

import Foundation


public struct StringCatalog: Codable {

    // MARK: Public
    
    public enum Error: Swift.Error {
        case localizedStringKeyNotFound(String)
        case localizedValueNotFoundForLanguage(Language)
    }
    
    public let sourceLanguage: Language
    public let version: String
    
    // MARK: Internal
    
    var strings: [String: StringTranslations]

    // MARK: Accessors
    
    public func localizedValue(for key: String, in language: Language) throws -> String {
        guard let stringTranslations = strings[key] else {
            throw Error.localizedStringKeyNotFound(key)
        }
        
        guard let value = stringTranslations.localizations[language.rawValue]?.stringUnit.value else {
            throw Error.localizedValueNotFoundForLanguage(language)
        }
        
        return value
    }
}
