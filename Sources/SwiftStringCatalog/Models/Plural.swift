//
//  Copyright © 2024 Hidden Spectrum, LLC.
//

import Foundation


struct Plural: Codable {
    let one: StringUnitWrapper?
    let other: StringUnitWrapper?
    let few: StringUnitWrapper?
    let many: StringUnitWrapper?
}
