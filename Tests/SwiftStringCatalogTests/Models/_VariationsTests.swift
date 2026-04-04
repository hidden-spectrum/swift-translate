//
//  Copyright © 2026 Hidden Spectrum, LLC.
//

@testable import SwiftStringCatalog

import Testing

@Suite("_Variations")
struct _VariationsTests {

    @Test("constructLocalizableStrings maps device source keys from the source language")
    func constructDeviceTargetStrings() throws {
        let variations = _Variations(
            device: [
                .iPhone: _Variation(state: .translated, translatedValue: "Hallo iPhone")!,
                .mac: _Variation(state: .translated, translatedValue: "Hallo Mac")!
            ],
            plural: nil
        )
        let context = LocalizableStringConstructionContext.targetLanguageContext(
            targetLanguage: .german,
            sourceLanguageStrings: [
                LocalizableString(kind: .variation(.device(.iPhone)), sourceKey: "Hello iPhone", targetLanguage: .english, translatedValue: "Hello iPhone", state: .translated),
                LocalizableString(kind: .variation(.device(.mac)), sourceKey: "Hello Mac", targetLanguage: .english, translatedValue: "Hello Mac", state: .translated)
            ]
        )
        
        let localizableStrings = try variations.constructLocalizableStrings(with: context)
        
        #expect(
            snapshots(localizableStrings) == snapshots([
                LocalizableString(kind: .variation(.device(.iPhone)), sourceKey: "Hello iPhone", targetLanguage: .german, translatedValue: "Hallo iPhone", state: .translated),
                LocalizableString(kind: .variation(.device(.mac)), sourceKey: "Hello Mac", targetLanguage: .german, translatedValue: "Hallo Mac", state: .translated)
            ])
        )
    }
    
    @Test("constructLocalizableStrings throws for device variations when no source key matches")
    func constructDeviceTargetStringsThrowsWithoutSourceMatch() {
        let variations = _Variations(
            device: [.iPhone: _Variation(state: .translated, translatedValue: "Hallo iPhone")!],
            plural: nil
        )
        let context = LocalizableStringConstructionContext.targetLanguageContext(
            targetLanguage: .german,
            sourceLanguageStrings: []
        )
        
        do {
            _ = try variations.constructLocalizableStrings(with: context)
            Issue.record("Expected SourceKeyLookupError.notFound")
        } catch let error as SourceKeyLookupError {
            #expect(error == .notFound)
        } catch {
            Issue.record("Unexpected error: \(error)")
        }
    }
    
    @Test("constructLocalizableStrings drops plural variations when no source key matches")
    func constructPluralTargetStringsDropsUnmatchedResults() throws {
        let variations = _Variations(
            device: nil,
            plural: [.one: _Variation(state: .translated, translatedValue: "Eine Katze")!]
        )
        let context = LocalizableStringConstructionContext.targetLanguageContext(
            targetLanguage: .german,
            sourceLanguageStrings: []
        )
        
        let localizableStrings = try variations.constructLocalizableStrings(with: context)
        
        #expect(localizableStrings.isEmpty)
    }
    
    @Test("addVariation stores direct and replacement-backed variations")
    func addVariation() {
        var variations = _Variations()
        
        variations.addVariation(from: LocalizableString(
            kind: .variation(.device(.tv)),
            sourceKey: "TV",
            targetLanguage: .english,
            translatedValue: "TV",
            state: .translated
        ))
        variations.addVariation(from: LocalizableString(
            kind: .replacement(.init(argNumber: 1, formatSpecifier: "lld", variation: .plural(.other))),
            sourceKey: "%arg cats",
            targetLanguage: .english,
            translatedValue: "%arg cats",
            state: .needsReview
        ))
        
        #expect(variations.device?[.tv]?.stringUnit.value == "TV")
        #expect(variations.plural?[.other]?.stringUnit.value == "%arg cats")
        #expect(variations.plural?[.other]?.stringUnit.state == .needsReview)
    }
}
