//
//  Copyright © 2024 Hidden Spectrum, LLC.
//

import ArgumentParser
import Foundation
import Rainbow
import SwiftStringCatalog


struct TranslationCoordinator {
    
    // MARK: Internal
    
    enum Mode {
        case stringCatalog(URL)
        case text(String)
    }

    let mode: Mode
    let targetLanguages: [Language]
    let translator: Translator

    // MARK: Lifecycle

    init(mode: Mode, translator: Translator, targetLanguages: Set<Language>) {
        self.mode = mode
        self.translator = translator
        self.targetLanguages = Array(targetLanguages).sorted(by: { $0.rawValue < $1.rawValue })
    }
    
    // MARK: Translation
    
    func translate() async throws {
        let startDate = Date()
        switch mode {
        case .stringCatalog(let catalog):
            try await translateStringCatalog(catalog)
        case .text(let string):
            try await translate(string)
        }
        print("✅ Done (\(startDate.timeIntervalSinceNow * -1) seconds)".green)
    }
    
    func translate(_ string: String) async throws {
        print("Translating `\(string)`:")
        for language in targetLanguages {
            let translation = try await translator.translate(string, to: language)
            print(String(format: "- %-15s: %@", language.rawValue, translation))
        }
    }
        
    func translateStringCatalog(_ catalogUrl: URL) async throws {
        let catalog = try loadStringCatalog(from: catalogUrl)
        try verifyLargeTranslation(of: catalog.localizableStringsCount, to: targetLanguages.count)
        
        for key in catalog.allKeys {
            try await translate(key: key, in: catalog)
        }
    }
    
    // MARK: Input
    
    private func verifyLargeTranslation(of stringsCount: Int, to languageCount: Int) throws {
        guard stringsCount * languageCount < 200 else {
            return
        }
        print("➡".yellow, "Are you sure you wish to translate \(stringsCount) strings into \(languageCount) languages? Y/n")
        let yesNo = readLine()
        guard yesNo == "Y" else {
            throw ValidationError("🫡 Translation canceled".yellow)
        }
    }
    
    // MARK: String Catalog
    
    private func loadStringCatalog(from url: URL) throws -> StringCatalog {
        print("Loading catalog \(url.lastPathComponent) into memory...")
        let catalog = try StringCatalog(url: url)
        print("✅ Done".green, "(Found \(catalog.allKeys.count) keys with \(catalog.localizableStringsCount) localizable strings)")
        return catalog
    }
    
    private func translate(key: String, in catalog: StringCatalog) async throws {
        print("\nTranslating key `\(key.truncatedRemovingNewlines(to: 64))`:")
        let localizableStrings = catalog.localizableStrings(for: key)
        for localizableString in localizableStrings {
            let targetLanguage = localizableString.targetLanguage
            let languageCodePrintLn = String(format: "- %-15s: ", targetLanguage.rawValue)
            if localizableString.state == .translated {
                print(languageCodePrintLn, "[Already translated]".dim)
                continue
            }
            do {
                let translatedString = try await translator.translate(localizableString.sourceKey, to: targetLanguage)
                print(languageCodePrintLn, translatedString.truncatedRemovingNewlines(to: 64))
            } catch {
                print(languageCodePrintLn, "[Error: \(error.localizedDescription)]".red)
            }
        }
    }
}
