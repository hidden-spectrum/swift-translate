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
    
    @Argument(
        parsing: .remaining,
        help: "File or directory containing string catalogs to translate"
    )
    private var fileOrDirectory: [String]
    
    @Option(
        name: [.customLong("lang"), .short],
        help: "Target language"
    )
    private var language: Language?
    
    @Flag(
        name: [.customLong("overwrite")],
        help: "Overwrite string catalog files instead of creating a new file"
    )
    private var overwriteExistingCatalogs: Bool = false
    
    @Flag(
        name: [.customLong("skip-confirmation"), .customShort("y")],
        help: "Skips confirmation for translating large string files"
    )
    private var skipConfirmation: Bool = false
    
    @Option(
        name: [.long, .short],
        help: "Text to translate"
    )
    private var text: String?
    
    @Flag(
        name: [.customLong("all-languages")],
        help: "Translate to all common languages (see CommonLanguage.swift)"
    )
    private var translateToAllLanguages: Bool = false
    
    @Flag(help: "Enables verbose log output")
    private var verbose: Bool = false
    
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
        } else if let fileOrDirectory = fileOrDirectory.first {
            mode = .fileOrDirectory(
                URL(fileURLWithPath: fileOrDirectory),
                targetLanguages,
                overwrite: overwriteExistingCatalogs
            )
        } else {
            throw ValidationError("No text or string catalog file to translate provided")
        }
        
        let coordinator = TranslationCoordinator(
            mode: mode,
            translator: translator,
            skipConfirmation: skipConfirmation,
            verbose: verbose
        )
        try await coordinator.translate()
    }
}
