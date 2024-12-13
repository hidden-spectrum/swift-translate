//
//  Copyright © 2024 Hidden Spectrum, LLC.
//

import ArgumentParser
import Foundation


public enum AIModel: String, ExpressibleByArgument {
    case gpt3_5Turbo = "gpt-3.5-turbo"
    case gpt4o = "gpt-4o"
    case gemini15 = "gemini-1.5-flash"
    case gemini20 = "gemini-2.0-flash-exp"
}
