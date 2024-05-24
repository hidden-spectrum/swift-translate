//
//  LinterTests.swift
//
//
//  Created by Jonas Bromö on 2024-05-24.
//

import Foundation

@testable import swift_translate
import SwiftStringCatalog
import XCTest
import OpenAI
import TestUtils

class LinterTests: XCTestCase {

    var linter = StringCatalogLinter(verbose: false)

    // MARK: - Non triggering examples

    func testGoodSimple() {
        let passed = lint(
            source: "Hello",
            translation: "Hej",
            language: .swedish
        )
        XCTAssertTrue(passed)
    }

    func testGoodTrailingWhitespace() {
        let passed = lint(
            source: "Hello ",
            translation: "Hej ",
            language: .swedish
        )
        XCTAssertTrue(passed)
    }

    func testGoodWhitespace() {
        let passed = lint(
            source: "One-Time Purchase",
            translation: "Engångsköp",
            language: .swedish
        )
        XCTAssertTrue(passed)
    }

    // MARK: - Non triggering examples

    func testBadTrailingWhitespace() {
        let passed = lint(
            source: "Hello",
            translation: "Hej ",
            language: .swedish
        )
        XCTAssertTrue(!passed)
    }

    func testBadLeadingWhitespace() {
        let passed = lint(
            source: "One-Time Purchase",
            translation: " Engångsköp",
            language: .swedish
        )
        XCTAssertTrue(!passed)
    }

    func testBadBackticks() {
        let passed = lint(
            source: "Something",
            translation: "Någonting``````",
            language: .swedish
        )
        XCTAssertTrue(!passed)
    }

    // MARK: - Helpers

    private func lint(source: String, translation: String, language: Language) -> Bool {
        linter.lint(
            source: source,
            sourceLanguage: .english,
            translation: translation,
            language: language
        )
    }

}
