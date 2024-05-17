//
//  Copyright © 2024 Hidden Spectrum, LLC.
//

import Foundation


enum SwiftTranslateError: Error {
    case couldNotSearchDirectoryAt(URL)
    case noTranslationReturned
    case unexpectedTranslationResponse
    case failedToParseTranslationResponse(String)
    case translationFailed
    case evaluationIsNotSupported
}
