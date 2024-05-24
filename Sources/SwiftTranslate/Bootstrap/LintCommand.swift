//
//  LintCommand.swift
//
//
//  Created by Jonas Bromö on 2024-05-24.
//

import ArgumentParser
import Foundation
import SwiftStringCatalog

struct LintCommand: ParsableCommand {

    static var configuration = CommandConfiguration(
        commandName: "lint",
        abstract: "Lint translations in String Catalog(s), optionally marking failed as NEEDS REVIEW."
    )

    // MARK: Command Line Options

    @OptionGroup(
        title: "Translate string catalogs"
    )
    private var catalogOptions: CatalogTranslationOptions

    @Option(
        name: [.customLong("lang"), .short],
        parsing: .upToNextOption,
        help: "The language(s) to lint. Or `all` for all languages in the String Catalog(s)",
        completion: .list(Language.allCommon.map(\.rawValue))
    )
    private var languages: [Language] = [Language("all")]

    @Flag(
        name: [.customLong("mark-failing-needs-review")],
        help: "Mark strings that fail as NEEDS REVIEW."
    )
    var markFailingNeedsReview: Bool = false

    @Flag(
        name: [.long, .short],
        help: "Enables verbose log output"
    )
    private var verbose: Bool = false

    func run() throws {

        guard !catalogOptions.fileOrDirectory.isEmpty else {
            throw ValidationError("Path(s) to a string catalog or directory must be provided")
        }

        guard !languages.isEmpty else {
            throw ValidationError("Languages to lint need to be provided")
        }
        if catalogOptions.overwriteExisting && !markFailingNeedsReview {
            throw ValidationError("Pass --mark-failing-needs-review if you want to update the String Catalog(s).")
        }

        let linter = StringCatalogLinter(verbose: verbose)

        var numberOfPassed = 0
        var numberOfFailed = 0
        for fileOrDirectory in catalogOptions.fileOrDirectory {
            let fileFinder = TranslatableFileFinder(
                fileOrDirectoryURL: URL(fileURLWithPath: fileOrDirectory),
                type: .stringCatalog
            )
            let translatableFiles = try fileFinder.findTranslatableFiles()

            for fileURL in translatableFiles {
                Log.info(newline: .before, "Loading catalog \(fileURL.path)")
                let catalog = try StringCatalog(url: fileURL)

                let languagesToLint: Set<Language>
                if languages.map(\.rawValue).contains("all") {
                    languagesToLint = catalog.targetLanguages
                } else {
                    languagesToLint = Set(languages)
                }

                let (failed, passed) = linter.lint(catalog, languages: languagesToLint)
                numberOfFailed += failed
                numberOfPassed += passed

                if markFailingNeedsReview {
                    var targetURL = fileURL
                    if !catalogOptions.overwriteExisting {
                        targetURL = targetURL.deletingPathExtension().appendingPathExtension("loc.xcstrings")
                    }
                    try catalog.write(to: targetURL)
                }
            }
        }

        if numberOfFailed > 0 {
            Log.info("Done: \(numberOfFailed) strings failed, \(numberOfPassed) strings passed.")
        } else {
            Log.info("Done: All \(numberOfPassed) strings passed.")
        }
    }

}
