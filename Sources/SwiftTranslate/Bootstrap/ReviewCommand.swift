//
//  ReviewCommand.swift
//
//
//  Created by Jonas Bromö on 2024-05-17.
//

import ArgumentParser
import Foundation
import OpenAI
import SwiftStringCatalog

struct ReviewCommand: AsyncParsableCommand {

    static var configuration = CommandConfiguration(
        commandName: "review",
        abstract: "Review the quality of translations marked as NEEDS REVIEW. Marking good translations as translated/green."
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
        title: "Translate string catalogs"
    )
    private var catalogOptions: CatalogTranslationOptions

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

        let targetLanguages = try getTargetLanguages(from: languages)

        guard let fileOrDirectory = catalogOptions.fileOrDirectory.first else {
            throw ValidationError("A string catalog file or directory to evaluate must be provided")
        }

        let coordinator = ActionCoordinator(
            action: .reviewFileOrDirectory(
                URL(fileURLWithPath: fileOrDirectory),
                targetLanguages,
                overwrite: catalogOptions.overwriteExisting
            ),
            translator: translator,
            skipConfirmation: skipConfirmation,
            verbose: verbose
        )
        try await coordinator.process()
    }

}
