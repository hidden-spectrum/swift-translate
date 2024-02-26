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
    func constructLocalizableStrings(with context: LocalizableStringConstructionContext) throws -> [LocalizableString] {
        if let variations {
            context.replacement = .init(argNumber: argNum, formatSpecifier: formatSpecifier, variation: nil)
            return try variations.constructLocalizableStrings(with: context)
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
