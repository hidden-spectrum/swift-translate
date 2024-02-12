//
//  Copyright © 2024 Hidden Spectrum, LLC.
//

import ArgumentParser
import Foundation
import OpenAI


@main
struct SwiftTranslate: AsyncParsableCommand {

    // MARK: Public

    @Option(
        name: [.customLong("api-key"), .customShort("k")],
        help: "OpenAI API token"
    )
    private var apiToken: String
    
    @Option(
        help: "Text to translate"
    )
    private var text: String
    

    // MARK: Lifecycle
    
    func run() async throws {
        let translator = OpenAITranslator(apiToken: "apiToken")
        try await translator.translate(text: "text", targetLanguage: "es")
    }
}
