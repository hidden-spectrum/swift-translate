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
    case providerHTTPError(provider: String, statusCode: Int, message: String)
    case translationRefused(reason: String)
    case unknown
}

extension SwiftTranslateError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .couldNotCreateGoogleTranslateURL:
            return "Could not create Google Translate request URL."
        case .couldNotDecodeTranslationResponse:
            return "Could not decode translation response."
        case .couldNotSearchDirectoryAt(let url):
            return "Could not search directory at \(url.path)."
        case .invalidResponseData:
            return "Invalid response data."
        case .noOutputFromModel:
            return "No output was returned from the model."
        case .noTranslationReturned:
            return "No translation was returned."
        case .providerHTTPError(let provider, let statusCode, let message):
            return "\(provider) HTTP \(statusCode): \(message)"
        case .translationRefused(let reason):
            return "Translation refused: \(reason)"
        case .unknown:
            return "Unknown error."
        }
    }

    var shouldAbortTranslation: Bool {
        switch self {
        case .providerHTTPError(_, let statusCode, _):
            return statusCode == 429
        default:
            return false
        }
    }
}
