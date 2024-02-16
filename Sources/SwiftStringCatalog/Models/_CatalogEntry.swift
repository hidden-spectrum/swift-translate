//
//  Copyright © 2024 Hidden Spectrum, LLC.
//

import Foundation
import os.log


struct _CatalogEntry: Codable {
    
    // MARK: Internal
    
    let comment: String?
    let extractionState: ExtractionState?
    
    var localizations: CodableKeyDictionary<Language, _Localization>?
    
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
            guard let translatedValue = localizableString.translatedValue else {
                continue
            }
            
            let language = localizableString.targetLanguage
            var localization = _Localization()
            
            defer {
                localizations[language] = localization
            }
            
            switch localizableString.kind {
            case .standalone:
                localization.stringUnit = _StringUnit(state: localizableString.state, value: translatedValue)
                continue
            case .replacement:
                throw StringCatalog.Error.substitionsNotYetSupported
            case .variation:
                localization.addVariations(from: localizableString)
            }
        }
        self.init(extractionState: .extractedWithValue, localizations: localizations)
    }
}
