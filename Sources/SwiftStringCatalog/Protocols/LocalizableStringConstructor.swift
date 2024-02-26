//
//  Copyright © 2024 Hidden Spectrum, LLC.
//

import Foundation


protocol LocalizableStringConstructor {
    func constructLocalizableStrings(with context: LocalizableStringConstructionContext) throws -> [LocalizableString]
}
