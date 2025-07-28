//
//  Copyright © 2024 Hidden Spectrum, LLC.
//

import Foundation


public final class StringCatalog {
    
    // MARK: Public
    
    public let sourceLanguage: Language
    public let version: String
    
    public private(set) var allKeys = [String]()
    
    // MARK: Internal
    
    var sourceLanguageStrings = [String: [LocalizableString]]()
    
    // MARK: Public private(set)
    
    public private(set) var localizableStringGroups: [String: LocalizableStringGroup] = [:]
    public private(set) var localizableStringsCount: Int = 0
    
    public private(set) var targetLanguages: Set<Language> = []
    
    // MARK: Lifecycle
    
    public init(url: URL, configureWith targetLanguages: Set<Language>? = nil) throws {
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        let catalog = try decoder.decode(_StringCatalog.self, from: data)
        self.version = catalog.version
        self.allKeys = Array(catalog.strings.keys)
        self.sourceLanguage = catalog.sourceLanguage
        self.targetLanguages = {
            if let targetLanguages {
                targetLanguages
            } else {
                detectedTargetLanguages(in: catalog)
            }
        }()
        
        try loadAllLocalizableStrings(from: catalog)        
    }
    
    public init(sourceLanguage: Language, targetLanguages: Set<Language> = [], version: String = "1.0") {
        self.sourceLanguage = sourceLanguage
        self.targetLanguages = targetLanguages
        self.version = version
    }
    
    // MARK: Loading
    
    private func detectedTargetLanguages(in catalog: _StringCatalog) -> Set<Language> {
        var targetLanguages = Set<Language>()
        for (_, entry) in catalog.strings {
            guard let localizations = entry.localizations else {
                continue
            }
            for (language, _) in localizations {
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
            localizableStringGroups[key] = LocalizableStringGroup(
                comment: entry.comment,
                extractionState: entry.extractionState,
                generatesSymbol: entry.generatesSymbol,
                shouldTranslate: entry.shouldTranslate,
                strings: localizableStrings
            )
        }
    }
    
    private func sourceLanguageStrings(in entry: _CatalogEntry, for key: String) throws -> [LocalizableString] {
        if let localization = entry.localizations?[sourceLanguage] {
            return try localization.constructLocalizableStrings(
                with: .sourceLanguageContext(sourceLanguage: sourceLanguage)
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
            if let localization = entry.localizations?[language] {
                localizableStrings += try localization.constructLocalizableStrings(
                    with: .targetLanguageContext(targetLanguage: language, sourceLanguageStrings: sourceLanguageStrings)
                )
            } else {
                localizableStrings += sourceLanguageStrings.map {
                    $0.emptyCopy(for: language)
                }
            }
        }
        return localizableStrings
    }
    
    // MARK: - Create / Save Catalog
    
    public func write(to url: URL) throws {
        let entries = try buildCatalogEntries()
        let catalog = _StringCatalog(
            sourceLanguage: sourceLanguage,
            strings: entries,
            version: version
        )
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        let data = try encoder.encode(catalog)
        
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: url.path) {
            try fileManager.removeItem(at: url)
        }
        fileManager.createFile(atPath: url.path, contents: data)
    }
    
    func buildCatalogEntries() throws -> [String: _CatalogEntry] {
        var entries = [String: _CatalogEntry]()
        for (key, stringGroup) in localizableStringGroups {
            entries[key] = try _CatalogEntry(from: stringGroup)
        }
        return entries
    }
}
