//
//  RemoveLanguagesCommand.swift
//
//
//  Created by Jonas Bromö on 2024-05-24.
//

import ArgumentParser
import Foundation
import SwiftStringCatalog

struct RemoveLanguagesCommand: ParsableCommand {

    static var configuration = CommandConfiguration(
        commandName: "remove",
        abstract: "Remove languages from String Catalog(s)."
    )

    // MARK: Command Line Options

    @OptionGroup(
        title: "Translate string catalogs"
    )
    private var catalogOptions: CatalogTranslationOptions

    @Option(
        name: [.customLong("lang"), .short],
        parsing: .upToNextOption,
        help: "The language(s) to remove. Or `all` for all languages in the String Catalog(s)",
        completion: .list(Language.allCommon.map(\.rawValue))
    )
    private var languages: [Language] = []

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
            throw ValidationError("Languages to delete need to be provided")
        }

        for fileOrDirectory in catalogOptions.fileOrDirectory {
            let fileFinder = TranslatableFileFinder(
                fileOrDirectoryURL: URL(fileURLWithPath: fileOrDirectory),
                type: .stringCatalog
            )
            let translatableFiles = try fileFinder.findTranslatableFiles()

            for fileURL in translatableFiles {
                Log.info(newline: .before, "Loading catalog \(fileURL.path)")
                let catalog = try StringCatalog(url: fileURL)

                let languagesToRemove: Set<Language>
                if languages.map(\.rawValue).contains("all") {
                    languagesToRemove = catalog.targetLanguages
                } else {
                    languagesToRemove = Set(languages)
                }
                let languagesToRemoveString = languagesToRemove.map(\.rawValue).joined(separator: ", ")

                print("\n?".yellow, "Do you want to remove the languages \"\(languagesToRemoveString)\"? y/N")
                let yesNo = readLine()
                guard yesNo?.lowercased() == "y" else {
                    continue
                }

                let removedLanguages = catalog.removeLanguages(languagesToRemove)
                let removedLanguagesString = removedLanguages.map(\.rawValue).joined(separator: ", ")

                if removedLanguages.isEmpty {
                    Log.info("The string catalog didn't contain any of the languages to remove.")
                } else {
                    var targetURL = fileURL
                    if !catalogOptions.overwriteExisting {
                        targetURL = targetURL.deletingPathExtension().appendingPathExtension("loc.xcstrings")
                    }
                    try catalog.write(to: targetURL)

                    Log.info("Languages \"\(removedLanguagesString)\" successfully removed.")
                }
            }
        }

        Log.info("Done")
    }

}
