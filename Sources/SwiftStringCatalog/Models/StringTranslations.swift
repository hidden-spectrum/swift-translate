//
//  Copyright © 2024 Hidden Spectrum, LLC.
//

import Foundation
import os.log


struct StringTranslations: Codable {

    // MARK: Internal
    
    let extractionState: ExtractionState
    
    var localizations: [String: StringUnitContainer]
}
