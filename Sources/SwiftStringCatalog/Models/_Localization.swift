//
//  Copyright © 2024 Hidden Spectrum, LLC.
//

import Foundation


struct _Localization: Codable {
    
    // MARK: Internal
    
    var stringUnit: _StringUnit?
    var substitutions: [String: _Substitution]?
    var variations: _Variations?
}

extension _Localization: LocalizableStringConstructor {
    func constructLocalizableStrings(context: LocalizableStringConstructionContext, targetLanguage: Language) throws -> [LocalizableString] {
        if let stringUnit {
            var localizableStrings = [
                LocalizableString(
                    kind: .standalone,
                    sourceKey: try context.embeddedSourceKey(matching: .standalone, or: stringUnit.value),
                    targetLanguage: targetLanguage,
                    translatedValue: stringUnit.value,
                    state: stringUnit.state
                )
            ]
            if let substitutions {
                localizableStrings += try substitutions.flatMap { key, substitution in
                    try substitution.constructLocalizableStrings(context: context, targetLanguage: targetLanguage)
                }
            }
            return localizableStrings
        } else if let variations {
            return try variations.constructLocalizableStrings(context: context, targetLanguage: targetLanguage)
        } else {
            return []
        }
    }
}

extension _Localization {
    mutating func addVariations(from localizedString: LocalizableString) {
        if variations == nil {
            variations = _Variations()
        }
        variations?.addVariation(from: localizedString)
    }
    
    mutating func addSubstitution(from localizedString: LocalizableString) {
        guard case .replacement(let replacement) = localizedString.kind else {
            return
        }
        if substitutions == nil {
            substitutions = [:]
        }
        var substitution = substitutions?[localizedString.sourceKey]
            ?? _Substitution(
                argNum: replacement.argNumber,
                formatSpecifier: replacement.formatSpecifier,
                variations: _Variations()
            )
        substitution.variations?.addVariation(from: localizedString)
        substitutions?["arg\(replacement.argNumber)"] = substitution
    }
}


enum LocalizableStringConstructionContext {
    case isSource
    case needTranslationFromKeyIn(sourceLanguageStrings: [LocalizableString])
    
    func embeddedSourceKey(matching kind: LocalizableString.Kind, or givenSourceKey: String) throws -> String {
        switch self {
        case .isSource:
            return givenSourceKey
        case .needTranslationFromKeyIn(let sourceLanguageStrings):
            return try sourceLanguageStrings.sourceKeyLookup(matchingKind: kind)
        }
    }
}
