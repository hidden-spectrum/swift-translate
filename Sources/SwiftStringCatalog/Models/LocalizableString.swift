//
//  Copyright © 2024 Hidden Spectrum, LLC.
//

import Foundation


public final class LocalizableString {
    
    // MARK: Public
    
    public let sourceKey: String
    public let targetLanguage: Language
    
    // MARK: Public private(set)
    
    public private(set) var kind: Kind
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
        self.translatedValue = translatedValue
        self.state = state
        self.kind = kind
    }
    
    // MARK: Translation
    
    public func setTranslation(_ translation: String) {
        translatedValue = translation
        state = .translated
    }

    public func setTranslated() {
        state = .translated
    }

    public func setNeedsReview() {
        state = .needsReview
    }

    // MARK: Utility
    
    func convertKindToSubstitution(argNum: Int, formatSpecifier: String) {
        guard case .variation(let variationKind) = kind else {
            return
        }
        kind = .replacement(
            Replacement(
                argNumber: argNum,
                formatSpecifier: formatSpecifier,
                variation: variationKind
            )
        )
    }
    
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
        case replacement(Replacement)
        case variation(Variation)
    }
    
    enum Variation: Equatable {
        case device(DeviceCategory)
        case plural(PluralQualifier)
    }
    
    struct Replacement: Equatable {
        let argNumber: Int
        let formatSpecifier: String
        let variation: Variation?
    }
}

extension LocalizableString: Equatable {
    public static func == (lhs: LocalizableString, rhs: LocalizableString) -> Bool {
        return lhs.kind == rhs.kind
            && lhs.sourceKey == rhs.sourceKey
            && lhs.targetLanguage == rhs.targetLanguage
            && lhs.translatedValue == rhs.translatedValue
            && lhs.state == rhs.state
    }
}
