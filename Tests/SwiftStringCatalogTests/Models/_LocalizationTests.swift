//
//  Copyright © 2026 Hidden Spectrum, LLC.
//

@testable import SwiftStringCatalog

import Testing

@Suite("_Localization")
struct _LocalizationTests {

    @Test("constructLocalizableStrings returns standalone and substitution strings")
    func constructStringUnitAndSubstitutions() throws {
        let localization = _Localization(
            stringUnit: _StringUnit(state: .translated, value: "Found %#@arg1@"),
            stringSet: nil,
            substitutions: [
                "arg1": _Substitution(
                    argNum: 1,
                    formatSpecifier: "lld",
                    variations: _Variations(
                        device: nil,
                        plural: [.one: _Variation(state: .translated, translatedValue: "%arg cat")!]
                    )
                )
            ],
            variations: nil
        )
        let context = LocalizableStringConstructionContext.sourceLanguageContext(sourceLanguage: .english)
        
        let localizableStrings = try localization.constructLocalizableStrings(with: context)
        
        #expect(
            snapshots(localizableStrings) == snapshots([
                LocalizableString(kind: .standalone, sourceKey: "Found %#@arg1@", targetLanguage: .english, translatedValue: "Found %#@arg1@", state: .translated),
                LocalizableString(kind: .replacement(.init(argNumber: 1, formatSpecifier: "lld", variation: .plural(.one))), sourceKey: "%arg cat", targetLanguage: .english, translatedValue: "%arg cat", state: .translated)
            ])
        )
    }
    
    @Test("constructLocalizableStrings delegates to string sets and variations")
    func constructStringSetAndVariations() throws {
        let stringSetLocalization = _Localization(
            stringUnit: nil,
            stringSet: _StringSet(state: .translated, values: ["One", "Two"]),
            substitutions: nil,
            variations: nil
        )
        let variationsLocalization = _Localization(
            stringUnit: nil,
            stringSet: nil,
            substitutions: nil,
            variations: _Variations(
                device: nil,
                plural: [.other: _Variation(state: .translated, translatedValue: "Many")!]
            )
        )
        
        let stringSetStrings = try stringSetLocalization.constructLocalizableStrings(
            with: .sourceLanguageContext(sourceLanguage: .english)
        )
        let variationStrings = try variationsLocalization.constructLocalizableStrings(
            with: .sourceLanguageContext(sourceLanguage: .english)
        )
        
        #expect(stringSetStrings.count == 2)
        #expect(variationStrings.count == 1)
        #expect(variationStrings.first?.kind == .variation(.plural(.other)))
    }
    
    @Test("constructLocalizableStrings returns an empty array when no storage is populated")
    func constructEmptyLocalization() throws {
        let localization = _Localization()
        
        let localizableStrings = try localization.constructLocalizableStrings(
            with: .sourceLanguageContext(sourceLanguage: .english)
        )
        
        #expect(localizableStrings.isEmpty)
    }
    
    @Test("mutating helpers populate substitutions, string sets, and variations")
    func helperMutations() {
        var localization = _Localization()
        
        localization.addStringSetValue(from: LocalizableString(
            kind: .stringSet(index: 2),
            sourceKey: "Third",
            targetLanguage: .english,
            translatedValue: "Third",
            state: .translated
        ))
        localization.addSubstitution(from: LocalizableString(
            kind: .replacement(.init(argNumber: 1, formatSpecifier: "@", variation: .plural(.one))),
            sourceKey: "%arg cat",
            targetLanguage: .english,
            translatedValue: "%arg cat",
            state: .translated
        ))
        localization.addVariations(from: LocalizableString(
            kind: .variation(.device(.vision)),
            sourceKey: "Vision",
            targetLanguage: .english,
            translatedValue: "Vision",
            state: .translated
        ))
        
        #expect(localization.stringSet?.values == ["", "", "Third"])
        #expect(localization.substitutions?["arg1"]?.variations?.plural?[.one]?.stringUnit.value == "%arg cat")
        #expect(localization.variations?.device?[.vision]?.stringUnit.value == "Vision")
    }
}
