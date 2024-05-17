//
//  LanguageOptions.swift
//
//
//  Created by Jonas Bromö on 2024-05-17.
//

import Foundation
import ArgumentParser
import SwiftStringCatalog

// TODO: Consider refactoring this to not misuse the Language type with "__in_catalog" and "all", e.g. the LanguagesOption enum.
func getTargetLanguages(from languages: [Language]) throws -> Set<Language>? {
    if languages.first?.rawValue == "__in_catalog" {
        return nil
    } else if languages.first?.rawValue == "all" {
        return Set(Language.allCommon)
    } else {
        let invalidLanguages: [Language]
        if #available(macOS 13, *) {
            invalidLanguages = languages.filter { language in
                Locale.Language(identifier: language.code).languageCode?.isISOLanguage != true
            }
        } else {
            // This is not really a good check validation check as there's a lot more valid languages than allCommon.
            invalidLanguages = languages.filter({ !Language.allCommon.contains($0) })
        }
        guard invalidLanguages.isEmpty else {
            throw ValidationError("Invalid language(s) provided: \(invalidLanguages.map(\.rawValue).joined(separator: ", "))")
        }

        var languages = languages
        if !languages.contains(.english) {
            languages.append(.english)
        }
        return Set(languages)
    }
}
