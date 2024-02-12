//
//  Copyright © 2024 Hidden Spectrum, LLC.
//

import Foundation


struct StringUnitContainer: Codable {
    var stringUnit: StringUnit
}


struct StringUnit: Codable {

    // MARK: Public
    
    enum State: String, Codable {
        case new
        case stale
        case translated
    }
    
    var state: State
    var value: String
}
