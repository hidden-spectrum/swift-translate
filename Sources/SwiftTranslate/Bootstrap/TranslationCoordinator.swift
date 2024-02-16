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
        case stringCatalog(URL, Set<Language>?)
        case text(String, Set<Language>)
    }

    let mode: Mode
    let translator: Translator

    // MARK: Lifecycle

    init(mode: Mode, translator: Translator) {
        self.mode = mode
        self.translator = translator
    }
    
    // MARK: Translation
    
    func translate() async throws {
        let startDate = Date()
        switch mode {
        case .stringCatalog(let catalog, let targetLanguages):
            try await translateStringCatalog(catalog, to: targetLanguages)
        case .text(let string, let targetLanguages):
            try await translate(string, to: targetLanguages)
        }
        print("\n✅ Done (\(startDate.timeIntervalSinceNow * -1) seconds)".green, "\n")
    }
    
    func translate(_ string: String, to targetLanguages: Set<Language>) async throws {
        print("\nTranslating `\(string)`:")
        for language in targetLanguages {
            let translation = try await translator.translate(string, to: language)
            logTranslationResult(to: language, result: translation, isSource: false)
        }
    }
        
    func translateStringCatalog(_ catalogUrl: URL, to targetLanguages: Set<Language>?) async throws {
        let catalog = try loadStringCatalog(from: catalogUrl, configureWith: targetLanguages)
        try verifyLargeTranslation(of: catalog.allKeys.count, to: catalog.targetLanguages.count)
        
        for key in catalog.allKeys {
            try await translate(key: key, in: catalog)
        }
        
        let newUrl = catalogUrl.deletingPathExtension().appendingPathExtension("loc.xcstrings")
        try catalog.write(to: newUrl)
    }
    
    // MARK: Input
    
    private func verifyLargeTranslation(of stringsCount: Int, to languageCount: Int) throws {
        guard stringsCount * languageCount > 200 else {
            return
        }
        print("\n?".yellow, "Are you sure you wish to translate \(stringsCount) keys into \(languageCount) languages? Y/n")
        let yesNo = readLine()
        guard yesNo == "Y" else {
            print("Translation canceled 🫡".yellow)
            exit(0)
        }
    }
    
    // MARK: String Catalog
    
    private func loadStringCatalog(from url: URL, configureWith targetLanguages: Set<Language>?) throws -> StringCatalog {
        print("\nLoading catalog \(url.lastPathComponent) into memory...")
        let catalog = try StringCatalog(url: url, configureWith: targetLanguages)
        print("✅ Done".green, "(Found \(catalog.allKeys.count) keys targeting \(catalog.targetLanguages.count) languages for a total of \(catalog.localizableStringsCount) localized strings)")
        return catalog
    }
    
    private func translate(key: String, in catalog: StringCatalog) async throws {
        print("\nTranslating key `\(key.truncatedRemovingNewlines(to: 64))`:")
        let localizableStrings = catalog.localizableStrings(for: key)
        
        for localizableString in localizableStrings {
            let isSource = catalog.sourceLanguage == localizableString.targetLanguage
            let targetLanguage = localizableString.targetLanguage
            
            if localizableString.state == .translated {
                let result = isSource ? localizableString.sourceKey : "[Already translated]".dim
                logTranslationResult(to: targetLanguage, result: result, isSource: isSource)
                continue
            }
            do {
                let translatedString = try await translator.translate(localizableString.sourceKey, to: targetLanguage)
                localizableString.setTranslation(translatedString)
                logTranslationResult(to: targetLanguage, result: translatedString.truncatedRemovingNewlines(to: 64), isSource: isSource)
            } catch {
                logTranslationResult(to: targetLanguage, result: "[Error: \(error.localizedDescription)]".red, isSource: isSource)
            }
        }
    }
    
    // MARK: Utilities
    
    private func logTranslationResult(to language: Language, result: String, isSource: Bool) {
        let languageCode = (language.rawValue + ":" as NSString).utf8String!
        let logString = String(format: "- %-8s %@", languageCode, result)
        print(isSource ? logString.dim : logString)
    }
}
