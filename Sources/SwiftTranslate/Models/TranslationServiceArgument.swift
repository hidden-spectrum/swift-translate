//
//  Copyright © 2024 Hidden Spectrum, LLC.
//

import ArgumentParser
import Foundation


public enum TranslationServiceArgument: String, ExpressibleByArgument {
    case openAI = "openai"
    case google = "google"
    case googleAI = "googleai"
}
