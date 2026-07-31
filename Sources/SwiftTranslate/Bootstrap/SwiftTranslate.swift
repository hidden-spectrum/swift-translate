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
        name: [.customLong("service"), .customShort("s")],
        help: "Service to use. Either `openai` (default), `google`, or `gemini`"
    )
    private var service: TranslationServiceArgument = .openAI

    @Option(
        name: [.customLong("api-key"), .customShort("k")],
        help: "OpenAI, Google Cloud Translate (v2), or Gemini API key"
    )
    private var apiToken: String
    
    @Option(
        name: [.customLong("model"), .customShort("m")],
        help: """
            Model to use.
            Defaults to `gpt-5.6-terra` for OpenAI and `gemini-2.5-flash` for Gemini.
            Ignored when using Google Translate.
            """
    )
    private var model: String?
    
    @Option(
        name: [.customLong("reasoning-effort")],
        help: "OpenAI reasoning effort to use (default: none). Lower values are faster. Ignored when using Google Translate or Gemini"
    )
    private var reasoningEffort: OpenAIReasoningEffort = .none
    
    @OptionGroup(
        title: "Translate text"
    )
    private var textOptions: TextTranslationOptions
    
    @OptionGroup(
        title: "Translate string catalogs"
    )
    private var catalogOptions: CatalogTranlationOptions
    
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
        name: [.customLong("enable-confidence-review")],
        help: "Asks the model if it thinks translation may be ambiguous, and marks those translations as `needs_review`. Ignored when using Google Translate"
    )
    private var enableConfidenceReview: Bool = false
    
    @Option(
        name: [.customLong("timeout")],
        help: "Timeout interval for API requests"
    )
    private var timeoutInterval: Int = 60

    @Flag(
        name: [.long, .short],
        help: "Enables verbose log output"
    )
    private var verbose: Bool = false
    
    // MARK: Private
    
    private static let languageList = [Language("all-common")] + Language.allCommon
    
    // MARK: Lifecycle
    
    func run() async throws {
        var translator: TranslationService
        
        switch service {
        case .google:
            translator = GoogleTranslator(apiKey: apiToken, timeoutInterval: timeoutInterval)
        case .openAI:
            let openAIModel = try resolvedOpenAIModel()
            translator = OpenAITranslator(
                with: apiToken,
                model: openAIModel,
                reasoningEffort: reasoningEffort,
                enableConfidenceReview: enableConfidenceReview,
                timeoutInterval: timeoutInterval
            )
        case .gemini:
            let geminiModel = try resolvedGeminiModel()
            translator = GeminiTranslator(
                apiKey: apiToken,
                model: geminiModel,
                enableConfidenceReview: enableConfidenceReview,
                timeoutInterval: timeoutInterval
            )
        }
        
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
            targetLanguages = Set(languages)
        }
        
        var mode: TranslationCoordinator.Mode
        if let text = textOptions.text {
            guard let targetLanguages else {
                throw ValidationError("Target language(s) is required for text translation")
            }
            mode = .text(text, targetLanguages)
        } else if let fileOrDirectory = catalogOptions.fileOrDirectory.first {
            if let unwrappedTargetLanguages = targetLanguages, !unwrappedTargetLanguages.contains(.english) {
                targetLanguages?.insert(.english)
            }
            mode = .fileOrDirectory(
                URL(fileURLWithPath: fileOrDirectory),
                targetLanguages,
                overwrite: catalogOptions.overwriteExisting
            )
        } else {
            throw ValidationError("No text or string catalog file to translate provided")
        }
        
        let coordinator = TranslationCoordinator(
            mode: mode,
            translator: translator,
            enableConfidenceReview: enableConfidenceReview,
            skipConfirmation: skipConfirmation,
            verbose: verbose
        )
        try await coordinator.translate()
    }

    private func resolvedOpenAIModel() throws -> OpenAIModel {
        guard let model else {
            return .gpt5_6_terra
        }
        guard let openAIModel = OpenAIModel(rawValue: model) else {
            throw ValidationError("Invalid OpenAI model `\(model)`. Use `--service gemini` for Gemini models.")
        }
        return openAIModel
    }

    private func resolvedGeminiModel() throws -> GeminiModel {
        guard let model else {
            return .gemini2_5Flash
        }
        guard let geminiModel = GeminiModel(rawValue: model) else {
            throw ValidationError("Invalid Gemini model `\(model)`. Use `--service openai` for OpenAI models.")
        }
        return geminiModel
    }
}


fileprivate struct TextTranslationOptions: ParsableArguments {
    
    @Option(
        name: [.long, .short],
        help: "Text to translate"
    )
    var text: String?
}

fileprivate struct CatalogTranlationOptions: ParsableArguments {
    
    @Flag(
        name: [.customLong("overwrite")],
        help: "Overwrite string catalog files instead of creating a new file"
    )
    var overwriteExisting: Bool = false
    
    @Argument(
        parsing: .remaining,
        help: "File or directory containing string catalogs to translate"
    )
    var fileOrDirectory: [String] = []
}
