//
//  Copyright © 2024 Hidden Spectrum, LLC.
//

import ArgumentParser
import Foundation


public enum OpenAIModel: String, ExpressibleByArgument, Sendable {
    case gpt5 = "gpt-5"
    case gpt5_mini = "gpt-5-mini" // Default
    case gpt5_nano = "gpt-5-nano"
}
