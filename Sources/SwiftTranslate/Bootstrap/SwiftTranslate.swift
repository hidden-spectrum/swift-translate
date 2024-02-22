//
//  Copyright © 2024 Hidden Spectrum, LLC.
//

import ArgumentParser
import Foundation
import OpenAI
import SwiftStringCatalog


@main
struct SwiftTranslate: AsyncParsableCommand {
    
    // MARK: Command Line Options

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
        name: [.customLong("--skip-confirmation"), .customShort("y")],
        help: "Skips confirmation for translating large string files"
    )
    private var skipConfirmation: Bool = false
    
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
    
    @Flag(
        name: [.customLong("overwrite")],
        help: "Overwrite the string catalog file instead of creating a new file"
    )
    private var overwriteExistingCatalog: Bool = false
    
    // MARK: Lifecycle
    
    func run() async throws {
        let translator = OpenAITranslator(with: apiToken)
        
        var targetLanguages: Set<Language>?
        if let language {
            targetLanguages = Set([language])
        } else if translateToAllLanguages {
            targetLanguages = Set(Language.allCommon)
        }
        
        var mode: TranslationCoordinator.Mode
        if let text {
            guard let targetLanguages else {
                throw ValidationError("Target language(s) is required for text translation")
            }
            mode = .text(text, targetLanguages)
        } else if let stringCatalogPath {
            mode = .stringCatalog(
                URL(fileURLWithPath: stringCatalogPath), 
                targetLanguages,
                overwrite: overwriteExistingCatalog, 
                skipConfirmation: skipConfirmation
            )
        } else {
            throw ValidationError("No target language(s) provided".red)
        }
        
        let coordinator = TranslationCoordinator(mode: mode, translator: translator)
        try await coordinator.translate()
    }
}
