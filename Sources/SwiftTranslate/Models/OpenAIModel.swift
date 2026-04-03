//
//  Copyright © 2024 Hidden Spectrum, LLC.
//

import ArgumentParser
import Foundation


public enum OpenAIModel: String, ExpressibleByArgument, Sendable {
    case gpt5_4 = "gpt-5.4"
    case gpt5_4_mini = "gpt-5.4-mini" // Default
    case gpt5_4_nano = "gpt-5.4-nano"
    case gpt5 = "gpt-5"
    case gpt5_mini = "gpt-5-mini"
    case gpt5_nano = "gpt-5-nano"
}
