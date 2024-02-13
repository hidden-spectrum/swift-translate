//
//  Copyright © 2024 Hidden Spectrum, LLC.
//

import Foundation
import os.log


struct Translations: Codable {

    // MARK: Internal
    
    let extractionState: ExtractionState?
    
    var localizations: [StringLiteralType: Localization]
}
