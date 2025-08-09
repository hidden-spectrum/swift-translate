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
        var translatedKeysCount: Int = 1
        
        switch mode {
        case .fileOrDirectory(let fileOrDirectoryUrl, let targetLanguages, let overwrite):
            translatedKeysCount = try await translateFiles(at: fileOrDirectoryUrl, to: targetLanguages, overwrite: overwrite)
        case .text(let string, let targetLanguages):
            try await translate(string, to: targetLanguages)
        }
        if translatedKeysCount > 0 {
            Log.success(newline: .after, startDate: startDate, "Translated \(translatedKeysCount) key(s)")
        }
    }
    
    // MARK: Translate Text
    
    private func translate(_ string: String, to targetLanguages: Set<Language>) async throws {
        Log.info(newline: .before, "Translating `", string, "`:")
        for language in targetLanguages {
            let translation = try await translator.translate(string, to: language, comment: nil)
            Log.structured(
                .init(width: 8, language.rawValue + ":"),
                .init(translation.translation)
            )
        }
    }
    
    // MARK: Translate Files
    
    private func translateFiles(at url: URL, to targetLanguages: Set<Language>?, overwrite: Bool) async throws -> Int {
        let fileFinder = TranslatableFileFinder(fileOrDirectoryURL: url, type: .stringCatalog)
        let translatableFiles = try fileFinder.findTranslatableFiles()
        
        if translatableFiles.isEmpty {
            return 0
        }
        
        let fileTranslator = StringCatalogTranslator(
            with: translator,
            targetLanguages: targetLanguages,
            overwrite: overwrite,
            skipConfirmations: skipConfirmation,
            verbose: verbose
        )
        
        var translatedKeys = 0
        for file in translatableFiles {
            translatedKeys += try await fileTranslator.translate(fileAt: file)
        }
        
        return translatedKeys
    }
}
