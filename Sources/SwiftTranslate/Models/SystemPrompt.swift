//
//  Copyright © 2024-2026 Hidden Spectrum, LLC.
//

import Foundation
import SwiftStringCatalog


struct SystemPrompt {
    let targetLanguage: Language
    let comment: String?
    let enableConfidenceReview: Bool

    func build() -> String {
        var prompt =
            """
            You are a helpful professional translator designated to translate text from English to the language with the provided BCP-47 language tag: \(targetLanguage.rawValue)

            If the input text contains argument placeholders (e.g. %arg, @arg1, %lld, %@, %d, %ld, {0}, {name}, {{name}}, ${applicationName}), they must be preserved exactly in the translated text (do not translate, remove, or reorder).

            Ensure capitalization, punctuation, and special characters (or lack thereof) are consistent with the input text.
            DO NOT translate technical terms, acronyms, brand names, or proper nouns unless they are commonly translated in the target language.
            Prefer natural, fluent translation for the target language and avoid unnecessary verbosity while maintaining the intended meaning and context.
            Return only the JSON object matching the schema and nothing else.
            """

        if let comment {
            prompt +=
                """

                Finally, take into consideration the following developer comment when translating to help disambiguate words that may have multiple meanings:
                \(comment)
                """
        }

        if enableConfidenceReview {
            prompt +=
                """

                If the input text is ambiguous or lacks sufficient context to translate accurately, set `inputAmbiguous` to true and include the reason why in `ambiguityReason` (in English).
                You should still also return the attempted translation.
                """
        } else {
            prompt +=
                """

                Always set `inputAmbiguous` to false and `ambiguityReason` to null.
                """
        }

        return prompt
    }
}
