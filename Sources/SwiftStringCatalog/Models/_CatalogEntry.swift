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

extension _CatalogEntry {
    init(from localizableStrings: [LocalizableString]) throws {
        var localizations = CodableKeyDictionary<Language, _Localization>()
        for localizableString in localizableStrings {
            let language = localizableString.targetLanguage
            let localization = try _Localization(from: localizableString)
            localizations[language] = localization
        }
        self.init(extractionState: .extractedWithValue, localizations: localizations)
    }
}
