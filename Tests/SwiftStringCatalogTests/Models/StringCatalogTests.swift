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
        
        XCTAssertEqual(stringCatalog.sourceLanguage, .english)
    }
    
    func testSourceLocalizableStrings() throws {
        let testCatalogURL = Bundle.module.url(forResource: "TestCatalog", withExtension: "json")!
        
        let stringCatalog = try StringCatalog.load(from: testCatalogURL)
        let key = "- or -"
        let entry = try stringCatalog.entry(for: key)
        
        let localizableStrings = try stringCatalog.sourceLocalizableStrings(in: entry, for: key)
        
        XCTAssertEqual(
            localizableStrings.first,
            LocalizableString(
                kind: .standalone,
                sourceKey: key,
                targetLanguage: .english,
                translatedValue: key,
                state: .translated
            )
        )
    }
    
    func testLocalizableStrings() throws {
        let testCatalogURL = Bundle.module.url(forResource: "TestCatalog", withExtension: "json")!
        
        var stringCatalog = try StringCatalog.load(from: testCatalogURL)
        stringCatalog.setTargetLanguages([.arabic, .chineseHongKong, .english, .french, .german, .italian, .japanese, .korean, .russian, .spanish])
        let key = "audioConverterQueue.supportedFileFormats"
        
        let localizableStrings = try stringCatalog.localizableStrings(for: key)
        
        XCTAssertEqual(localizableStrings.count, 10)
    }
}
