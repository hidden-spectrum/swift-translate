//
//  Copyright © 2024 Hidden Spectrum, LLC.
//

import Foundation


struct _Variation: Codable {
    let stringUnit: _StringUnit
    
    enum Error: Swift.Error {
        case translatedValueMissing
    }
    
    init?(state: TranslationState, translatedValue: String?) {
        guard let translatedValue else {
            return nil
        }
        self.stringUnit = _StringUnit(state: state, value: translatedValue)
    }
}

struct _Variations: Codable {
    var device: CodableKeyDictionary<DeviceCategory, _Variation>?
    var plural: CodableKeyDictionary<PluralQualifier, _Variation>?
}

extension _Variations: LocalizableStringConstructor {
    func constructLocalizableStrings(with context: LocalizableStringConstructionContext) throws -> [LocalizableString] {
        if let deviceVariations = device {
            return try deviceVariations.map { deviceCategory, variation in
                let kind = context.constructKind(variation: .device(deviceCategory))
                let stringUnit = variation.stringUnit
                return LocalizableString(
                    kind: kind,
                    sourceKey: try context.embeddedSourceKey(matching: kind, or: stringUnit.value),
                    targetLanguage: context.targetLanguage,
                    translatedValue: variation.stringUnit.value,
                    state: stringUnit.state
                )
            }
        } else if let pluralVariations = plural {
            return pluralVariations.compactMap { qualifier, variation in
                let kind = context.constructKind(variation: .plural(qualifier))
                let stringUnit = variation.stringUnit
                guard let sourceKey = try? context.embeddedSourceKey(matching: kind, or: stringUnit.value) else {
                    return nil
                }
                return LocalizableString(
                    kind: kind,
                    sourceKey: sourceKey,
                    targetLanguage: context.targetLanguage,
                    translatedValue: variation.stringUnit.value,
                    state: variation.stringUnit.state
                )
            }
        } else {
            return []
        }
    }
    
    mutating func addVariation(from localizedString: LocalizableString) {
        var unpackedVariation: LocalizableString.Variation
        
        if case .variation(let variation) = localizedString.kind {
            unpackedVariation = variation
        } else if case .replacement(let replacement) = localizedString.kind, let variation = replacement.variation {
            unpackedVariation = variation
        } else {
            return
        }
        
        switch unpackedVariation {
        case .device(let category):
            if device == nil {
                device = CodableKeyDictionary()
            }
            device?[category] = _Variation(state: localizedString.state, translatedValue: localizedString.translatedValue)
        case .plural(let qualifier):
            if plural == nil {
                plural = CodableKeyDictionary()
            }
            plural?[qualifier] = _Variation(state: localizedString.state, translatedValue: localizedString.translatedValue)
        }
    }
}
