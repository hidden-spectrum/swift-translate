//
//  Copyright © 2024 Hidden Spectrum, LLC.
//

import Foundation


struct Substitution: Codable {
    let argNum: Int
    let formatSpecifier: String
    let variations: Variations?
}
