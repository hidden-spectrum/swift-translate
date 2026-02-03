//
//  Copyright © 2024 Hidden Spectrum, LLC.
//

@testable import SwiftStringCatalog
import Foundation
import XCTest


class StringCatalogTests: XCTestCase {
    
    // MARK: Private
    
    let basicTestCatalog = Bundle.module.url(forResource: "BasicCatalog", withExtension: "json")!
    let appShortcutsCatalog = Bundle.module.url(forResource: "AppShortcutsCatalog", withExtension: "json")!
    let basicTestKey = "This is a test"
    let appShortcutsKey = "Add a ${applicationName} contact"
    
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
        
        let localizableStrings = stringCatalog.localizableStringGroups[basicTestKey]?.strings ?? []
        
        XCTAssertEqual(localizableStrings.count, 4)
    }
    
    func testLoad_AppShortcutsStringSet() throws {
        let stringCatalog = try StringCatalog(url: appShortcutsCatalog)
        
        XCTAssertEqual(stringCatalog.sourceLanguage, .english)
        
        let sourceStrings = stringCatalog.sourceLanguageStrings[appShortcutsKey] ?? []
        XCTAssertEqual(sourceStrings.count, 2)
        XCTAssertEqual(sourceStrings[0].kind, .stringSet(index: 0))
        XCTAssertEqual(sourceStrings[0].sourceKey, "Add a ${applicationName} contact")
        XCTAssertEqual(sourceStrings[1].kind, .stringSet(index: 1))
        XCTAssertEqual(sourceStrings[1].sourceKey, "Add a person in ${applicationName}")
        
        let groupedStrings = stringCatalog.localizableStringGroups[appShortcutsKey]?.strings ?? []
        XCTAssertEqual(groupedStrings.count, 8)
        
        let germanStrings = groupedStrings.filter { $0.targetLanguage == .german }
        XCTAssertEqual(germanStrings.count, 2)
    }
}
