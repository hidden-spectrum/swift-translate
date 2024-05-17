//
//  MarkNeedsReviewCommand.swift
//
//
//  Created by Jonas Bromö on 2024-05-17.
//

import ArgumentParser
import Foundation
import SwiftStringCatalog

struct MarkNeedsReviewCommand: ParsableCommand {

    static var configuration = CommandConfiguration(
        commandName: "mark-needs-review",
        abstract: "Mark translated strings as NEEDS REVIEW. E.g. if you want to review your translations using the review command."
    )

    // MARK: Command Line Options

    @OptionGroup(
        title: "Translate string catalogs"
    )
    private var catalogOptions: CatalogTranslationOptions

    @Option(
        name: [.customLong("lang"), .short],
        parsing: .upToNextOption,
        help: "The language(s) to mark. Or `all` for all languages in the String Catalog(s)",
        completion: .list(Language.allCommon.map(\.rawValue))
    )
    private var languages: [Language] = []

    func run() throws {

        guard !catalogOptions.fileOrDirectory.isEmpty else {
            throw ValidationError("Path(s) to a string catalog or directory must be provided")
        }

        var markedStringsCount = 0
        for fileOrDirectory in catalogOptions.fileOrDirectory {
            let fileFinder = TranslatableFileFinder(
                fileOrDirectoryURL: URL(fileURLWithPath: fileOrDirectory),
                type: .stringCatalog
            )
            let translatableFiles = try fileFinder.findTranslatableFiles()

            for fileURL in translatableFiles {
                let catalog = try StringCatalog(url: fileURL)
                Log.info(newline: .before, "Loading catalog \(fileURL.path) into memory...")
                if languages.map(\.rawValue).contains("all") {
                    let languagesString = catalog.targetLanguages.map(\.rawValue).joined(separator: ", ")
                    Log.info(newline: .before, "Marking all languages: \(languagesString)")
                    markedStringsCount += catalog.markNeedsReview(.allInStringCatalog)
                } else {
                    let languagesString = languages.map(\.rawValue).joined(separator: ", ")
                    Log.info(newline: .before, "Marking languages: \(languagesString)")
                    markedStringsCount += catalog.markNeedsReview(.languages(languages))
                }

                var targetURL = fileURL
                if !catalogOptions.overwriteExisting {
                    targetURL = targetURL.deletingPathExtension().appendingPathExtension("loc.xcstrings")
                }
                try catalog.write(to: targetURL)
            }
        }

        Log.info("Finished: Marked \(markedStringsCount) keys as NEEDS REVIEW")
    }

}
