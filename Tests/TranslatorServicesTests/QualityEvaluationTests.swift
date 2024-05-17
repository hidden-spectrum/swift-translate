//
//  QualityEvaluationTests.swift
//
//
//  Created by Jonas Bromö on 2024-05-17.
//

@testable import swift_translate
import SwiftStringCatalog
import XCTest
import OpenAI

class QualityEvaluationTests: XCTestCase {

    let model: Model = .gpt4_o
    var service: EvaluationService!
    var catalog: StringCatalog!

    override func setUp() async throws {
        let stringCatalogURL = try FileManager.default.find(
            "TheGoodTheBadAndTheUgly.xcstrings",
            in: Bundle.module.bundleURL
        )
        guard let stringCatalogURL else {
            // Maybe we didn't succeed to avoid .xcstrings processing,
            // consider reverting to .json
            throw CocoaError(.fileNoSuchFile)
        }
        catalog = try StringCatalog(url: stringCatalogURL)

        // TODO: Is there a better way to read the api key?
        let projectRootURL = try FileManager.default.findProjectRoot()
        guard let apiKeyFileURL = projectRootURL?.appending(component: ".secret-openai-api-key") else {
            Log.error("Please create a .secret-openai-api-key file in the project root (that contains the Package.swift) containing an OpenAI Api Key.")
            throw CocoaError(.fileNoSuchFile)
        }
        let apiKey = try String(contentsOf: apiKeyFileURL, encoding: .utf8)
            .trimmingCharacters(in: .whitespacesAndNewlines)

        service = OpenAITranslator(with: apiKey, model: model)
    }

    func testNotGoodWrongEmoji() async throws {
        let result = try await evaluate(.swedish, key: "Good job! 👍 Keep up the great work. 😊")
        XCTAssertNotEqual(result.quality, .good, "The translation uses the wrong emoji!")
    }

    func testGoodGoodJob() async throws {
        let result = try await evaluate(.swedish, key: "Good job! Keep up the great work.")
        XCTAssertEqual(result.quality, .good, "This is a good translation!")
    }

    func testNotGoodMissingArgumentPlaceholder() async throws {
        let result = try await evaluate(.swedish, key: "Hello %@! You have %lld new messages.")
        XCTAssertNotEqual(result.quality, .good, "Translation is missing the %lld argument placeholder!")
    }

    func testGoodHelloHowAreYou() async throws {
        let result = try await evaluate(.swedish, key: "Hello, how are you?")
        XCTAssertEqual(result.quality, .good, "This is a good translation!")
    }

    func testNotGoodSpellingError() async throws {
        let result = try await evaluate(.swedish, key: "It's a wonderful day!")
        XCTAssertNotEqual(result.quality, .good, "There's a spelling error in the translation.")
    }

    func testNotGoodWrongSentiment() async throws {
        let result = try await evaluate(.swedish, key: "Keep up the great work.")
        XCTAssertNotEqual(result.quality, .good, "Wrong sentiment because the word great has been translated too literally.")
    }

    func testNotGoodMissingQutationMark() async throws {
        let result = try await evaluate(.swedish, key: "She said, \"It's a wonderful day!\"")
        XCTAssertNotEqual(result.quality, .good, "The last quotation mark is missing.")
    }

    func testNotGoodWrongLanguage() async throws {
        let result = try await evaluate(.swedish, key: "Today is the day")
        XCTAssertNotEqual(result.quality, .good, "The translation is not in Swedish.")
    }

    func testNotGoodMissingWhitespace() async throws {
        let result = try await evaluate(.swedish, key: "Today's temperature ")
        XCTAssertNotEqual(result.quality, .good, "The trailing whitespace is missing.")
    }

    func testNotGoodCommentIgnored() async throws {
        let result = try await evaluate(.swedish, key: "Welcome to this Fantastic App!")
        XCTAssertNotEqual(result.quality, .good, "The comment was ignored.")
    }

    // MARK: - Helpers

    private func evaluate(_ language: Language, key: String) async throws -> EvaluationResult {
        guard let group = catalog.localizableStringGroups[key] else {
            fatalError("The string catalog doesn't contain the key: \(key)")
        }
        guard let translation = group.string(for: language)?.translatedValue else {
            fatalError("The string catalog is missing a \(language) translation for the key: \(key)")
        }
        let result = try await service.evaluateQuality(
            key,
            translation: translation,
            in: language,
            comment: group.comment
        )
        return result
    }

}

extension FileManager {

    func find(_ filename: String, in directoryURL: URL) throws -> URL? {
        var isDir: ObjCBool = false
        guard 
            fileExists(atPath: directoryURL.path(), isDirectory: &isDir),
            isDir.boolValue
        else {
            return nil
        }
        let directoryContents = try contentsOfDirectory(atPath: directoryURL.path())
        for content in directoryContents {
            let contentURL = directoryURL.appendingPathComponent(content)
            if content == filename {
                return contentURL
            } else {
                return try find(filename, in: contentURL)
            }
        }
        return nil
    }

    func findProjectRoot(_ path: String = #file) throws -> URL? {
        let url = URL(fileURLWithPath: path)
        let directoryURL = url.deletingLastPathComponent()

        let contents = try contentsOfDirectory(atPath: directoryURL.path())
        if contents.contains("Package.swift") {
            return directoryURL
        }
        return try findProjectRoot(directoryURL.path())
    }

}
