//
//  Copyright © 2024 Hidden Spectrum, LLC.
//

import ArgumentParser
import Foundation


public enum OpenAIModel: String, ExpressibleByArgument {
    case gpt4o = "gpt-4o" // Default
    case gpt4_1 = "gpt-4.1"
    case gpt4_1mini = "gpt-4.1-mini"
    case gpt4_1nano = "gpt-4.1-nano"
}
