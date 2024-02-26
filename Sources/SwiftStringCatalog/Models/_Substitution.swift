//
//  Copyright © 2024 Hidden Spectrum, LLC.
//

import Foundation


struct _Substitution: Codable {
    let argNum: Int
    let formatSpecifier: String
    var variations: _Variations?
}


extension _Substitution: LocalizableStringConstructor {
    func constructLocalizableStrings(context: LocalizableStringConstructionContext, targetLanguage: Language) throws -> [LocalizableString] {
        if let variations {
            let localizableStrings = try variations.constructLocalizableStrings(context: context, targetLanguage: targetLanguage)
            localizableStrings.forEach {
                $0.convertKindToSubstitution(argNum: argNum, formatSpecifier: formatSpecifier)
            }
            return localizableStrings
        } else {
            return []
        }
    }
    
    mutating func addVariations(from localizedString: LocalizableString) {
        if variations == nil {
            variations = _Variations()
        }
        variations?.addVariation(from: localizedString)
    }
}
