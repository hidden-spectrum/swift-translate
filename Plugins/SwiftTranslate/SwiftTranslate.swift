//
//  Copyright © 2024-2025 Hidden Spectrum, LLC.
//

import Foundation
import PackagePlugin


@main
struct SwiftTranslatePlugin: CommandPlugin {

    func performCommand(context: PluginContext, arguments: [String]) async throws {
        let apiKey = try preflight(with: arguments)
        let enableConfidenceReview = confidenceReviewEnabled(with: arguments)
        
        let swiftTranslate = try context.tool(named: "swift-translate")
        let swiftTranslateUrl = swiftTranslate.url
        let targets = context.package.targets
        
        for target in targets {
            guard let target = target.sourceModule else {
                continue
            }
            try _performCommand(
                toolUrl: swiftTranslateUrl,
                apiKey: apiKey,
                enableConfidenceReview: enableConfidenceReview,
                directoryUrl: target.directoryURL
            )
        }
    }
    
    private func preflight(with arguments: [String]) throws -> String {
        var argumentExtractor = ArgumentExtractor(arguments)
        guard let apiKey = argumentExtractor.extractOption(named: "api-key").last else {
            throw SwiftTranslatePluginError.apiKeyMissing
        }
        return apiKey
    }

    private func confidenceReviewEnabled(with arguments: [String]) -> Bool {
        var argumentExtractor = ArgumentExtractor(arguments)
        return argumentExtractor.extractFlag(named: "enable-confidence-review") > 0
    }
    
    private func _performCommand(toolUrl: URL, apiKey: String, enableConfidenceReview: Bool, directoryUrl: URL) throws {
        var swiftTranslateArgs = ["--api-key", apiKey, "--skip-confirmation", "--overwrite"]
        if enableConfidenceReview {
            swiftTranslateArgs.append("--enable-confidence-review")
        }
        swiftTranslateArgs.append(directoryUrl.path)
        
        let process = try Process.run(toolUrl, arguments: swiftTranslateArgs)
        process.waitUntilExit()
        
        if process.terminationReason != .exit || process.terminationStatus != 0  {
            let problem = "\(process.terminationReason):\(process.terminationStatus)"
            Diagnostics.error("Translating catalog failed: \(problem)")
        }
    }
}

#if canImport(XcodeProjectPlugin)
import XcodeProjectPlugin

extension SwiftTranslatePlugin: XcodeCommandPlugin {
    func performCommand(context: XcodePluginContext, arguments: [String]) throws {
        let apiKey = try preflight(with: arguments)
        let enableConfidenceReview = confidenceReviewEnabled(with: arguments)
        let swiftTranslate = try context.tool(named: "swift-translate")
        let swiftTranslateUrl = swiftTranslate.url

        try _performCommand(
            toolUrl: swiftTranslateUrl,
            apiKey: apiKey,
            enableConfidenceReview: enableConfidenceReview,
            directoryUrl: context.xcodeProject.directoryURL
        )
    }
}

#endif
