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
        
//        let value = try stringCatalog.translation(for: "- or -", in: .chineseHongKong)
//        XCTAssertEqual(value, "- 或 -")
    }
    
    func testSourceLocalizableStrings() throws {
        let testCatalogURL = Bundle.module.url(forResource: "TestCatalog", withExtension: "json")!
        
        let stringCatalog = try StringCatalog.load(from: testCatalogURL)
        let entry = try stringCatalog.entry(for: "%lld additional files not shown")
        
        let localizableStrings = try stringCatalog.sourceLocalizableStrings(in: entry, for: "%lld additional files not shown")
        
        print(localizableStrings)
        
        XCTAssertEqual(localizableStrings.count, 2)
    }
}
