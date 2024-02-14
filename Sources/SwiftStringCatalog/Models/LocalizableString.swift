//
//  Copyright © 2024 Hidden Spectrum, LLC.
//

import Foundation


public struct LocalizableString {
    
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
    
    mutating func setTranslation(_ translation: StringLiteralType) {
        translatedValue = translation
        state = .translated
    }
}

public extension LocalizableString {
    enum Kind {
        case standalone
        case replacement
        case variation(VariationKind)
    }
    
    enum VariationKind: CustomDebugStringConvertible {
        case device(DeviceCategory)
        case plural(PluralQualifier)
        
        public var debugDescription: String {
            switch self {
            case .device(let deviceCategory):
                return ".device(.\(deviceCategory))"
            case .plural(let pluralQualifier):
                return ".plural(.\(pluralQualifier))"
            }
        }
    }
}

extension LocalizableString: CustomDebugStringConvertible {
    public var debugDescription: String {
        return
            """
            LocalizableString(
                kind: .\(kind),
                sourceKey: `\(sourceKey)`,
                targetLanguage: \(targetLanguage.rawValue),
                comment: \(comment ?? "nil"),
                translatedValue: `\(translatedValue ?? "nil")`,
                state: ..\(state)
            )
            """
    }
}
