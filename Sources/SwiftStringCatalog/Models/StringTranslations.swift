//
//  Copyright © 2024 Hidden Spectrum, LLC.
//

import Foundation
import os.log


public struct StringTranslations: Codable {
    
    // MARK: Public
    
    public let extractionState: ExtractionState
    
    // MARK: Internal
    
    let localizations: [String: StringUnitContainer]
    
    // MARK: Private
    
//    private let log = Logger(subsystem: "io.hiddenspectrum.swiftstringcatalog", category: "Localizations")
}
