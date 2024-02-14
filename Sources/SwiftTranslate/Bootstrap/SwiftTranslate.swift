//
//  Copyright © 2024 Hidden Spectrum, LLC.
//

import ArgumentParser
import Foundation
import OpenAI
import SwiftStringCatalog


@main
struct SwiftTranslate: AsyncParsableCommand {

    // MARK: Public

    @Option(
        name: [.customLong("api-key"), .customShort("k")],
        help: "OpenAI API token"
    )
    private var apiToken: String
    
    @Option(
        name: [.long, .short],
        help: "Text to translate"
    )
    private var text: String?
    
    @Option(
        name: [.customLong("catalog"), .customShort("c")],
        help: "String catalog to translate"
    )
    private var stringCatalogPath: String?
    
    @Option(
        name: [.customLong("lang"), .short],
        help: "Target language"
    )
    private var language: Language?
    
    @Flag(
        name: [.customLong("all-languages")],
        help: "Translate to all languages"
    )
    private var translateToAllLanguages: Bool = false
    
    // MARK: Lifecycle
    
    func run() async throws {
        let translator = OpenAITranslator(with: apiToken)

        if let targetLanguage = language {
            if let text {
                try await translator.translate(text: text, to: targetLanguage)
            } else if let stringCatalogPath {
                try await translator.translateStringCatalog(at: URL(fileURLWithPath: stringCatalogPath), to: [targetLanguage])
            } else {
                throw ValidationError("No text or string catalog path provided")
            }
        } else if translateToAllLanguages {
            if text != nil {
                throw ValidationError("Text option not supported with --all-languages flag")
            } else if let stringCatalogPath {
                try await translator.translateToAllLanguagesStringCatalog(at: URL(fileURLWithPath: stringCatalogPath))
            } else {
                throw ValidationError("No text or string catalog path provided")
            }
        } else {
            throw ValidationError("No target language(s) provided")
        }
    }
}
