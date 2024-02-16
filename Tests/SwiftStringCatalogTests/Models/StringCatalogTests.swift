//
//  Copyright © 2024 Hidden Spectrum, LLC.
//

@testable import SwiftStringCatalog
import Foundation
import XCTest


class StringCatalogTests: XCTestCase {
    
    // MARK: Private
    
    let basicTestCatalog = Bundle.module.url(forResource: "BasicCatalog", withExtension: "json")!
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
                sourceKey: basicTestKey,
                targetLanguage: .english,
                translatedValue: basicTestKey,
                state: .translated
            )
        )
    }
    
    func testLocalizableStrings_Basic() throws {
        let targetLanguages: Set<Language> = [.english, .french, .german, .italian]
        let stringCatalog = try StringCatalog(url: basicTestCatalog, configureWith: targetLanguages)
        
        let localizableStrings = stringCatalog.localizableStrings(for: basicTestKey)
        
        XCTAssertEqual(localizableStrings.count, 4)
    }
}
