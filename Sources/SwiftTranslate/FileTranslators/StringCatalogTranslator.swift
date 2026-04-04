//
//  Copyright © 2024 Hidden Spectrum, LLC.
//

import Foundation
import SwiftStringCatalog


struct StringCatalogTranslator: FileTranslator {
    
    // MARK: Internal
    
    let overwrite: Bool
    let skipConfirmations: Bool
    let targetLanguages: Set<Language>?
    let service: TranslationService
    let enableConfidenceReview: Bool
    let verbose: Bool
    
    // MARK: Lifecycle
    
    init(with translator: TranslationService, targetLanguages: Set<Language>?, overwrite: Bool, enableConfidenceReview: Bool, skipConfirmations: Bool, verbose: Bool) {
        self.skipConfirmations = skipConfirmations
        self.overwrite = overwrite
        self.targetLanguages = targetLanguages
        self.service = translator
        self.enableConfidenceReview = enableConfidenceReview
        self.verbose = verbose
    }
    
    func translate(fileAt fileUrl: URL) async throws -> Int {
        let catalog = try loadStringCatalog(from: fileUrl)
        
        if !skipConfirmations {
            verifyLargeTranslation(of: catalog.allKeys.count, to: catalog.targetLanguages.count)
        }
        
        if catalog.allKeys.isEmpty {
            return 0
        }
        
        for key in catalog.allKeys {
            try await translate(key: key, in: catalog)
        }
        
        var targetUrl = fileUrl
        if !overwrite {
            targetUrl = targetUrl.deletingPathExtension().appendingPathExtension("loc.xcstrings")
        }
        try catalog.write(to: targetUrl)
        return catalog.allKeys.count
    }
    
    private func loadStringCatalog(from url: URL) throws -> StringCatalog {
        Log.info(newline: .before, "Loading catalog \(url.path) into memory...")
        let catalog = try StringCatalog(url: url, configureWith: targetLanguages)
        Log.info("Found \(catalog.allKeys.count) keys targeting \(catalog.targetLanguages.count) languages for a total of \(catalog.localizableStringsCount) localizable strings")
        return catalog
    }
    
    private func translate(key: String, in catalog: StringCatalog) async throws {
        guard let localizableStringGroup = catalog.localizableStringGroups[key] else {
            return
        }
        
        if let shouldTranslate = localizableStringGroup.shouldTranslate, shouldTranslate == false {
            Log.info(newline: verbose ? .before : .none, "Skipping key `\(key.truncatedRemovingNewlines(to: 64))` (marked Do Not Translate) " + "[Comment: \(localizableStringGroup.comment ?? "n/a")]".dim)
            return
        }
        
        if localizableStringGroup.extractionState == .stale {
            Log.info(
                newline: verbose ? .before : .none,
                "Skipping key `\(key.truncatedRemovingNewlines(to: 64))` (extraction state is stale) "
                + "[Comment: \(localizableStringGroup.comment ?? "n/a")]".dim
            )
            return
        }
        
        Log.info(newline: verbose ? .before : .none, "Translating key `\(key.truncatedRemovingNewlines(to: 64))` " + "[Comment: \(localizableStringGroup.comment ?? "n/a")]".dim)

        try await withThrowingTaskGroup(of: Void.self) { taskGroup in
            for localizableString in localizableStringGroup.strings {
                let isSource = catalog.sourceLanguage == localizableString.targetLanguage
                let targetLanguage = localizableString.targetLanguage

                if localizableString.state == .translated || localizableString.state == .needsReview || isSource {
                    if verbose {
                        let result = isSource
                            ? localizableString.sourceKey.truncatedRemovingNewlines(to: 64)
                            : "[Already translated]".dim
                        logTranslationResult(to: targetLanguage, result: result, isSource: isSource)
                    }
                    continue
                }
                
                taskGroup.addTask {
                    try await self.translationTask(
                        for: localizableString,
                        targeting: targetLanguage,
                        isSource: isSource,
                        comment: localizableStringGroup.comment
                    )
                }
            }

            do {
                while try await taskGroup.next() != nil {}
            } catch {
                taskGroup.cancelAll()
                throw error
            }
        }
    }
    
    private func translationTask(for localizableString: LocalizableString, targeting targetLanguage: Language, isSource: Bool, comment: String?) async throws {
        do {
            let response = try await service.translate(localizableString.sourceKey, to: targetLanguage, comment: comment)
            let translation = response.translation
            let needsReview = enableConfidenceReview && response.inputAmbiguous
            localizableString.setTranslation(
                translation,
                state: needsReview ? .needsReview : .translated
            )
            if verbose {
                let truncatedTranslation = translation.truncatedRemovingNewlines(to: 64)
                logTranslationResult(to: targetLanguage, result: truncatedTranslation, isSource: isSource, needsReview: needsReview)
            }
        } catch is CancellationError {
            return
        } catch {
            if let swiftTranslateError = error as? SwiftTranslateError, swiftTranslateError.shouldAbortTranslation {
                logTranslationResult(to: targetLanguage, result: "[Fatal: \(swiftTranslateError.localizedDescription)]".red, isSource: isSource)
                throw swiftTranslateError
            }
            logTranslationResult(to: targetLanguage, result: "[Error: \(error.localizedDescription)]".red, isSource: isSource)
        }
    }
    
    // MARK: Utilities
    
    private func verifyLargeTranslation(of stringsCount: Int, to languageCount: Int) {
        guard stringsCount * languageCount > 200 else {
            return
        }
        print("\n?".yellow, "Are you sure you wish to translate \(stringsCount) keys into \(languageCount) languages? Y/n")
        let yesNo = readLine()
        guard yesNo == "Y" else {
            print("Translation canceled 🫡".yellow)
            exit(0)
        }
    }
    
    private func logTranslationResult(to language: Language, result: String, isSource: Bool, needsReview: Bool = false) {
        var level: Log.Level = .info
        if isSource {
            level = .unimportant
        } else if needsReview {
            level = .warning
        }
        Log.structured(
            level: level,
            .init(width: 8, language.rawValue + ":"),
            .init(result)
        )
    }
}
