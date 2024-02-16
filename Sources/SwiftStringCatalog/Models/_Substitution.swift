//
//  Copyright © 2024 Hidden Spectrum, LLC.
//

import Foundation


struct _Substitution: Codable {
    let argNum: Int
    let formatSpecifier: String
    let variations: _Variations?
}
