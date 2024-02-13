//
//  Copyright © 2024 Hidden Spectrum, LLC.
//

import Foundation
import os.log


extension StringCatalog {
    
    struct Entry: Codable {
        
        // MARK: Internal
        
        let comment: String?
        let extractionState: ExtractionState?
        
        var localizations: TypedCodableDictionary<Language, Localization>
        
        // MARK: Lifecycle
        
        init(
            comment: String? = nil,
            extractionState: ExtractionState? = .manual,
            localizations: TypedCodableDictionary<Language, Localization>
        ) {
            self.comment = comment
            self.extractionState = extractionState
            self.localizations = localizations
        }
    }
}
