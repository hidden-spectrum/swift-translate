//
//  Copyright © 2024 Hidden Spectrum, LLC.
//

import Foundation
import PackagePlugin


@main
struct SwiftTranslatePlugin: CommandPlugin {
    
    let fileManager = FileManager.default
    
    func performCommand(context: PluginContext, arguments: [String]) async throws {
        let apiKey = try preflight(with: arguments)
        
        let swiftTranslate = try context.tool(named: "swift-translate")
        let swiftTranslateUrl = URL(fileURLWithPath: swiftTranslate.path.string)
        let targets = context.package.targets
        
        for target in targets {
            guard let target = target.sourceModule else {
                continue
            }
            try _performCommand(
                toolUrl: swiftTranslateUrl,
                apiKey: apiKey,
                targetName: target.name,
                directoryPath: target.directory.string
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
    
    private func _performCommand(toolUrl: URL, apiKey: String, targetName: String, directoryPath: String) throws {
        let swiftTranslateArgs = ["--api-key", apiKey, "--skip-confirmation", "--overwrite", directoryPath]
        
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
        let swiftTranslate = try context.tool(named: "swift-translate")
        let swiftTranslateUrl = URL(fileURLWithPath: swiftTranslate.path.string)

        try _performCommand(
            toolUrl: swiftTranslateUrl,
            apiKey: apiKey,
            targetName: context.xcodeProject.displayName,
            directoryPath: context.xcodeProject.directory.string
        )
    }
}

#endif
