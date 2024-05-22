//
//  TranslatorTests.swift
//
//
//  Created by Jonas Bromö on 2024-05-19.
//

@testable import swift_translate
import SwiftStringCatalog
import XCTest
import OpenAI
import TestUtils

class TranslatorTests: XCTestCase {

    let model: Model = .gpt3_5Turbo
    var service: TranslationService!
    var catalog: StringCatalog!

    override func setUp() async throws {
        service = OpenAITranslator(with: try apiKey(), model: model)

        let stringCatalogURL = try FileManager.default.find(
            "Localizable.xcstrings",
            in: Bundle.module.bundleURL
        )
        catalog = try StringCatalog(url: stringCatalogURL)
    }

    func testSimpleTranslation() async throws {
        let result = try await translate("Translation", to: .swedish)
        XCTAssertEqual(result, "Översättning")
    }

    func testEmptyString() async throws {
        let empty = try await translate("", to: .swedish)
        XCTAssertEqual(empty, "")
    }

    func testNewline() async throws {
        let newline = try await translate("\n", to: .swedish)
        XCTAssertEqual(newline, "\n")
    }

    func testSpecialCharacters() async throws {
        let specialChars = try await translate(") * ", to: .swedish)
        XCTAssertEqual(specialChars, ") * ")
    }

    func testMarkdownBold() async throws {
        let markdown = try await translate("Enter prices in **%@/kWh**.", to: .swedish)
        XCTAssertEqual(markdown, "Ange priser i **%@/kWh**.")
    }

    // MARK: - Helpers

    private func translate(_ string: String, to language: Language, comment: String? = nil) async throws -> String {
        try await service.translate(string, to: language, comment: comment)
    }

    private func apiKey() throws -> String {
        // TODO: Is there a better way to read the api key?
        let projectRootURL = try FileManager.default.findProjectRoot()
        guard let apiKeyFileURL = projectRootURL?.appending(component: ".secret-openai-api-key") else {
            Log.error("Please create a .secret-openai-api-key file in the project root (that contains the Package.swift) containing an OpenAI Api Key.")
            throw CocoaError(.fileNoSuchFile)
        }
        let apiKey = try String(contentsOf: apiKeyFileURL, encoding: .utf8)
            .trimmingCharacters(in: .whitespacesAndNewlines)
        return apiKey
    }

}
