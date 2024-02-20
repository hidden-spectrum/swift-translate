//
//  Copyright © 2024 Hidden Spectrum, LLC.
//

import Foundation
import SwiftStringCatalog


public protocol Translator {
    func translate(_ string: String, to targetLanguage: Language, comment: String?) async throws -> String
}
