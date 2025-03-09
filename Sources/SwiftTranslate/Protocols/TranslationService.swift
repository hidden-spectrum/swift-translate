//
//  Copyright © 2024 Hidden Spectrum, LLC.
//

import Foundation
import SwiftStringCatalog


public protocol TranslationService {
    func translate(_ string: String, to targetLanguage: Language, comment: String?, baseTranslation: String?) async throws -> String
}
