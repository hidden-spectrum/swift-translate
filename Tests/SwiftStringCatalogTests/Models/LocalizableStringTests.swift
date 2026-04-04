//
//  Copyright © 2026 Hidden Spectrum, LLC.
//

@testable import SwiftStringCatalog

import Testing

@Suite("LocalizableString")
struct LocalizableStringTests {

    @Test("setTranslation updates the translated value and state")
    func setTranslation() {
        let localizableString = LocalizableString(
            kind: .standalone,
            sourceKey: "Hello",
            targetLanguage: .german,
            translatedValue: nil,
            state: .new
        )
        
        localizableString.setTranslation("Hallo", state: .needsReview)
        
        #expect(localizableString.translatedValue == "Hallo")
        #expect(localizableString.state == .needsReview)
    }
    
    @Test("convertKindToSubstitution turns a variation into a replacement")
    func convertKindToSubstitution() {
        let localizableString = LocalizableString(
            kind: .variation(.plural(.one)),
            sourceKey: "%arg cat",
            targetLanguage: .english,
            translatedValue: "%arg cat",
            state: .translated
        )
        
        localizableString.convertKindToSubstitution(argNum: 2, formatSpecifier: "lld")
        
        #expect(
            localizableString.kind
                == .replacement(.init(argNumber: 2, formatSpecifier: "lld", variation: .plural(.one)))
        )
    }
    
    @Test("convertKindToSubstitution leaves non-variation kinds unchanged")
    func convertKindToSubstitutionIgnoresNonVariations() {
        let localizableString = LocalizableString(
            kind: .standalone,
            sourceKey: "Hello",
            targetLanguage: .english,
            translatedValue: "Hello",
            state: .translated
        )
        
        localizableString.convertKindToSubstitution(argNum: 1, formatSpecifier: "@")
        
        #expect(localizableString.kind == .standalone)
    }
    
    @Test("emptyCopy preserves identity data and resets translation state")
    func emptyCopy() {
        let original = LocalizableString(
            kind: .stringSet(index: 3),
            sourceKey: "Create an event",
            targetLanguage: .english,
            translatedValue: "Create an event",
            state: .translated
        )
        
        let copy = original.emptyCopy(for: .french)
        
        #expect(copy.kind == .stringSet(index: 3))
        #expect(copy.sourceKey == "Create an event")
        #expect(copy.targetLanguage == .french)
        #expect(copy.translatedValue == nil)
        #expect(copy.state == .new)
    }
}
