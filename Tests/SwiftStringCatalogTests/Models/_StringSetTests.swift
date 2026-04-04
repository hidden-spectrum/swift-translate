//
//  Copyright © 2026 Hidden Spectrum, LLC.
//

@testable import SwiftStringCatalog

import Testing

@Suite("_StringSet")
struct _StringSetTests {

    @Test("constructLocalizableStrings uses values as source keys in source context")
    func constructSourceStrings() throws {
        let stringSet = _StringSet(state: .translated, values: ["One", "Two"])
        let context = LocalizableStringConstructionContext.sourceLanguageContext(sourceLanguage: .english)
        
        let localizableStrings = try stringSet.constructLocalizableStrings(with: context)
        
        #expect(
            snapshots(localizableStrings) == snapshots([
                LocalizableString(kind: .stringSet(index: 0), sourceKey: "One", targetLanguage: .english, translatedValue: "One", state: .translated),
                LocalizableString(kind: .stringSet(index: 1), sourceKey: "Two", targetLanguage: .english, translatedValue: "Two", state: .translated)
            ])
        )
    }
    
    @Test("constructLocalizableStrings uses source index lookup and falls back when missing")
    func constructTargetStrings() throws {
        let stringSet = _StringSet(state: .translated, values: ["Hallo", "Guten Tag"])
        let context = LocalizableStringConstructionContext.targetLanguageContext(
            targetLanguage: .german,
            sourceLanguageStrings: [
                LocalizableString(kind: .stringSet(index: 0), sourceKey: "Hello", targetLanguage: .english, translatedValue: "Hello", state: .translated)
            ]
        )
        
        let localizableStrings = try stringSet.constructLocalizableStrings(with: context)
        
        #expect(
            snapshots(localizableStrings) == snapshots([
                LocalizableString(kind: .stringSet(index: 0), sourceKey: "Hello", targetLanguage: .german, translatedValue: "Hallo", state: .translated),
                LocalizableString(kind: .stringSet(index: 1), sourceKey: "Guten Tag", targetLanguage: .german, translatedValue: "Guten Tag", state: .translated)
            ])
        )
    }
    
    @Test("addValue pads missing indexes and keeps the highest-priority state")
    func addValuePadsAndMergesState() {
        var stringSet = _StringSet(state: .translated, values: ["One"])
        
        stringSet.addValue("Three", at: 2, state: .needsReview)
        
        #expect(stringSet.values == ["One", "", "Three"])
        #expect(stringSet.state == .needsReview)
    }
    
    @Test("addValue preserves a stronger existing state over a weaker incoming state")
    func addValueKeepsExistingPriority() {
        var stringSet = _StringSet(state: .new, values: ["One"])
        
        stringSet.addValue("One", at: 0, state: .translated)
        
        #expect(stringSet.values == ["One"])
        #expect(stringSet.state == .new)
    }
}
