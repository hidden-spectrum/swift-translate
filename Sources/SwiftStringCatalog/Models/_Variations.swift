//
//  Copyright © 2024 Hidden Spectrum, LLC.
//

import Foundation


struct _Variation: Codable {
    let stringUnit: _StringUnit
}

struct _Variations: Codable {
    let device: CodableKeyDictionary<DeviceCategory, _Variation>?
    let plural: CodableKeyDictionary<PluralQualifier, _Variation>?
}

extension _Variations: LocalizableStringConstructor {
    func constructLocalizableStrings(context: LocalizableStringConstructionContext, targetLanguage: Language) throws -> [LocalizableString] {
        if let deviceVariations = device {
            return try deviceVariations.map { deviceCategory, variation in
                let kind = LocalizableString.Kind.variation(.device(deviceCategory))
                let stringUnit = variation.stringUnit
                return LocalizableString(
                    kind: kind,
                    sourceKey: try context.embeddedSourceKey(matching: kind, or: stringUnit.value),
                    targetLanguage: targetLanguage,
                    translatedValue: variation.stringUnit.value,
                    state: stringUnit.state
                )
            }
        } else if let pluralVariations = plural {
            return try pluralVariations.map { qualifier, variation in
                let kind = LocalizableString.Kind.variation(.plural(qualifier))
                let stringUnit = variation.stringUnit
                return LocalizableString(
                    kind: .variation(.plural(qualifier)),
                    sourceKey: try context.embeddedSourceKey(matching: kind, or: stringUnit.value),
                    targetLanguage: targetLanguage,
                    translatedValue: variation.stringUnit.value,
                    state: variation.stringUnit.state
                )
            }
        } else {
            return []
        }
    }
}
