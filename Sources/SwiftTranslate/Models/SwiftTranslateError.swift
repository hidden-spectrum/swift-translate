//
//  Copyright © 2024 Hidden Spectrum, LLC.
//

import Foundation


enum SwiftTranslateError: Error {
    case couldNotCreateGoogleTranslateURL
    case couldNotDecodeTranslationResponse
    case couldNotSearchDirectoryAt(URL)
    case invalidResponseData
    case noOutputFromModel
    case noTranslationReturned
    case translationRefused(reason: String)
    case unknown
}
