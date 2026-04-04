//
//  Copyright © 2026 Hidden Spectrum, LLC.
//

@testable import SwiftStringCatalog

import Testing

@Suite("LocalizableString Lookup")
struct LocalizableStringLookupTests {

    @Test("sourceKeyLookup returns the matching source key")
    func sourceKeyLookupReturnsSingleMatch() throws {
        let localizableStrings = [
            LocalizableString(kind: .standalone, sourceKey: "Hello", targetLanguage: .english, translatedValue: "Hello", state: .translated)
        ]
        
        let sourceKey = try localizableStrings.sourceKeyLookup(matchingKind: .standalone)
        
        #expect(sourceKey == "Hello")
    }
    
    @Test("sourceKeyLookup throws when no match exists")
    func sourceKeyLookupThrowsWhenMissing() {
        let localizableStrings = [
            LocalizableString(kind: .standalone, sourceKey: "Hello", targetLanguage: .english, translatedValue: "Hello", state: .translated)
        ]
        
        do {
            _ = try localizableStrings.sourceKeyLookup(matchingKind: .variation(.plural(.one)))
            Issue.record("Expected SourceKeyLookupError.notFound")
        } catch let error as SourceKeyLookupError {
            #expect(error == .notFound)
        } catch {
            Issue.record("Unexpected error: \(error)")
        }
    }
    
    @Test("sourceKeyLookup throws when multiple matches exist")
    func sourceKeyLookupThrowsWhenMultipleMatchesExist() {
        let localizableStrings = [
            LocalizableString(kind: .standalone, sourceKey: "Hello", targetLanguage: .english, translatedValue: "Hello", state: .translated),
            LocalizableString(kind: .standalone, sourceKey: "Hi", targetLanguage: .english, translatedValue: "Hi", state: .translated)
        ]
        
        do {
            _ = try localizableStrings.sourceKeyLookup(matchingKind: .standalone)
            Issue.record("Expected SourceKeyLookupError.multipleFound")
        } catch let error as SourceKeyLookupError {
            #expect(error == .multipleFound)
        } catch {
            Issue.record("Unexpected error: \(error)")
        }
    }
}
