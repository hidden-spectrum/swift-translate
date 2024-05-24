//
//  StringCatalogLinter.swift
//
//
//  Created by Jonas Bromö on 2024-05-24.
//

import Foundation
import SwiftStringCatalog

struct StringCatalogLinter {

    let verbose: Bool

    func lint(_ catalog: StringCatalog, languages: Set<Language>) -> (failed: Int, passed: Int) {
        let languagesString = languages.map(\.rawValue).joined(separator: ", ")

        if verbose {
            Log.info("Linting \"\(languagesString)\".")
        }

        var numberOfFailed = 0
        var numberOfPassed = 0
        for (_, group) in catalog.localizableStringGroups {
            for string in group.strings {
                guard languages.contains(string.targetLanguage) else {
                    continue
                }
                guard let translation = string.translatedValue else {
                    continue
                }

                let passed = lint(
                    source: string.sourceValue,
                    sourceLanguage: catalog.sourceLanguage,
                    translation: translation,
                    language: string.targetLanguage
                )
                if !passed {
                    numberOfFailed += 1
                    string.setNeedsReview()
                } else {
                    numberOfPassed += 1
                }
            }
        }
        return (numberOfFailed, numberOfPassed)
    }

    func lint(
        source: String,
        sourceLanguage: Language,
        translation: String,
        language: Language
    ) -> Bool {
        var failedRule: LintRule?
        for rule in LintRule.allRules {
            let result = rule.evaluate(
                source: source,
                sourceLanguage: sourceLanguage,
                translation: translation,
                language: language
            )
            if result == .bad {
                failedRule = rule
                break
            }
        }

        if let failedRule {
            Log.structured(
                .init(width: 6, language.rawValue),
                .init("🚨 Lint failed \(failedRule.name):"),
                .init("\"\(translation.truncatedRemovingNewlines(to: 64))\""),
                .init("(source \"\(source.truncatedRemovingNewlines(to: 64))\")")
            )
        } else if verbose {
            Log.structured(
                .init(width: 6, language.rawValue),
                .init("✅ Lint passed:"),
                .init("\"\(translation.truncatedRemovingNewlines(to: 64))\""),
                .init("(source \"\(source.truncatedRemovingNewlines(to: 64))\")")
            )
        }

        return failedRule == nil
    }

}

enum LintStatus {
    case good, bad
}

struct LintRule {

    typealias Evaluator = (
        _ source: String,
        _ sourceLanguage: Language,
        _ translation: String,
        _ language: Language
    ) -> LintStatus

    let name: String
    private let evaluator: Evaluator

    init(name: String, evaluator: @escaping Evaluator) {
        self.name = name
        self.evaluator = evaluator
    }

    func evaluate(source: String, sourceLanguage: Language, translation: String, language: Language) -> LintStatus {
        evaluator(source, sourceLanguage, translation, language)
    }

}

extension LintRule {

    static var allRules: [LintRule] = [
        .unbalancedWhitespace,
        .specialCharactersNotInSource
    ]

    static let unbalancedWhitespace = LintRule(
        name: "unbalanced_whitespace"
    ) { source, sourceLanguage, translation, language in

        // Trim leading/trailing whitespace
        let trimmedSource = source.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedTranslation = translation.trimmingCharacters(in: .whitespacesAndNewlines)

        // Subtract it from the original, leaving just the leading/trailing whitespace (LTW)
        let sourceLTW = source.replacing(trimmedSource, with: "")
        let translationLTW = translation.replacing(trimmedTranslation, with: "")

        guard sourceLTW == translationLTW else {
            return .bad
        }

        return .good
    }

    static let specialCharactersNotInSource = LintRule(
        name: "special_characters_not_in_source"
    ) { source, sourceLanguage, translation, language in
        if translation.contains("`") && !source.contains("`") {
            return .bad
        }
        return .good
    }
}
