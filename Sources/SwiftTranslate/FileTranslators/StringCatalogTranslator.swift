//
//  Copyright © 2024 Hidden Spectrum, LLC.
//

import Foundation
import SwiftStringCatalog


struct StringCatalogTranslator: FileTranslator {
    
    // MARK: Internal
    
    let overwrite: Bool
    let skipConfirmations: Bool
    let targetLanguages: Set<Language>?
    let service: TranslationService
    let verbose: Bool
    
    // MARK: Lifecycle
    
    init(with translator: TranslationService, targetLanguages: Set<Language>?, overwrite: Bool, skipConfirmations: Bool, verbose: Bool) {
        self.skipConfirmations = skipConfirmations
        self.overwrite = overwrite
        self.targetLanguages = targetLanguages
        self.service = translator
        self.verbose = verbose
    }
    
    func translate(fileAt fileUrl: URL) async throws {
        let catalog = try loadStringCatalog(from: fileUrl)
        
        if !skipConfirmations {
            verifyLargeTranslation(of: catalog.allKeys.count, to: catalog.targetLanguages.count)
        }
        
        for key in catalog.allKeys {
            try await translate(key: key, in: catalog)
        }
        
        var targetUrl = fileUrl
        if !overwrite {
            targetUrl = targetUrl.deletingPathExtension().appendingPathExtension("loc.xcstrings")
        }
        try catalog.write(to: targetUrl)
    }
    
    private func loadStringCatalog(from url: URL) throws -> StringCatalog {
        Log.info(newline: true, "Loading catalog \(url.lastPathComponent) into memory...")
        let catalog = try StringCatalog(url: url, configureWith: targetLanguages)
        Log.info("Done (Found \(catalog.allKeys.count) keys targeting \(catalog.targetLanguages.count) languages for a total of \(catalog.localizableStringsCount) localizable strings)")
        return catalog
    }
    
    private func translate(key: String, in catalog: StringCatalog) async throws {
        Log.info(newline: verbose, "Translating key `\(key.truncatedRemovingNewlines(to: 64))`")        
        let localizableStrings = catalog.localizableStrings(for: key)
        
        for localizableString in localizableStrings {
            let isSource = catalog.sourceLanguage == localizableString.targetLanguage
            let targetLanguage = localizableString.targetLanguage
            
            if localizableString.state == .translated || isSource {
                if verbose {
                    let result = isSource ? localizableString.sourceKey : "[Already translated]"
                    logTranslationResult(to: targetLanguage, result: result, isSource: isSource)
                }
                continue
            }
            do {
                let translatedString = try await service.translate(localizableString.sourceKey, to: targetLanguage, comment: localizableString.comment)
                localizableString.setTranslation(translatedString)
                if verbose {
                    logTranslationResult(to: targetLanguage, result: translatedString.truncatedRemovingNewlines(to: 64), isSource: isSource)
                }
            } catch {
                logTranslationResult(to: targetLanguage, result: "[Error: \(error.localizedDescription)]".red, isSource: isSource)
            }
        }
    }
    
    // MARK: Utilities
    
    private func verifyLargeTranslation(of stringsCount: Int, to languageCount: Int) {
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
    
    private func logTranslationResult(to language: Language, result: String, isSource: Bool) {
        Log.structured(
            level: isSource ? .info : .unimportant,
            .init(width: 8, language.rawValue + ":"),
            .init(result)
        )
    }
}
