//
//  Copyright © 2024 Hidden Spectrum, LLC.
//

import Foundation


public struct LocalizableStringGroup {

    // MARK: Public
    
    public let extractionState: ExtractionState?
    public let strings: [LocalizableString]
    
    // MARK: Lifecycle

    init(
        extractionState: ExtractionState?,
        strings: [LocalizableString]
    ) {
        self.extractionState = extractionState
        self.strings = strings
    }
}
