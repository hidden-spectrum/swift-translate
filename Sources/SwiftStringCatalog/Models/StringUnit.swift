//
//  Copyright © 2024 Hidden Spectrum, LLC.
//

import Foundation


struct Localization: Codable {
    var stringUnit: StringUnit?
    var variations: Variations?
}


struct Variations: Codable {
    var stringUnit: StringUnit?
    var plural: Plural?
}

struct Plural: Codable {
    let one: StringUnit?
    let other: StringUnit?
    let few: StringUnit?
    let many: StringUnit?
}


struct StringUnit: Codable {

    // MARK: Public
    
    enum State: String, Codable {
        case new
        case needsReview = "needs_review"
        case stale
        case translated
    }
    
    var state: State?
    var value: String?
}
