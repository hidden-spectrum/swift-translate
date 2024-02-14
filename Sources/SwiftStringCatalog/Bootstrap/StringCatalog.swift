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
    
    private enum CodingKeys: String, CodingKey {
        case sourceLanguage
        case version
        case strings
    }
    
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
    
    public mutating func setTargetLanguages(_ languages: [Language]) {
        targetLangauges = languages
    }
    
    // MARK: Accessors
    
    public var allKeys: Set<StringLiteralType> {
        return Set(strings.keys)
    }
    
    public func localizableStrings(for key: StringLiteralType) throws -> [LocalizableString] {
        let entry = try entry(for: key)
        let sourceLocalizableStrings = try sourceLocalizableStrings(in: entry, for: key)
        var localizableStrings = [LocalizableString]()
        
        for language in targetLangauges {
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
    
    // MARK: Internal Accessors
    
    func entry(for key: StringLiteralType) throws -> _Entry {
        guard let entry = strings[key] else {
            throw Error.noEntryFor(key: key)
        }
        return entry
    }
    
    func sourceLocalizableStrings(in entry: _Entry, for key: StringLiteralType) throws -> [LocalizableString] {
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
}
