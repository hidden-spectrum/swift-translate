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
            return [
                LocalizableString(
                    kind: .standalone,
                    sourceKey: try context.embeddedSourceKey(matching: .standalone, or: stringUnit.value),
                    targetLanguage: targetLanguage,
                    translatedValue: stringUnit.value,
                    state: stringUnit.state
                )
            ]
        } else if substitutions != nil {
            throw StringCatalog.Error.substitionsNotYetSupported
        } else if let variations {
            return try variations.constructLocalizableStrings(context: context, targetLanguage: targetLanguage)
        } else {
            return []
        }
    }
}

extension _Localization {
    init(from localizableString: LocalizableString) throws {
        switch localizableString.kind {
        case .standalone:
            self.stringUnit = _StringUnit(state: localizableString.state, value: localizableString.translatedValue ?? "TODO")
        case .replacement:
            throw StringCatalog.Error.substitionsNotYetSupported
        case .variation:
            throw StringCatalog.Error.variationsNotYetSupported
        }
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
