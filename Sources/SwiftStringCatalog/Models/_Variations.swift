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
            return deviceVariations.map { deviceCategory, variation in
                return LocalizableString(
                    kind: .variation(.device(deviceCategory)),
                    sourceKey: context.embeddedSourceKey(or: variation.stringUnit.value),
                    targetLanguage: targetLanguage,
                    translatedValue: variation.stringUnit.value,
                    state: variation.stringUnit.state
                )
            }
        } else if let pluralVariations = plural {
            return pluralVariations.map { qualifier, variation in
                return LocalizableString(
                    kind: .variation(.plural(qualifier)),
                    sourceKey: context.embeddedSourceKey(or: variation.stringUnit.value),
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
