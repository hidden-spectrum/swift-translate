//
//  Copyright © 2024 Hidden Spectrum, LLC.
//

import Foundation


protocol LocalizableStringConstructor {
    func constructLocalizableStrings(context: LocalizableStringConstructionContext, targetLanguage: Language) throws -> [LocalizableString]
}

protocol LocalizableStringCodable {
    init(localizableString: LocalizableString) throws
}
