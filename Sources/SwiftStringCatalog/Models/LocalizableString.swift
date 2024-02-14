//
//  Copyright © 2024 Hidden Spectrum, LLC.
//

import Foundation


public struct LocalizableString: Equatable {
    
    // MARK: Public
    
    public let kind: Kind
    public let sourceKey: StringLiteralType
    public let targetLanguage: Language
    
    // MARK: Public private(set)
    
    public private(set) var comment: String?
    public private(set) var translatedValue: String?
    public private(set) var state: TranslationState
    
    // MARK: Lifecycle
    
    init(
        kind: Kind,
        sourceKey: StringLiteralType,
        targetLanguage: Language,
        translatedValue: String?,
        state: TranslationState
    ) {
        self.sourceKey = sourceKey
        self.targetLanguage = targetLanguage
        self.comment = nil
        self.translatedValue = translatedValue
        self.state = state
        self.kind = kind
    }
    
    // MARK: Mutation
    
    public mutating func setTranslation(_ translation: StringLiteralType) {
        translatedValue = translation
        state = .translated
    }
    
    // MARK: Helpers
    
    func emptyCopy(for targetLanguage: Language) -> LocalizableString {
        return LocalizableString(
            kind: kind,
            sourceKey: sourceKey,
            targetLanguage: targetLanguage,
            translatedValue: nil,
            state: .new
        )
    }
}

public extension LocalizableString {
    enum Kind: Equatable {
        case standalone
        case replacement
        case variation(VariationKind)
    }
    
    enum VariationKind: Equatable {
        case device(DeviceCategory)
        case plural(PluralQualifier)
    }
}
