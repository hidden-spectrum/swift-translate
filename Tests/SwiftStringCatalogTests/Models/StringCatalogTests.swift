//
//  Copyright © 2024 Hidden Spectrum, LLC.
//

@testable import SwiftStringCatalog
import Foundation
import XCTest


class StringCatalogTests: XCTestCase {
    
    func testLoad() throws {
        let testCatalogURL = Bundle.module.url(forResource: "TestCatalog", withExtension: "json")!
        
        let stringCatalog = try StringCatalog.load(from: testCatalogURL)
        
        let value = try stringCatalog.translation(for: "- or -", in: .chineseHongKong)
        XCTAssertEqual(value, "- 或 -")
    }
}
