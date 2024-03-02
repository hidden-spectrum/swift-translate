//
//  Copyright © 2024 Hidden Spectrum, LLC.
//

import Foundation


struct _StringCatalog: Codable {

    // MARK: Internal
    
    let sourceLanguage: Language
    let strings: [String: _CatalogEntry]
    let version: String
    
    // MARK: Lifecycle
    
    init(sourceLanguage: Language, strings: [String: _CatalogEntry]) {
        self.sourceLanguage = sourceLanguage
        self.strings = strings
        self.version = "1.0" // Only 1.0 supported
    }
}
