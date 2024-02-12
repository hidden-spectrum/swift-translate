//
//  Copyright © 2024 Hidden Spectrum, LLC.
//

@testable import SwiftStringCatalog
import Foundation
import XCTest


class StringCatalogTests: XCTestCase {
    
    let decoder = JSONDecoder()

    func testDecodable() throws {
        let testCatalogURL = Bundle.module.url(forResource: "TestCatalog", withExtension: "json")!
        
        let stringCatalog = try StringCatalog.load(from: testCatalogURL)
        
        let value = try stringCatalog.translation(for: "error.login.noAccount", in: .english)
        XCTAssertEqual(value, "No account with the email address was found.")
    }
}
