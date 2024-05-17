//
//  TranslateCommand.swift
//
//
//  Created by Jonas Bromö on 2024-05-17.
//

import ArgumentParser
import Foundation
import OpenAI
import SwiftStringCatalog

struct TranslateCommand: AsyncParsableCommand {

    static var configuration = CommandConfiguration(
        commandName: "translate"
    )

    // MARK: Command Line Options

    @Option(
        name: [.customLong("api-key"), .customShort("k")],
        help: "OpenAI API token"
    )
    private var apiToken: String

    @Option(
        name: [.customLong("model"), .customShort("m")],
        help: "OpenAI Model (e.g. \"gpt-4o\", the model must support function calling, see: https://platform.openai.com/docs/guides/function-calling/supported-models)"
    )
    private var model: String = Model.gpt3_5Turbo

    @OptionGroup(
        title: "Translate text"
    )
    private var textOptions: TextTranslationOptions

    @OptionGroup(
        title: "Translate string catalogs"
    )
    private var catalogOptions: CatalogTranslationOptions

    @Flag(
        name: [.customLong("evaluate")],
        help: "Evaluate the quality of the translations, marking poor and bad translations for review in the string catalog"
    )
    private var evaluateQuality: Bool = false

    @Option(
        name: [.customLong("lang"), .short],
        parsing: .upToNextOption,
        help: "Target language(s) or `all` for all common languages. Omitting this option will use existing langauges in the String Catalog(s)\n",
        completion: .list(Language.allCommon.map(\.rawValue))
    )
    private var languages: [Language] = [Language("__in_catalog")]

    @Flag(
        name: [.customLong("skip-confirmation"), .customShort("y")],
        help: "Skips confirmation for translating large string files"
    )
    var skipConfirmation: Bool = false

    @Flag(
        name: [.long, .short],
        help: "Enables verbose log output"
    )
    private var verbose: Bool = false

    // MARK: Private

    private static let languageList = [Language("all-common")] + Language.allCommon

    // MARK: Lifecycle

    func run() async throws {
        let translator = OpenAITranslator(with: apiToken, model: model)
        Log.info("Using model: \(model)")

        var targetLanguages: Set<Language>?
        if languages.first?.rawValue == "__in_catalog" {
            targetLanguages = nil
        } else if languages.first?.rawValue == "all" {
            targetLanguages = Set(Language.allCommon)
        } else {
            let invalidLanguages = languages.filter({ !Language.allCommon.contains($0) }).map(\.rawValue)
            guard invalidLanguages.isEmpty else {
                throw ValidationError("Invalid language(s) provided: \(invalidLanguages.joined(separator: ", "))")
            }
            var languages = languages
            if !languages.contains(.english) {
                languages.append(.english)
            }
            targetLanguages = Set(languages)
        }

        var action: ActionCoordinator.Action
        if evaluateQuality {
            guard textOptions.text == nil else {
                throw ValidationError("Evaluating text is not supported")
            }
            guard let fileOrDirectory = catalogOptions.fileOrDirectory.first else {
                throw ValidationError("A string catalog file or directory to evaluate must be provided")
            }
            action = .evaluateQuality(
                URL(fileURLWithPath: fileOrDirectory),
                targetLanguages,
                overwrite: catalogOptions.overwriteExisting
            )
        } else if let text = textOptions.text {
            guard let targetLanguages else {
                throw ValidationError("Target language(s) is required for text translation")
            }
            action = .translateText(text, targetLanguages)
        } else if let fileOrDirectory = catalogOptions.fileOrDirectory.first {
            action = .translateFileOrDirectory(
                URL(fileURLWithPath: fileOrDirectory),
                targetLanguages,
                overwrite: catalogOptions.overwriteExisting
            )
        } else {
            throw ValidationError("No text or string catalog file to translate provided")
        }

        let coordinator = ActionCoordinator(
            action: action,
            translator: translator,
            skipConfirmation: skipConfirmation,
            verbose: verbose
        )
        try await coordinator.process()
    }
}

fileprivate struct TextTranslationOptions: ParsableArguments {

    @Option(
        name: [.long, .short],
        help: "Text to translate"
    )
    var text: String?
}
