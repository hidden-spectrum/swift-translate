//
//  Copyright © 2024 Hidden Spectrum, LLC.
//

import Foundation
import os.log


struct _CatalogEntry: Codable {
    
    // MARK: Internal
    
    let comment: String?
    let extractionState: ExtractionState?
    
    var localizations: CodableKeyDictionary<Language, _Localization>
    
    // MARK: Lifecycle
    
    init(
        comment: String? = nil,
        extractionState: ExtractionState? = .manual,
        localizations: CodableKeyDictionary<Language, _Localization>
    ) {
        self.comment = comment
        self.extractionState = extractionState
        self.localizations = localizations
    }
}
