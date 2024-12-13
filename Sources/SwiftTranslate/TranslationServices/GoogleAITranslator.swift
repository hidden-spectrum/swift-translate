//
//  Copyright © 2024 Hidden Spectrum, LLC.
//

import Foundation
import GoogleGenerativeAI
import SwiftStringCatalog

struct GoogleAITranslator {

    // MARK: Private

    private let apiKey: String
    private let model: AIModel

    // MARK: Lifecycle

    init(apiKey: String, model: AIModel) {
        self.apiKey = apiKey
        self.model = model
    }
}

extension GoogleAITranslator: TranslationService {
    func translate(_ string: String, to targetLanguage: Language, comment: String?) async throws -> String {
        let generativeModel =
        GenerativeModel(
            name: model.rawValue,
            apiKey: apiKey
        )

        var prompt = """
            You are a helpful assistant designed to translate the given text from English to the language with ISO 639-1 code: \(targetLanguage.rawValue)
            If the input text contains argument placeholders (%arg, @arg1, %lld, etc), it's important they are preserved in the translated text.
            You should not output anything other than the translated text.
            """
        if let comment {
            prompt += "\n- IMPORTANT: Take into account the following context when translating: \(comment)\n"
        }

        prompt += string

        let response = try await generativeModel.generateContent(prompt)
        guard var responseText = response.text else {
            throw SwiftTranslateError.noTranslationReturned
        }
        // Last character is a newline, need to remove it.
        responseText.removeLast()

        return responseText
    }
}
