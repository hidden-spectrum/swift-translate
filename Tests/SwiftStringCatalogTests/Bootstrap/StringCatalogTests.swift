//
//  Copyright © 2026 Hidden Spectrum, LLC.
//

@testable import SwiftStringCatalog

import Foundation
import Testing

@Suite("StringCatalog")
struct StringCatalogTests {

    private let basicTestKey = "This is a test"
    private let appShortcutsKey = "Add a ${applicationName} contact"

    @Test("Loads basic catalog metadata and detected target languages")
    func loadBasicCatalog() throws {
        let catalog = try StringCatalog(url: TestResources.basicCatalog)
        
        #expect(catalog.sourceLanguage == .english)
        #expect(catalog.version == "1.0")
        #expect(Set(catalog.allKeys) == ["I really like tests!", basicTestKey])
        #expect(catalog.targetLanguages == [.italian])
        #expect(catalog.localizableStringsCount == 2)
    }
    
    @Test("Synthesizes a source string when the source localization is missing")
    func sourceFallbackWhenLocalizationMissing() throws {
        let catalog = try StringCatalog(url: TestResources.basicCatalog)
        
        let sourceStrings = try #require(catalog.sourceLanguageStrings[basicTestKey])
        
        #expect(
            snapshots(sourceStrings) == snapshots([
                LocalizableString(
                    kind: .standalone,
                    sourceKey: basicTestKey,
                    targetLanguage: .english,
                    translatedValue: basicTestKey,
                    state: .translated
                )
            ])
        )
    }
    
    @Test("Uses configureWith to override detected targets and create empty copies")
    func configureWithOverridesDetectedTargets() throws {
        let targetLanguages: Set<Language> = [.english, .french, .german, .italian]
        let catalog = try StringCatalog(url: TestResources.basicCatalog, configureWith: targetLanguages)
        
        #expect(catalog.targetLanguages == targetLanguages)
        #expect(catalog.localizableStringsCount == 8)
        
        let localizableStrings = try #require(catalog.localizableStringGroups[basicTestKey]) .strings
        
        #expect(
            snapshots(localizableStrings) == snapshots([
                LocalizableString(kind: .standalone, sourceKey: basicTestKey, targetLanguage: .english, translatedValue: nil, state: .new),
                LocalizableString(kind: .standalone, sourceKey: basicTestKey, targetLanguage: .french, translatedValue: nil, state: .new),
                LocalizableString(kind: .standalone, sourceKey: basicTestKey, targetLanguage: .german, translatedValue: nil, state: .new),
                LocalizableString(kind: .standalone, sourceKey: basicTestKey, targetLanguage: .italian, translatedValue: nil, state: .new)
            ])
        )
    }
    
    @Test("Loads string set source keys and target values using source indexes")
    func loadStringSetCatalog() throws {
        let catalog = try StringCatalog(url: TestResources.appShortcutsCatalog)
        
        #expect(catalog.sourceLanguage == .english)
        #expect(catalog.targetLanguages == [.english, .german, .italian, .spanishLatinAmerica])
        #expect(catalog.localizableStringsCount == 50)
        
        let sourceStrings = try #require(catalog.sourceLanguageStrings[appShortcutsKey])
        #expect(
            snapshots(sourceStrings) == snapshots([
                LocalizableString(
                    kind: .stringSet(index: 0),
                    sourceKey: appShortcutsKey,
                    targetLanguage: .english,
                    translatedValue: appShortcutsKey,
                    state: .new
                ),
                LocalizableString(
                    kind: .stringSet(index: 1),
                    sourceKey: "Add a person in ${applicationName}",
                    targetLanguage: .english,
                    translatedValue: "Add a person in ${applicationName}",
                    state: .new
                )
            ])
        )
        
        let germanStrings = try #require(catalog.localizableStringGroups[appShortcutsKey]) .strings
            .filter { $0.targetLanguage == .german }
        
        #expect(
            snapshots(germanStrings) == snapshots([
                LocalizableString(
                    kind: .stringSet(index: 0),
                    sourceKey: appShortcutsKey,
                    targetLanguage: .german,
                    translatedValue: "Fügen Sie einen ${applicationName} Kontakt hinzu",
                    state: .translated
                ),
                LocalizableString(
                    kind: .stringSet(index: 1),
                    sourceKey: "Add a person in ${applicationName}",
                    targetLanguage: .german,
                    translatedValue: "Fügen Sie eine Person in ${applicationName} hinzu",
                    state: .translated
                )
            ])
        )
    }
    
    @Test("Loads plural and substitution entries from a catalog fixture")
    func loadPluralCatalog() throws {
        let catalog = try StringCatalog(url: TestResources.pluralCatalog)
        
        let pluralStrings = try #require(catalog.localizableStringGroups["pluralTest1"]) .strings
        #expect(
            snapshots(pluralStrings) == snapshots([
                LocalizableString(kind: .variation(.plural(.one)), sourceKey: "I have %lld cat", targetLanguage: .english, translatedValue: "I have %lld cat", state: .translated),
                LocalizableString(kind: .variation(.plural(.other)), sourceKey: "I have %lld cats", targetLanguage: .english, translatedValue: "I have %lld cats", state: .translated),
                LocalizableString(kind: .variation(.plural(.zero)), sourceKey: "I have no cats :(", targetLanguage: .english, translatedValue: "I have no cats :(", state: .translated)
            ])
        )
        
        let substitutionStrings = try #require(catalog.localizableStringGroups["substitutionTest1"]) .strings
        #expect(
            snapshots(substitutionStrings) == snapshots([
                LocalizableString(kind: .standalone, sourceKey: "Found %#@arg1@ with %#@arg2@", targetLanguage: .english, translatedValue: "Found %#@arg1@ with %#@arg2@", state: .translated),
                LocalizableString(kind: .replacement(.init(argNumber: 1, formatSpecifier: "lld", variation: .plural(.one))), sourceKey: "%arg cat", targetLanguage: .english, translatedValue: "%arg cat", state: .translated),
                LocalizableString(kind: .replacement(.init(argNumber: 1, formatSpecifier: "lld", variation: .plural(.other))), sourceKey: "%arg cats", targetLanguage: .english, translatedValue: "%arg cats", state: .translated),
                LocalizableString(kind: .replacement(.init(argNumber: 2, formatSpecifier: "lld", variation: .plural(.one))), sourceKey: "%arg kitten", targetLanguage: .english, translatedValue: "%arg kitten", state: .translated),
                LocalizableString(kind: .replacement(.init(argNumber: 2, formatSpecifier: "lld", variation: .plural(.other))), sourceKey: "%arg kittens", targetLanguage: .english, translatedValue: "%arg kittens", state: .translated)
            ])
        )
    }
    
    @Test("Loads device variations from a catalog fixture")
    func loadDeviceCatalog() throws {
        let catalog = try StringCatalog(url: TestResources.deviceCatalog)
        let deviceStrings = try #require(catalog.localizableStringGroups["deviceGreeting"]) .strings
            .filter { $0.targetLanguage == .german }
        
        #expect(
            snapshots(deviceStrings) == snapshots([
                LocalizableString(kind: .variation(.device(.iPhone)), sourceKey: "Hello iPhone", targetLanguage: .german, translatedValue: "Hallo iPhone", state: .translated),
                LocalizableString(kind: .variation(.device(.mac)), sourceKey: "Hello Mac", targetLanguage: .german, translatedValue: "Hallo Mac", state: .translated)
            ])
        )
    }
    
    @Test("Writes and reloads catalog metadata")
    func writeRoundTripPreservesMetadata() throws {
        let catalog = try StringCatalog(url: TestResources.metadataCatalog)
        let temporaryDirectory = try TemporaryDirectory()
        defer { temporaryDirectory.cleanup() }
        
        let outputURL = temporaryDirectory.file(named: "MetadataCatalog", pathExtension: "xcstrings")
        try catalog.write(to: outputURL)
        
        let reloadedCatalog = try StringCatalog(url: outputURL)
        let group = try #require(reloadedCatalog.localizableStringGroups["Brand Name"])
        
        #expect(reloadedCatalog.version == "1.1")
        #expect(group.comment == "Do not translate")
        #expect(group.isCommentAutoGenerated == true)
        #expect(group.extractionState == .manual)
        #expect(group.generatesSymbol == true)
        #expect(group.shouldTranslate == false)
    }
    
    @Test("write(to:) overwrites an existing file with valid catalog data")
    func writeOverwritesExistingFile() throws {
        let catalog = try StringCatalog(url: TestResources.metadataCatalog)
        let temporaryDirectory = try TemporaryDirectory()
        defer { temporaryDirectory.cleanup() }
        
        let outputURL = temporaryDirectory.file(named: "ExistingCatalog", pathExtension: "xcstrings")
        try Data("not a catalog".utf8).write(to: outputURL)
        
        try catalog.write(to: outputURL)
        let reloadedCatalog = try StringCatalog(url: outputURL)
        
        #expect(reloadedCatalog.sourceLanguage == .english)
        #expect(Set(reloadedCatalog.allKeys) == ["Brand Name", "Welcome"])
    }
}
