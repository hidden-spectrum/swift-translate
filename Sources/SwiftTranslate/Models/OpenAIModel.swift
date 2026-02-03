//
//  Copyright © 2024 Hidden Spectrum, LLC.
//

import ArgumentParser
import Foundation


public enum OpenAIModel: String, ExpressibleByArgument {
    case gpt5 = "gpt-5"
    case gpt5_mini = "gpt-5-mini"
    case gpt5_nano = "gpt-5-nano"
    case gpt4_1 = "gpt-4-1"
    case gpt4_1_mini = "gpt-4-1-mini" // Default
}
