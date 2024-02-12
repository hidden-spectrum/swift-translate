//
//  Copyright © 2024 Hidden Spectrum, LLC.
//

import Foundation
import SwiftStringCatalog
import XCTest


class StringCatalogTests: XCTestCase {
    
    let decoder = JSONDecoder()

    func testDecodable() throws {
        let testCatalogURL = Bundle.module.url(forResource: "TestCatalog", withExtension: "json")!
        let testCatalogFile = try Data(contentsOf: testCatalogURL)
        
        let stringCatalog = try decoder.decode(StringCatalog.self, from: testCatalogFile)
        
        let value = try stringCatalog.localizedValue(for: "error.login.noAccount", in: .english)
        XCTAssertEqual(value, "No account with the email address was found.")
    }
}
