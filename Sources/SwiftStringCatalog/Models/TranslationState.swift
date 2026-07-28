//
//  Copyright © 2024 Hidden Spectrum, LLC.
//

import Foundation


public enum TranslationState: String, Codable, Equatable, Sendable {
    case machineTranslated = "machine_translated"
    case new
    case needsReview = "needs_review"
    case stale
    case translated
}
