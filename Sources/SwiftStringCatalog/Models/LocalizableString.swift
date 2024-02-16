//
//  Copyright © 2024 Hidden Spectrum, LLC.
//

import Foundation


public final class LocalizableString {
    
    // MARK: Public
    
    public let kind: Kind
    public let sourceKey: String
    public let targetLanguage: Language
    
    // MARK: Public private(set)
    
    public private(set) var comment: String?
    public private(set) var translatedValue: String?
    public private(set) var state: TranslationState
    
    // MARK: Lifecycle
    
    init(
        kind: Kind,
        sourceKey: String,
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
    
    public func setTranslation(_ translation: String) {
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

extension LocalizableString: Equatable {
    public static func == (lhs: LocalizableString, rhs: LocalizableString) -> Bool {
        return lhs.kind == rhs.kind
            && lhs.sourceKey == rhs.sourceKey
            && lhs.targetLanguage == rhs.targetLanguage
            && lhs.comment == rhs.comment
            && lhs.translatedValue == rhs.translatedValue
            && lhs.state == rhs.state
    }
}
