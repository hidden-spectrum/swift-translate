//
//  Copyright © 2024 Hidden Spectrum, LLC.
//

import ArgumentParser
import Foundation
import Rainbow
import SwiftStringCatalog


struct TranslationCoordinator {
    
    // MARK: Internal
    
    enum Mode {
        case fileOrDirectory(URL, Set<Language>?, overwrite: Bool)
        case text(String, Set<Language>)
    }

    let mode: Mode
    let translator: TranslationService
    let skipConfirmation: Bool
    let verbose: Bool

    // MARK: Lifecycle
    
    init(mode: Mode, translator: TranslationService, skipConfirmation: Bool, verbose: Bool) {
        self.mode = mode
        self.translator = translator
        self.skipConfirmation = skipConfirmation
        self.verbose = verbose
    }
    
    // MARK: Main
    
    func translate() async throws {
        let startDate = Date()
        switch mode {
        case .fileOrDirectory(let fileOrDirectoryUrl, let targetLanguages, let overwrite):
            try await translateFiles(at: fileOrDirectoryUrl, to: targetLanguages, overwrite: overwrite)
        case .text(let string, let targetLanguages):
            try await translate(string, to: targetLanguages)
        }
        Log.success(newline: true, startDate: startDate, "Done")
    }
    
    // MARK: Translate Text
    
    private func translate(_ string: String, to targetLanguages: Set<Language>) async throws {
        Log.info(newline: true, "Translating `", string, "`:")
        for language in targetLanguages {
            let translation = try await translator.translate(string, to: language, comment: nil)
            Log.structured(
                .init(width: 8, language.rawValue + ":"),
                .init(translation)
            )
        }
    }
    
    // MARK: Translate Files
    
    private func translateFiles(at url: URL, to targetLanguages: Set<Language>?, overwrite: Bool) async throws {
        let fileFinder = TranslatableFileFinder(fileOrDirectoryURL: url, type: .stringCatalog)
        let translatableFiles = try fileFinder.findTranslatableFiles()
        let fileTranslator = StringCatalogTranslator(
            with: translator,
            targetLanguages: targetLanguages,
            overwrite: overwrite,
            skipConfirmations: skipConfirmation,
            verbose: verbose
        )
        for file in translatableFiles {
            try await fileTranslator.translate(fileAt: file)
        }
    }
}
