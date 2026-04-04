//
//  Copyright © 2026 Hidden Spectrum, LLC.
//

@testable import SwiftStringCatalog

import Foundation
import Testing

@Suite("CodableKeyDictionary")
struct CodableKeyDictionaryTests {

    @Test("Supports typed subscripting and dictionary literals")
    func subscriptingAndLiteralInit() {
        var dictionary: CodableKeyDictionary<Language, Int> = [.english: 1]
        
        dictionary[.french] = 2
        
        #expect(dictionary[.english] == 1)
        #expect(dictionary[.french] == 2)
        #expect(dictionary[.german, default: 3] == 3)
    }
    
    @Test("Sequence iteration yields typed keys")
    func sequenceIteration() {
        let dictionary: CodableKeyDictionary<Language, Int> = [.english: 1, .german: 2]
        
        let iterated = Dictionary(uniqueKeysWithValues: dictionary.map { ($0.key, $0.value) })
        
        #expect(iterated == [.english: 1, .german: 2])
    }
    
    @Test("Codable round-trips the wrapped raw-value dictionary")
    func codableRoundTrip() throws {
        let dictionary: CodableKeyDictionary<Language, Int> = [.english: 1, .spanishLatinAmerica: 2]
        
        let encoded = try JSONEncoder().encode(dictionary)
        let decoded = try JSONDecoder().decode(CodableKeyDictionary<Language, Int>.self, from: encoded)
        
        #expect(decoded[.english] == 1)
        #expect(decoded[.spanishLatinAmerica] == 2)
        #expect(decoded.wrappedValue == ["en": 1, "es-419": 2])
    }
}
