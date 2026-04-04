//
//  Copyright © 2024 Hidden Spectrum, LLC.
//

import ArgumentParser
import Foundation


public enum GeminiModel: String, CaseIterable, ExpressibleByArgument, Sendable {
    case gemini2_5Flash = "gemini-2.5-flash"
    case gemini3FlashPreview = "gemini-3-flash-preview"
}
