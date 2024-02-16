//
//  Copyright © 2024 Hidden Spectrum, LLC.
//

import Foundation


public final class StringCatalog {
    
    // MARK: Public
    
    public enum Error: Swift.Error {
        case noEntryFor(key: String)
        case noSourceLanguageEntryFor(key: String)
        case corruptedEntry
        case substitionsNotYetSupported
        case catalogVersionNotSupported(String)
    }
    
    public let sourceLanguage: Language
    public let version = "1.0" // Only version 1.0 supported for now
    
    public private(set) var allKeys = [String]()
    
    // MARK: Internal
    
    var sourceLanguageStrings = [String: [LocalizableString]]()
    
    // MARK: Public private(set)
    
    public private(set) var localizableStrings: [String: [LocalizableString]] = [:]
    public private(set) var localizableStringsCount: Int = 0
    
    public private(set) var targetLanguages: Set<Language> = []
    
    // MARK: Lifecycle
    
    public init(url: URL) throws {
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        let catalog = try decoder.decode(_StringCatalog.self, from: data)
        if catalog.version != version {
            throw Error.catalogVersionNotSupported(catalog.version)
        }
        
        self.allKeys = Array(catalog.strings.keys)
        self.sourceLanguage = catalog.sourceLanguage
        self.targetLanguages = detectedTargetLanguages(in: catalog)
        
        try loadAllLocalizableStrings(from: catalog)
    }
    
    public init(sourceLanguage: Language, targetLanguages: Set<Language> = []) {
        self.sourceLanguage = sourceLanguage
        self.targetLanguages = targetLanguages
    }
    
    // MARK: Loading
    
    private func detectedTargetLanguages(in catalog: _StringCatalog) -> Set<Language> {
        var targetLanguages = Set<Language>()
        for (_, entry) in catalog.strings {
            for (language, _) in entry.localizations {
                targetLanguages.insert(language)
            }
        }
        return targetLanguages
    }
    
    private func loadAllLocalizableStrings(from catalog: _StringCatalog) throws {
        localizableStringsCount = 0
        for (key, entry) in catalog.strings {
            let sourceLanguageStrings = try sourceLanguageStrings(in: entry, for: key)
            self.sourceLanguageStrings[key] = sourceLanguageStrings
            
            let localizableStrings = try localizableStrings(in: entry, for: key, referencing: sourceLanguageStrings)
            localizableStringsCount += localizableStrings.count
            self.localizableStrings[key] = localizableStrings
        }
    }
    
    private func sourceLanguageStrings(in entry: _CatalogEntry, for key: String) throws -> [LocalizableString] {
        if let localization = entry.localizations[sourceLanguage] {
            return try localization.constructLocalizableStrings(
                context: .isSource,
                targetLanguage: sourceLanguage
            )
        } else {
            return [
                LocalizableString(
                    kind: .standalone,
                    sourceKey: key,
                    targetLanguage: sourceLanguage,
                    translatedValue: key,
                    state: .translated
                )
            ]
        }
    }
    
    private func localizableStrings(
        in entry: _CatalogEntry,
        for key: String,
        referencing sourceLanguageStrings: [LocalizableString]
    ) throws -> [LocalizableString] {
        var localizableStrings = [LocalizableString]()
        
        for language in targetLanguages {
            if let localization = entry.localizations[language] {
                localizableStrings += try localization.constructLocalizableStrings(
                    context: .needTranslationFromKeyIn(sourceLanguageStrings: sourceLanguageStrings),
                    targetLanguage: language
                )
            } else {
                localizableStrings += sourceLanguageStrings.map {
                    $0.emptyCopy(for: language)
                }
            }
        }
        
        return localizableStrings
    }
    
    // MARK: - Configuration
    
    public func targetAllLanguages() {
        targetLanguages = Set(Language.allCases)
    }
    
    public func setTargetLanguages(_ languages: [Language]) {
        targetLanguages = Set(languages)
    }
    
    // MARK: - Accessors
    
    public func localizableStrings(for key: String) -> [LocalizableString] {
        return localizableStrings[key] ?? []
    }
    
    // MARK: - Create / Save Catalog
    
    public func write(to url: URL) throws {
        let entries = try buildCatalogEntries()
        let catalog = _StringCatalog(
            sourceLanguage: sourceLanguage,
            strings: entries
        )
        let encoder = JSONEncoder()
        let data = try encoder.encode(catalog)
        try data.write(to: url)
    }
    
    func buildCatalogEntries() throws -> [StringLiteralType: _CatalogEntry] {
        let entries = [StringLiteralType: _CatalogEntry]()
//        for (key, localizableStrings) in localizableStrings {
////            entries[key] =
//        }
        return entries
    }
}
