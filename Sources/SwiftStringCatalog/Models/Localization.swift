//
//  Copyright © 2024 Hidden Spectrum, LLC.
//

import Foundation


struct Localization: Codable {
    var stringUnit: StringUnit?
    var substitutions: [StringLiteralType: Substitution]?
    var variations: Variations?
}
