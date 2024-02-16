//
//  Copyright © 2024 Hidden Spectrum, LLC.
//

import Foundation
import SwiftStringCatalog


public protocol Translator {
    func translate(_ string: String, to targetLanguage: Language) async throws -> String
}


public extension Translator {
    func translateStringCatalog(_ catalog: StringCatalog, to targetLanguages: [Language]) async throws {
        
    }
}
