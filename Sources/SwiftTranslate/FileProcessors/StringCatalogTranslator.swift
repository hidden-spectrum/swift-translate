//
//  Copyright © 2024 Hidden Spectrum, LLC.
//

import Foundation
import SwiftStringCatalog


struct StringCatalogTranslator: FileTranslator {
    
    // MARK: Internal
    
    let overwrite: Bool
    let skipConfirmations: Bool
    let setNeedsReviewAfterTranslating: Bool
    let targetLanguages: Set<Language>?
    let service: TranslationService
    let verbose: Bool
    
    // MARK: Lifecycle
    
    init(
        with translator: TranslationService,
        targetLanguages: Set<Language>?,
        overwrite: Bool,
        skipConfirmations: Bool,
        setNeedsReviewAfterTranslating: Bool,
        verbose: Bool
    ) {
        self.skipConfirmations = skipConfirmations
        self.overwrite = overwrite
        self.targetLanguages = targetLanguages
        self.service = translator
        self.setNeedsReviewAfterTranslating = setNeedsReviewAfterTranslating
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

        var targetUrl = fileUrl
        if !overwrite {
            targetUrl = targetUrl.deletingPathExtension().appendingPathExtension("loc.xcstrings")
        }

        var translatedStringsCount = 0
        for key in catalog.allKeys {
            try await translate(
                key: key,
                in: catalog,
                translatedStringsCount: &translatedStringsCount,
                savingPeriodicallyTo: targetUrl
            )
        }

        try catalog.write(to: targetUrl)

        return translatedStringsCount
    }
    
    private func loadStringCatalog(from url: URL) throws -> StringCatalog {
        Log.info(newline: .before, "Loading catalog \(url.path) into memory...")
        let catalog = try StringCatalog(url: url, configureWith: targetLanguages)
        Log.info("Found \(catalog.allKeys.count) keys targeting \(catalog.targetLanguages.count) languages for a total of \(catalog.localizableStringsCount) localizable strings")
        return catalog
    }
    
    private func translate(
        key: String,
        in catalog: StringCatalog,
        translatedStringsCount: inout Int,
        savingPeriodicallyTo fileURL: URL
    ) async throws {
        guard let localizableStringGroup = catalog.localizableStringGroups[key] else {
            return
        }
        Log.info(newline: verbose ? .before : .none, "Translating key `\(key.truncatedRemovingNewlines(to: 64))` " + "[Comment: \(localizableStringGroup.comment ?? "n/a")]".dim)
        
        for localizableString in localizableStringGroup.strings {
            let isSource = catalog.sourceLanguage == localizableString.targetLanguage
            let targetLanguage = localizableString.targetLanguage
            
            if localizableString.state == .translated || isSource {
                if verbose {
                    let result = isSource 
                        ? localizableString.sourceValue.truncatedRemovingNewlines(to: 64)
                        : "[Already translated]".dim
                    logTranslationResult(to: targetLanguage, result: result, isSource: isSource)
                }
                continue
            }
            
            let numberOfRetries = 1
            var failedAttempts = 0
            while failedAttempts <= numberOfRetries {
                do {
                    let translatedString = try await service.translate(
                        localizableString.sourceValue,
                        to: targetLanguage,
                        comment: localizableStringGroup.comment
                    )
                    localizableString.setTranslation(translatedString)
                    if setNeedsReviewAfterTranslating {
                        localizableString.setNeedsReview()
                    }

                    if verbose {
                        logTranslationResult(to: targetLanguage, result: translatedString.truncatedRemovingNewlines(to: 64), isSource: isSource)
                    }
                    translatedStringsCount += 1
                    break
                } catch {
                    failedAttempts += 1
                    let result: String
                    if failedAttempts <= numberOfRetries {
                        result = "[Error: \(error.localizedDescription)] (retrying)".red
                    } else {
                        result = "[Error: \(error.localizedDescription)]".red
                    }
                    logTranslationResult(to: targetLanguage, result: result, isSource: isSource)
                }
            }

            if translatedStringsCount % 5 == 0 {
                try catalog.write(to: fileURL)
            }
        }
    }

    // MARK: Utilities
    
    private func verifyLargeTranslation(of stringsCount: Int, to languageCount: Int) {
        guard stringsCount * languageCount > 200 else {
            return
        }
        print("\n?".yellow, "Are you sure you wish to translate \(stringsCount) keys into \(languageCount) languages? Y/n")
        let yesNo = readLine()
        guard yesNo?.lowercased() == "y" || yesNo == "" else {
            print("Translation canceled 🫡".yellow)
            exit(0)
        }
    }
    
    private func logTranslationResult(to language: Language, result: String, isSource: Bool) {
        Log.structured(
            level: isSource ? .unimportant : .info,
            .init(width: 8, language.rawValue + ":"),
            .init(result)
        )
    }
}
