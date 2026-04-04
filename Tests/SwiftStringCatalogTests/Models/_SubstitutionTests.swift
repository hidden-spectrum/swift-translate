//
//  Copyright © 2026 Hidden Spectrum, LLC.
//

@testable import SwiftStringCatalog

import Testing

@Suite("_Substitution")
struct _SubstitutionTests {

    @Test("constructLocalizableStrings expands variations into replacement strings")
    func constructLocalizableStrings() throws {
        let substitution = _Substitution(
            argNum: 2,
            formatSpecifier: "lld",
            variations: _Variations(
                device: nil,
                plural: [
                    .one: _Variation(state: .translated, translatedValue: "%arg kitten")!,
                    .other: _Variation(state: .translated, translatedValue: "%arg kittens")!
                ]
            )
        )
        let context = LocalizableStringConstructionContext.sourceLanguageContext(sourceLanguage: .english)
        
        let localizableStrings = try substitution.constructLocalizableStrings(with: context)
        
        #expect(
            snapshots(localizableStrings) == snapshots([
                LocalizableString(kind: .replacement(.init(argNumber: 2, formatSpecifier: "lld", variation: .plural(.one))), sourceKey: "%arg kitten", targetLanguage: .english, translatedValue: "%arg kitten", state: .translated),
                LocalizableString(kind: .replacement(.init(argNumber: 2, formatSpecifier: "lld", variation: .plural(.other))), sourceKey: "%arg kittens", targetLanguage: .english, translatedValue: "%arg kittens", state: .translated)
            ])
        )
    }
    
    @Test("addVariations creates the variations container on demand")
    func addVariations() {
        var substitution = _Substitution(argNum: 1, formatSpecifier: "@", variations: nil)
        
        substitution.addVariations(from: LocalizableString(
            kind: .replacement(.init(argNumber: 1, formatSpecifier: "@", variation: .device(.watch))),
            sourceKey: "%arg",
            targetLanguage: .english,
            translatedValue: "Watch",
            state: .translated
        ))
        
        #expect(substitution.variations?.device?[.watch]?.stringUnit.value == "Watch")
    }
}
