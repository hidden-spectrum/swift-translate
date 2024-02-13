//
//  Copyright © 2024 Hidden Spectrum, LLC.
//

import Foundation
import os.log


struct CatalogEntry: Codable {

    // MARK: Internal
    
    let comment: String?
    let extractionState: ExtractionState?
    
    var localizations: TypedCodableDictionary<Language, Localization>
}
