//
//  Copyright © 2024 Hidden Spectrum, LLC.
//

import Foundation


struct StringUnit: Codable {

    // MARK: Public
    
    enum State: String, Codable {
        case new
        case needsReview = "needs_review"
        case stale
        case translated
    }
    
    var state: State
    var value: String
}
