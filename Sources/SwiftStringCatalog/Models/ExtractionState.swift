//
//  Copyright © 2024 Hidden Spectrum, LLC.
//

import Foundation


public enum ExtractionState: String, Codable, Sendable {
    case extractedWithValue = "extracted_with_value"
    case manual
    case migrated
    case stale
    case unknown
}
