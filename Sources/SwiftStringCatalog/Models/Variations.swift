//
//  Copyright © 2024 Hidden Spectrum, LLC.
//

import Foundation


struct Variation: Codable {
    let stringUnit: StringUnit
}

struct Variations: Codable {
    let device: TypedCodableDictionary<Device, Variation>?
    let plural: TypedCodableDictionary<Plural, Variation>?
}

extension Variations {
    enum Device: String, Codable {
        case iPad = "ipad"
        case iPhone = "iphone"
        case iPod = "ipod"
        case mac = "mac"
        case other = "other"
        case tv = "appletv"
        case vision = "applevision"
        case watch = "applewatch"
    }
    
    enum Plural: String, Codable {
        case zero
        case one
        case two
        case few
        case many
        case other
    }
}
