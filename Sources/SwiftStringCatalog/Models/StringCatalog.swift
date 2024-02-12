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
    
    var strings: [StringLiteralType: StringTranslations]

    // MARK: Accessors
    
    public func extractionState(for key: String) throws -> ExtractionState {
        let translations = try getTranslations(for: key)
        return translations.extractionState
    }
    
    public func localizedValue(for key: StringLiteralType, in language: Language? = nil) throws -> String {
        let language = language ?? sourceLanguage
        let translations = try getTranslations(for: key)
        
        guard let value = translations.localizations[language.rawValue]?.stringUnit.value else {
            throw Error.localizedValueNotFoundForLanguage(language)
        }
        
        return value
    }
    
    mutating func set(localizedValue: StringLiteralType, for key: StringLiteralType, in language: Language) throws {
        var translations = try getTranslations(for: key)
        var localizations = translations.localizations
        if var stringUnitContainer = localizations[language.rawValue] {
            stringUnitContainer.stringUnit.value = localizedValue
            localizations[language.rawValue] = stringUnitContainer
        } else {
            localizations[language.rawValue] = .init(stringUnit: .init(state: .translated, value: localizedValue))
        }
        translations.localizations = localizations
        strings[key] = translations
    }
    
    // MARK: Helpers
    
    private func getTranslations(for key: StringLiteralType) throws -> StringTranslations {
        guard let translations = strings[key] else {
            throw Error.localizedStringKeyNotFound(key)
        }
        return translations
    }
}
