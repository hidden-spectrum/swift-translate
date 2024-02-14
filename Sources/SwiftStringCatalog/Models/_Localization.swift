//
//  Copyright © 2024 Hidden Spectrum, LLC.
//

import Foundation


struct _Localization: Codable {
    
    // MARK: Internal
    
    var stringUnit: _StringUnit?
    var substitutions: [StringLiteralType: _Substitution]?
    var variations: _Variations?
}
