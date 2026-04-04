//
//  Copyright © 2026 Hidden Spectrum, LLC.
//

@testable import SwiftStringCatalog

import Foundation
import Testing

@Suite("Language")
struct LanguageTests {

    @Test("Codable round-trips region-specific language codes")
    func codableRoundTrip() throws {
        let encoded = try JSONEncoder().encode(Language.spanishLatinAmerica)
        let decoded = try JSONDecoder().decode(Language.self, from: encoded)
        
        #expect(decoded == .spanishLatinAmerica)
        #expect(decoded.rawValue == "es-419")
    }
    
    @Test("allCommon contains the documented common languages")
    func allCommon() {
        #expect(Language.allCommon.contains(.english))
        #expect(Language.allCommon.contains(.portugueseBrazil))
        #expect(Language.allCommon.contains(.spanishLatinAmerica))
        #expect(!Language.allCommon.contains(.ukrainian))
    }
}
