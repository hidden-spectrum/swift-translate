//
//  Copyright © 2024 Hidden Spectrum, LLC.
//

import Foundation


public struct LocalizableStringGroup {

    // MARK: Public
    
    public let comment: String?
    public let extractionState: ExtractionState?
    public let strings: [LocalizableString]
    
    // MARK: Lifecycle

    init(
        comment: String?,
        extractionState: ExtractionState?,
        strings: [LocalizableString]
    ) {
        self.comment = comment
        self.extractionState = extractionState
        self.strings = strings
    }

    // MARK: Getters

    public func string(for language: Language) -> LocalizableString? {
        strings.first(where: { $0.targetLanguage == language })
    }

}
