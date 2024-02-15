//
//  Copyright © 2024 Hidden Spectrum, LLC.
//

import Foundation


struct _StringCatalog: Codable {

    // MARK: Internal
    
    let sourceLanguage: Language
    let strings: [StringLiteralType: _CatalogEntry]
    let version: String
}
