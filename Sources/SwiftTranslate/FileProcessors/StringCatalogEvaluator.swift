//
//  StringCatalogEvaluator.swift
//
//
//  Created by Jonas Bromö on 2024-05-17.
//

import Foundation
import SwiftStringCatalog

struct StringCatalogEvaluator {
    let service: EvaluationService
    let languages: Set<Language>?
    let overwrite: Bool
    let skipConfirmations: Bool
    let verbose: Bool

    // MARK: Lifecycle

    init(
        with service: EvaluationService,
        languages: Set<Language>?,
        overwrite: Bool,
        skipConfirmations: Bool,
        verbose: Bool
    ) {
        self.service = service
        self.languages = languages
        self.overwrite = overwrite
        self.skipConfirmations = skipConfirmations
        self.verbose = verbose
    }

    func process(fileAt fileUrl: URL) async throws -> Int {
        let catalog = try loadStringCatalog(from: fileUrl)

        var targetUrl = fileUrl
        if !overwrite {
            targetUrl = targetUrl.deletingPathExtension().appendingPathExtension("loc.xcstrings")
        }

        let numberOfVerifiedStrings = try await evaluate(
            catalog: catalog,
            savingPeriodicallyTo: targetUrl
        )

        return numberOfVerifiedStrings
    }

    @discardableResult
    func evaluate(catalog: StringCatalog, savingPeriodicallyTo fileURL: URL? = nil) async throws -> Int {
        if catalog.allKeys.isEmpty {
            return 0
        }
        var reviewedStringsCount = 0
        for key in catalog.allKeys {
            try await evaluate(key: key, in: catalog, reviewedStringsCount: &reviewedStringsCount, savingPeriodicallyTo: fileURL)
        }
        if let fileURL {
            try catalog.write(to: fileURL)
        }
        return reviewedStringsCount
    }

    private func loadStringCatalog(from url: URL) throws -> StringCatalog {
        Log.info(newline: .before, "Loading catalog \(url.path) into memory...")
        let catalog = try StringCatalog(url: url)
        Log.info("Found \(catalog.allKeys.count) keys targeting \(catalog.targetLanguages.count) languages for a total of \(catalog.localizableStringsCount) localizable strings")
        return catalog
    }

    private func evaluate(
        key: String,
        in catalog: StringCatalog,
        reviewedStringsCount: inout Int,
        savingPeriodicallyTo fileURL: URL?
    ) async throws {
        guard let localizableStringGroup = catalog.localizableStringGroups[key] else {
            return
        }

        var hasLoggedWillEvaluate = false

        for localizableString in localizableStringGroup.strings {
            let isSource = catalog.sourceLanguage == localizableString.targetLanguage
            let language = localizableString.targetLanguage

            guard
                languages == nil || languages?.contains(language) == true,
                !isSource,
                localizableString.state == .needsReview,
                let translation = localizableString.translatedValue
            else {
                continue
            }

            // Only log the "Evaluating key" if there's actually a translation to evaluate
            if !hasLoggedWillEvaluate {
                hasLoggedWillEvaluate = true
                Log.info(newline: verbose ? .before : .none, "Evaluating key `\(key.truncatedRemovingNewlines(to: 64))` " + "[Comment: \(localizableStringGroup.comment ?? "n/a")]".dim)
            }

            do {
                let result = try await service.evaluateQuality(
                    key, // TODO: Why does localizableString.sourceKey contain the translated value?
                    translation: translation,
                    in: language,
                    comment: localizableStringGroup.comment
                )
                logResult(result, translation: translation, in: language)
                if result.quality == .good {
                    localizableString.setTranslated()
                }
                reviewedStringsCount += 1
            } catch {
                logError(language: language, error: error)
            }

            if let fileURL, reviewedStringsCount % 5 == 0 {
                try catalog.write(to: fileURL)
            }
        }
    }

    // MARK: Utilities

    private func logResult(_ result: EvaluationResult, translation: String, in language: Language) {
        Log.structured(
            .init(width: 6, language.rawValue),
            .init(width: 8, result.quality.description + ":"),
            .init(translation.truncatedRemovingNewlines(to: 64))
        )
    }

    private func logError(language: Language, error: Error) {
        Log.structured(
            .init(width: 6, language.rawValue),
            .init("[Error: \(error.localizedDescription)]".red)
        )
    }

}
