//
//  Copyright © 2024-2025 Hidden Spectrum, LLC.
//

import ArgumentParser
import Foundation
import OpenAI


public enum OpenAIReasoningEffort: String, ExpressibleByArgument, Sendable {
    case minimal
    case low
    case medium
    case high
    
    var sdkValue: Components.Schemas.ReasoningEffort {
        switch self {
        case .minimal:
            return .minimal
        case .low:
            return .low
        case .medium:
            return .medium
        case .high:
            return .high
        }
    }
}
