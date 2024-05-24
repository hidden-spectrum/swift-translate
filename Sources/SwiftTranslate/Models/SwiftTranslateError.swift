//
//  Copyright © 2024 Hidden Spectrum, LLC.
//

import Foundation


enum SwiftTranslateError: LocalizedError {
    case couldNotSearchDirectoryAt(URL)
    case noTranslationReturned
    case unexpectedTranslationResponse
    case failedToParseTranslationResponse(String)
    case translationFailed
    case evaluationIsNotSupported

    var errorDescription: String? {
        switch self {
        case .couldNotSearchDirectoryAt(let url):
            "Could not search directory at: \(url)"
        case .noTranslationReturned:
            "No translation returned"
        case .unexpectedTranslationResponse:
            "Unexpected translation response"
        case .failedToParseTranslationResponse(let message):
            "Failed to parse translation response: \(message)"
        case .translationFailed:
            "Translation failed"
        case .evaluationIsNotSupported:
            "Evaluation is not supported"
        }
    }

}
