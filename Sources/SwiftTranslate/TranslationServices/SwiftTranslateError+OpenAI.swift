//
//  Copyright © 2026 Hidden Spectrum, LLC.
//

import Foundation
import OpenAI


extension SwiftTranslateError {
    init?(openAIError error: Error) {
        switch error {
        case let OpenAIError.statusError(_, statusCode):
            self = .providerHTTPError(
                provider: "OpenAI",
                statusCode: statusCode,
                message: error.localizedDescription
            )

        default:
            return nil
        }
    }
}
