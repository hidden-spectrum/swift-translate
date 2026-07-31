//
//  Copyright © 2024 Hidden Spectrum, LLC.
//

import ArgumentParser
import Foundation


public enum OpenAIModel: String, CaseIterable, ExpressibleByArgument, Sendable {
    case gpt5_6_sol = "gpt-5.6-sol"
    case gpt5_6_terra = "gpt-5.6-terra" // Default
    case gpt5_6_luna = "gpt-5.6-luna"
    case gpt5_4 = "gpt-5.4"
    case gpt5_4_mini = "gpt-5.4-mini"
    case gpt5_4_nano = "gpt-5.4-nano"
}
