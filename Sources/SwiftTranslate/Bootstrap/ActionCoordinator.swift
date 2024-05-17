//
//  Copyright © 2024 Hidden Spectrum, LLC.
//

import ArgumentParser
import Foundation
import Rainbow
import SwiftStringCatalog


struct ActionCoordinator {
    
    // MARK: Internal
    
    enum Action {
        case translateFileOrDirectory(URL, Set<Language>?, overwrite: Bool)
        case translateText(String, Set<Language>)
        case reviewFileOrDirectory(URL, Set<Language>?, overwrite: Bool)
    }

    let action: Action
    let translator: TranslationService
    let skipConfirmation: Bool
    let verbose: Bool

    // MARK: Lifecycle
    
    init(action: Action, translator: TranslationService, skipConfirmation: Bool, verbose: Bool) {
        self.action = action
        self.translator = translator
        self.skipConfirmation = skipConfirmation
        self.verbose = verbose
    }
    
    // MARK: Main
    
    func process() async throws {
        let startDate = Date()
        var keysCount: Int = 1
        let logPrefix: String

        switch action {
        case .translateFileOrDirectory(let fileOrDirectoryUrl, let targetLanguages, let overwrite):
            logPrefix = "Translated"
            keysCount = try await translateFiles(at: fileOrDirectoryUrl, to: targetLanguages, overwrite: overwrite)
        case .translateText(let string, let targetLanguages):
            logPrefix = "Translated"
            try await translate(string, to: targetLanguages)
        case .reviewFileOrDirectory(let url, let languages, let overwrite):
            logPrefix = "Reviewed"
            keysCount = try await reviewFiles(at: url, languages: languages, overwrite: overwrite)

            if keysCount == 0 {
                Log.info(newline: .both, "Found no keys marked as NEEDS REVIEW")
            }
        }
        if keysCount > 0 {
            Log.success(newline: .after, startDate: startDate, "\(logPrefix) \(keysCount) key(s)")
        }
    }
    
    // MARK: Translate Text
    
    private func translate(_ string: String, to targetLanguages: Set<Language>) async throws {
        Log.info(newline: .before, "Translating `", string, "`:")
        for language in targetLanguages {
            let translation = try await translator.translate(string, to: language, comment: nil)
            Log.structured(
                .init(width: 8, language.rawValue + ":"),
                .init(translation)
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

    // MARK: Evaluate translations

    private func reviewFiles(
        at url: URL,
        languages: Set<Language>?,
        overwrite: Bool
    ) async throws -> Int {
        let fileFinder = TranslatableFileFinder(fileOrDirectoryURL: url, type: .stringCatalog)
        let files = try fileFinder.findTranslatableFiles()

        guard let translator = translator as? EvaluationService else {
            throw SwiftTranslateError.evaluationIsNotSupported
        }

        let evaluator = StringCatalogEvaluator(
            with: translator,
            languages: languages,
            overwrite: overwrite,
            skipConfirmations: skipConfirmation,
            verbose: verbose
        )

        var numberOfVerifiedStrings = 0
        for file in files {
            numberOfVerifiedStrings += try await evaluator.process(fileAt: file)
        }
        return numberOfVerifiedStrings
    }

}
