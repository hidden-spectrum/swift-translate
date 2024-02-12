//
//  Copyright © 2024 Hidden Spectrum, LLC.
//

import ArgumentParser
import Foundation
import OpenAI
import SwiftStringCatalog


@main
struct SwiftTranslate: AsyncParsableCommand {

    // MARK: Public

    @Option(
        name: [.customLong("api-key"), .customShort("k")],
        help: "OpenAI API token"
    )
    private var apiToken: String
    
    @Option(
        name: [.long, .short],
        help: "Text to translate"
    )
    private var text: String
    
    @Option(
        name: [.customLong("lang"), .short],
        help: "Target language"
    )
    private var language: Language
    
    // MARK: Lifecycle
    
    func run() async throws {
        let translator = OpenAITranslator(with: apiToken)
        try await translator.translate(text: text, targetLanguage: language)
    }
}
