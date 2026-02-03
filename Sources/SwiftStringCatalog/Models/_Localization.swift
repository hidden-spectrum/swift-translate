//
//  Copyright © 2024 Hidden Spectrum, LLC.
//

import Foundation


struct _Localization: Codable {
    
    // MARK: Internal
    
    var stringUnit: _StringUnit?
    var stringSet: _StringSet?
    var substitutions: [String: _Substitution]?
    var variations: _Variations?
}

extension _Localization: LocalizableStringConstructor {
    func constructLocalizableStrings(with context: LocalizableStringConstructionContext) throws -> [LocalizableString] {
        if let stringUnit {
            var localizableStrings = [
                LocalizableString(
                    kind: .standalone,
                    sourceKey: try context.embeddedSourceKey(matching: .standalone, or: stringUnit.value),
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
        } else if let stringSet {
            return try stringSet.constructLocalizableStrings(with: context)
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
    
    mutating func addStringSetValue(from localizedString: LocalizableString) {
        guard case .stringSet(let index) = localizedString.kind else {
            return
        }
        guard let translatedValue = localizedString.translatedValue else {
            return
        }
        if stringSet == nil {
            stringSet = _StringSet(state: localizedString.state, values: [])
        }
        stringSet?.addValue(translatedValue, at: index, state: localizedString.state)
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
    
    func embeddedSourceKey(matching kind: LocalizableString.Kind, or givenSourceKey: String) throws -> String {
        if isSource {
            return givenSourceKey
        } else {
            return try sourceLanguageStrings.sourceKeyLookup(matchingKind: kind)
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
