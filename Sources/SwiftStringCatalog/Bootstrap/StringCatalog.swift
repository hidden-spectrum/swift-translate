//
//  Copyright © 2024 Hidden Spectrum, LLC.
//

import Foundation


public struct StringCatalog: Codable {

    // MARK: Public
    
    public enum Error: Swift.Error {
        case noEntryFor(key: String)
        case noSourceLanguageEntryFor(key: String)
        case corruptedEntry
        case substitionsNotYetSupported
    }
    
    public let sourceLanguage: Language
    public let version: String
    
    // MARK: Internal
    
    
    
    // MARK: Private
    
    private var strings: [StringLiteralType: _Entry]
    private var targetLangauges: [Language] = []
    
    // MARK: Lifecycle
    
    public init(sourceLanguage: Language, targetLanguages: [Language] = [], version: String = "1.0") {
        self.sourceLanguage = sourceLanguage
        self.strings = [:]
        self.targetLangauges = targetLanguages
        self.version = version
    }
    
    public static func load(from url: URL) throws -> StringCatalog {
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
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
    
    // MARK: Lifecycle
    
    mutating func setTargetLanguages(_ languages: [Language]) {
        targetLangauges = languages
    }
    
    // MARK: Accessors
    
    public var allKeys: Set<StringLiteralType> {
        return Set(strings.keys)
    }
    
    public func localizableStrings(for key: StringLiteralType) throws -> [LocalizableString] {
        let entry = try entry(for: key)
        let sourceLocalizableString = try sourceLocalizableStrings(in: entry, for: key)
        
        var localizableStrings = [LocalizableString]()
        
        for (language, localizations) in entry.localizations {
            
        }
        
        return []
    }
    
    // MARK: Private Accessors
    
    private func entry(for key: StringLiteralType) throws -> _Entry {
        guard let entry = strings[key] else {
            throw Error.noEntryFor(key: key)
        }
        return entry
    }
    
    private func sourceLocalizableStrings(in entry: _Entry, for key: StringLiteralType) throws -> [LocalizableString] {
        guard let localization = entry.localizations[sourceLanguage] else {
            throw Error.noSourceLanguageEntryFor(key: key)
        }
        return try localization.constructLocalizableStrings(context: .isSource, targetLanguage: sourceLanguage)
    }
    
    
    
    
//
//    public func extractionState(for key: StringLiteralType) throws -> ExtractionState {
//        let entry = try getEntry(for: key)
//        return entry.extractionState ?? .unknown
//    }
//    
//    public func sourceLanguageValue(for key: StringLiteralType) throws -> StringLiteralType {
//        return try translation(for: key, in: sourceLanguage)
//    }
//    
//    public func translation(for key: StringLiteralType, in language: Language) throws -> StringLiteralType {
//        let entry = try getEntry(for: key)
//        
//        guard let value = entry.localizations[language]?.stringUnit?.value else {
//            throw Error.localizedValueNotFoundForLanguage(language)
//        }
//        
//        return value
//    }
//    
//    mutating public func set(_ translation: StringLiteralType, for key: StringLiteralType, in language: Language) throws {
//        var entry = try getEntry(for: key)
//        var localizations = entry.localizations
//        if var localization = localizations[language] {
//            localization.stringUnit?.value = translation
//            localization.stringUnit?.state = .translated
//            localizations[language] = localization
//        } else {
//            localizations[language] = .init(stringUnit: .init(state: .translated, value: translation))
//        }
//        entry.localizations = localizations
//        strings[key] = entry
//    }
//    
//    // MARK: Helpers
//    
//    private func getEntry(for key: StringLiteralType) throws -> Entry {
//        guard let translations = strings[key] else {
//            throw Error.localizedStringKeyNotFound(key)
//        }
//        return translations
//    }
}
