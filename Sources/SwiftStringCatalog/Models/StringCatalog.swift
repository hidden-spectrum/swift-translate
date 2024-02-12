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
    
    // MARK: Private
    
    // MARK: Lifecycle
    
    public init(sourceLanguage: Language, version: String = "1.0") {
        self.sourceLanguage = sourceLanguage
        self.version = version
        self.strings = [:]
    }
    
    public static func load(from url: URL) throws -> StringCatalog {
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        decoder.allowsJSON5 = true
        return try decoder.decode(Self.self, from: data)
    }
    
    public func write(to url: URL) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let data = try encoder.encode(self)
        
        let fileManager = FileManager.default
        try? fileManager.removeItem(at: url)
        fileManager.createFile(atPath: url.path, contents: data)
    }
    
    // MARK: Accessors
    
    public var keys: [StringLiteralType] {
        return Array(strings.keys)
    }
    
    public func extractionState(for key: StringLiteralType) throws -> ExtractionState {
        let translations = try getTranslations(for: key)
        return translations.extractionState ?? .unknown
    }
    
    public func sourceLanguageValue(for key: StringLiteralType) throws -> StringLiteralType {
        return try translation(for: key, in: sourceLanguage)
    }
    
    public func translation(for key: StringLiteralType, in language: Language) throws -> StringLiteralType {
        let language = language
        let translations = try getTranslations(for: key)
        
        guard let value = translations.localizations[language.rawValue]?.stringUnit?.value else {
            throw Error.localizedValueNotFoundForLanguage(language)
        }
        
        return value
    }
    
    mutating public func set(_ translation: StringLiteralType, for key: StringLiteralType, in language: Language) throws {
        var translations = try getTranslations(for: key)
        var localizations = translations.localizations
        if var stringUnitContainer = localizations[language.rawValue] {
            stringUnitContainer.stringUnit?.value = translation
            stringUnitContainer.stringUnit?.state = .translated
            localizations[language.rawValue] = stringUnitContainer
        } else {
            localizations[language.rawValue] = .init(stringUnit: .init(state: .translated, value: translation))
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
