//
//  Copyright © 2024-2025 Hidden Spectrum, LLC.
//

import ArgumentParser
import Foundation
import OpenAI


public enum OpenAIReasoningEffort: String, ExpressibleByArgument, Sendable {
    case none
    case low
    case medium
    case high
    
    var sdkValue: Components.Schemas.ReasoningEffort {
        switch self {
        case .none:
            return .none
        case .low:
            return .low
        case .medium:
            return .medium
        case .high:
            return .high
        }
    }
}
