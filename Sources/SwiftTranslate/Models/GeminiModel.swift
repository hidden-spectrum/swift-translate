//
//  Copyright © 2024 Hidden Spectrum, LLC.
//

import ArgumentParser
import Foundation


public enum GeminiModel: String, CaseIterable, ExpressibleByArgument, Sendable {
    case gemini1_5Flash = "gemini-1.5-flash"
    case gemini2_0Flash = "gemini-2.0-flash"
}
