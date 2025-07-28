//
//  Copyright © 2024 Hidden Spectrum, LLC.
//

import Foundation


public struct LocalizableStringGroup {

    // MARK: Public
    
    public let comment: String?
    public let extractionState: ExtractionState?
    public let generatesSymbol: Bool?
    public let shouldTranslate: Bool?
    public let strings: [LocalizableString]
    
    // MARK: Lifecycle

    init(
        comment: String?,
        extractionState: ExtractionState?,
        generatesSymbol: Bool?,
        shouldTranslate: Bool?,
        strings: [LocalizableString]
    ) {
        self.comment = comment
        self.extractionState = extractionState
        self.generatesSymbol = generatesSymbol
        self.shouldTranslate = shouldTranslate
        self.strings = strings
    }
}
