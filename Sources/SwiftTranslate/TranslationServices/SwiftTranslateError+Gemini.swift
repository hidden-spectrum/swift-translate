//
//  Copyright © 2026 Hidden Spectrum, LLC.
//

import Foundation
import GoogleGenerativeAI


extension SwiftTranslateError {
    init?(geminiError error: Error) {
        switch error {
        case let GenerateContentError.invalidAPIKey(message):
            self = .providerConfigurationIssue(provider: "Gemini", message: message)

        case GenerateContentError.unsupportedUserLocation:
            self = .providerConfigurationIssue(
                provider: "Gemini",
                message: "User location is not supported for the Gemini API."
            )

        case let GenerateContentError.promptBlocked(response):
            let reason = response.promptFeedback?.blockReason?.rawValue ?? "Prompt blocked"
            self = .translationRefused(reason: reason)

        case let GenerateContentError.responseStoppedEarly(_, response):
            if let responseText = response.text,
               !responseText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                return nil
            }
            self = .noTranslationReturned

        case let GenerateContentError.internalError(underlyingError):
            let reflectedProperties = Mirror(reflecting: underlyingError).children
            let httpResponseCode = reflectedProperties
                .first(where: { $0.label == "httpResponseCode" })?
                .value as? Int

            guard httpResponseCode == 429 else {
                return nil
            }

            let message = reflectedProperties
                .first(where: { $0.label == "message" })?
                .value as? String ?? error.localizedDescription

            self = .providerHTTPError(
                provider: "Gemini",
                statusCode: 429,
                message: message
            )

        default:
            return nil
        }
    }
}
