//
//  Copyright © 2024 Hidden Spectrum, LLC.
//

import ArgumentParser
import Foundation


public enum OpenAIModel: String, ExpressibleByArgument {
    case gpt3_5Turbo = "gpt-3.5-turbo"
    case gpt4o = "gpt-4o"
}
