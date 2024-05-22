//
//  Copyright © 2024 Hidden Spectrum, LLC.
//

@testable import SwiftStringCatalog
import Foundation
import XCTest
import TestUtils

class StringCatalogTests: XCTestCase {
    
    // MARK: Private
    
    let basicTestCatalog = try! FileManager.default.find(
        "BasicCatalog.xcstrings",
        in: Bundle.module.bundleURL
    )
    let basicTestKey = "This is a test"
    
    // MARK: Basic Tests
    
    func testLoad_Basic() throws {
        let stringCatalog = try StringCatalog(url: basicTestCatalog)
        
        XCTAssertEqual(stringCatalog.sourceLanguage, .english)
    }
    
    func testSourceLocalizableStrings_Basic() throws {
        let stringCatalog = try StringCatalog(url: basicTestCatalog)
        
        let localizableStrings = stringCatalog.sourceLanguageStrings[basicTestKey]
        
        XCTAssertEqual(
            localizableStrings?.first,
            LocalizableString(
                kind: .standalone,
                sourceValue: basicTestKey,
                targetLanguage: .english,
                translatedValue: basicTestKey,
                state: .translated
            )
        )
    }
    
    func testLocalizableStrings_Basic() throws {
        let targetLanguages: Set<Language> = [.english, .french, .german, .italian]
        let stringCatalog = try StringCatalog(url: basicTestCatalog, configureWith: targetLanguages)
        
        let localizableStrings = stringCatalog.localizableStringGroups[basicTestKey]?.strings ?? []
        
        XCTAssertEqual(localizableStrings.count, 4)
    }

    func testReadKey1() throws {
        let catalog = try StringCatalog(url: basicTestCatalog)
        let localizableString = catalog.localizableStringGroups["KEY_1"]?.string(for: .italian)

        XCTAssertEqual(localizableString?.sourceValue, "Translation")
        XCTAssertEqual(localizableString?.translatedValue, "Traduzione")
        XCTAssertEqual(localizableString?.state, .translated)
    }

    func testReadTranslation() throws {
        let catalog = try StringCatalog(url: basicTestCatalog)
        let localizableString = catalog.localizableStringGroups["Translation"]?.string(for: .italian)

        XCTAssertEqual(localizableString?.sourceValue, "Translation")
        XCTAssertEqual(localizableString?.translatedValue, "Traduzione")
        XCTAssertEqual(localizableString?.state, .translated)
    }

}
