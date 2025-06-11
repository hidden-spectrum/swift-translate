//
//  Copyright © 2024 Hidden Spectrum, LLC.
//

import Foundation
import os.log


struct _CatalogEntry: Codable {
    
    // MARK: Internal
    
    let comment: String?
    let extractionState: ExtractionState?
    let shouldTranslate: Bool?
    
    var localizations: CodableKeyDictionary<Language, _Localization>?
    
    // MARK: Lifecycle
    
    init(
        comment: String?,
        extractionState: ExtractionState?,
        shouldTranslate: Bool?,
        localizations: CodableKeyDictionary<Language, _Localization>?
    ) {
        self.comment = comment
        self.extractionState = extractionState
        self.shouldTranslate = shouldTranslate
        self.localizations = localizations
    }
}

extension _CatalogEntry {
    init(from stringsGroup: LocalizableStringGroup) throws {
        var localizations = CodableKeyDictionary<Language, _Localization>()
        for localizableString in stringsGroup.strings {
            guard let translatedValue = localizableString.translatedValue else {
                continue
            }
            
            let language = localizableString.targetLanguage
            var localization =  localizations[language] ?? _Localization()
            
            defer {
                localizations[language] = localization
            }
            
            switch localizableString.kind {
            case .standalone:
                localization.stringUnit = _StringUnit(state: localizableString.state, value: translatedValue)
                continue
            case .replacement:
                localization.addSubstitution(from: localizableString)
            case .variation:
                localization.addVariations(from: localizableString)
            }
            
        }
        self.init(
            comment: stringsGroup.comment,
            extractionState: stringsGroup.extractionState,
            shouldTranslate: stringsGroup.shouldTranslate,
            localizations: localizations.values.isEmpty ? nil : localizations
        )
    }
}
