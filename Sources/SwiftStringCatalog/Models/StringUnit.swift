//
//  Copyright © 2024 Hidden Spectrum, LLC.
//

import Foundation


public struct StringUnitContainer: Codable {
    let stringUnit: StringUnit
}


public struct StringUnit: Codable {

    // MARK: Public
    
    public enum State: String, Codable {
        case translated
    }
    
    public let state: State
    public let value: String
}
