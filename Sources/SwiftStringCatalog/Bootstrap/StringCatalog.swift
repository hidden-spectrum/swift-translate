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
    
    // MARK: Public private(set)
    
    public private(set) var localizableStrings: [String: [LocalizableString]] = [:]
    public private(set) var localizableStringsCount: Int = 0
    
    public private(set) var targetLanguages: Set<Language> = []
    
    // MARK: Internal
    
    // MARK: Private
    
    // MARK: Lifecycle
    
    public init(url: URL) throws {
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        let catalog = try decoder.decode(_StringCatalog.self, from: data)
        if catalog.version != version {
            throw Error.catalogVersionNotSupported(catalog.version)
        }
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
            let localizableStrings = try localizableStrings(for: entry, in: key)
            localizableStringsCount += localizableStrings.count
            self.localizableStrings[key] = localizableStrings
        }
    }
    
    private func localizableStrings(for entry: _CatalogEntry, in key: StringLiteralType) throws -> [LocalizableString] {
        let sourceLocalizableStrings = try sourceLocalizableStrings(in: entry, for: key)
        var localizableStrings = [LocalizableString]()
        
        for language in targetLanguages {
            if let localization = entry.localizations[language] {
                localizableStrings += try localization.constructLocalizableStrings(
                    context: .needTranslationFromKeyIn(sourceLocalizableStrings: sourceLocalizableStrings),
                    targetLanguage: language
                )
            } else {
                localizableStrings += sourceLocalizableStrings.map {
                    $0.emptyCopy(for: language)
                }
            }
        }
        
        return localizableStrings
    }
    
    func sourceLocalizableStrings(in entry: _CatalogEntry, for key: StringLiteralType) throws -> [LocalizableString] {
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
    
    // MARK: Configuration
    
    public func targetAllLanguages() {
        targetLanguages = Set(Language.allCases)
    }
    
    public func setTargetLanguages(_ languages: [Language]) {
        targetLanguages = Set(languages)
    }
    
    // MARK: Read/write
    
    public func write(to url: URL) throws {
        //        let encoder = JSONEncoder()
        //        encoder.outputFormatting = .prettyPrinted
        //        let data = try encoder.encode(catalog)
        //
        //        let fileManager = FileManager.default
        //        try? fileManager.removeItem(at: url)
        //        fileManager.createFile(atPath: url.path, contents: data)
    }
}
