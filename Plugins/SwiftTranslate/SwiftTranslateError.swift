//
//  Copyright © 2024 Hidden Spectrum, LLC.
//

import Foundation


enum SwiftTranslatePluginError: Error {
    case apiKeyMissing
}

extension SwiftTranslatePluginError: CustomStringConvertible {
    var description: String {
        switch self {
        case .apiKeyMissing:
            return "No API key argument provided (--api-key)"
        }
    }
}

extension SwiftTranslatePluginError: LocalizedError {
  var errorDescription: String? { self.description }
}
