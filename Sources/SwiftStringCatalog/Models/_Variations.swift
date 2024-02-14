//
//  Copyright © 2024 Hidden Spectrum, LLC.
//

import Foundation


struct _Variation: Codable {
    let stringUnit: _StringUnit
}

struct _Variations: Codable {
    let device: CodableKeyDictionary<DeviceCategory, _Variation>?
    let plural: CodableKeyDictionary<PluralQualifier, _Variation>?
}





