//
//  Copyright © 2024 Hidden Spectrum, LLC.
//

import ArgumentParser
import Foundation
import OpenAI
import SwiftStringCatalog


@main
struct SwiftTranslate: AsyncParsableCommand {

    static var configuration = CommandConfiguration(
        abstract: "Swift Translate is a CLI tool and Swift Package Plugin that makes it easy to localize your app",
        subcommands: [
            TranslateCommand.self,
            MarkNeedsReviewCommand.self
        ]
    )

    func run() async throws {

    }

}

