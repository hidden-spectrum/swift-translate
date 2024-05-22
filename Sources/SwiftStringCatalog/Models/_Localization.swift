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
    func constructLocalizableStrings(with context: LocalizableStringConstructionContext) throws -> [LocalizableString] {
        if let stringUnit {
            var localizableStrings = [
                LocalizableString(
                    kind: .standalone,
                    sourceValue: try context.embeddedSourceValue(matching: .standalone, or: stringUnit.value),
                    targetLanguage: context.targetLanguage,
                    translatedValue: stringUnit.value,
                    state: stringUnit.state
                )
            ]
            if let substitutions {
                localizableStrings += try substitutions.flatMap { key, substitution in
                    try substitution.constructLocalizableStrings(with: context)
                }
            }
            return localizableStrings
        } else if let variations {
            return try variations.constructLocalizableStrings(with: context)
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
        let substitutionKey = "arg\(replacement.argNumber)"
        var substitution = substitutions?[substitutionKey]
            ?? _Substitution(
                argNum: replacement.argNumber,
                formatSpecifier: replacement.formatSpecifier,
                variations: _Variations()
            )
        substitution.variations?.addVariation(from: localizedString)
        substitutions?[substitutionKey] = substitution
    }
}


final class LocalizableStringConstructionContext {
    
    // MARK: Internal
    
    let isSource: Bool
    let sourceLanguageStrings: [LocalizableString]
    let targetLanguage: Language
    
    var replacement: LocalizableString.Replacement?
    
    // MARK: Lifecycle
    
    static func sourceLanguageContext(sourceLanguage: Language) -> Self {
        return .init(
            isSource: true,
            targetLanguage: sourceLanguage,
            sourceLanguageStrings: []
        )
    }
    
    static func targetLanguageContext(
        targetLanguage: Language,
        sourceLanguageStrings: [LocalizableString]
    ) -> Self {
        return .init(
            isSource: false,
            targetLanguage: targetLanguage,
            sourceLanguageStrings: sourceLanguageStrings
        )
    }
    
    private init(isSource: Bool, targetLanguage: Language, sourceLanguageStrings: [LocalizableString]) {
        self.isSource = isSource
        self.targetLanguage = targetLanguage
        self.sourceLanguageStrings = sourceLanguageStrings
    }
    
    func embeddedSourceValue(matching kind: LocalizableString.Kind, or stringValue: String) throws -> String {
        if isSource {
            return stringValue
        } else {
            return try sourceLanguageStrings.sourceValueLookup(matchingKind: kind)
        }
    }
    
    func constructKind(variation: LocalizableString.Variation) -> LocalizableString.Kind {
        if let replacement = replacement {
            let updatedReplacement = LocalizableString.Replacement(
                argNumber: replacement.argNumber,
                formatSpecifier: replacement.formatSpecifier,
                variation: variation
            )
            return .replacement(updatedReplacement)
        } else {
            return .variation(variation)
        }
    }
}
