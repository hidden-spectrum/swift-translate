//
//  Copyright © 2024 Hidden Spectrum, LLC.
//

import Foundation


public struct LocalizableString {
    
    // MARK: Public
    
    public let key: String
    public let kind: Kind
    public let comment: String?
    
    // MARK: Public private(set)
    
    public private(set) var translation: String?
    public private(set) var state: TranslationState
    
    // MARK: Lifecycle
    
    mutating func setTranslation(_ translation: StringLiteralType) {
        self.translation = translation
        self.state = .translated
    }
}

public extension LocalizableString {
    enum Kind {
        case standalone
        case replacement
        case variation(VariationKind)
    }
    
    enum VariationKind {
        case device(DeviceCategory)
        case plural(PluralQualifier)
    }
}
