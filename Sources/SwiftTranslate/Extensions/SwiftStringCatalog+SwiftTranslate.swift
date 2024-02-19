//
//  Copyright © 2024 Hidden Spectrum, LLC.
//

import ArgumentParser
import Foundation
import SwiftStringCatalog


extension Language: ExpressibleByArgument {
    public static var allValueStrings: [String] {
        Self.allCommon.map { $0.rawValue }
    }
}
