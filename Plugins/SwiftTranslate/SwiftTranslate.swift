//
//  Copyright © 2024 Hidden Spectrum, LLC.
//

import Foundation
import PackagePlugin


@main
struct SwiftTranslatePlugin: CommandPlugin {
    
    func performCommand(context: PluginContext, arguments: [String]) async throws {
        try preflightCheck(for: arguments)
        
        let swiftTranslate = try context.tool(named: "swift-translate")
        let swiftTranslateUrl = URL(fileURLWithPath: swiftTranslate.path.string)
        let targets = context.package.targets
        
        for target in targets {
            guard let target = target.sourceModule else {
                continue
            }
            let stringCatalogs = target.sourceFiles(withSuffix: "xcstrings")
            if stringCatalogs.underestimatedCount == 0 {
                print("No string catalogs found in target (\(target.name)), skipping")
                continue
            }
            
            try _performCommand(
                toolUrl: swiftTranslateUrl,
                targetName: target.name,
                catalogPaths: stringCatalogs.map { $0.path.string }
            )
        }
        
        print("Done!")
    }
    
    private func preflightCheck(for arguments: [String]) throws {
        guard arguments.contains("--api-key") else {
            throw SwiftTranslatePluginError.apiKeyMissing
        }
    }
    
    private func _performCommand(toolUrl: URL, targetName: String, catalogPaths: [String]) throws {
        for catalogPath in catalogPaths {
            let swiftTranslateArgs = ["--skip-confirmation", "--catalog", catalogPath]
            let process = try Process.run(toolUrl, arguments: swiftTranslateArgs)
            process.waitUntilExit()
            if process.terminationReason == .exit && process.terminationStatus == 0 {
                print("Translated string catalogs for \(targetName)")
            } else {
                let problem = "\(process.terminationReason):\(process.terminationStatus)"
                Diagnostics.error("Translating catalog failed: \(problem)")
            }
        }
    }
}

#if canImport(XcodeProjectPlugin)
import XcodeProjectPlugin

extension SwiftTranslatePlugin: XcodeCommandPlugin {
    func performCommand(context: XcodePluginContext, arguments: [String]) throws {
        try preflightCheck(for: arguments)
        
        let swiftTranslate = try context.tool(named: "swift-translate")
        let swiftTranslateUrl = URL(fileURLWithPath: swiftTranslate.path.string)
        let catalogPaths = context.xcodeProject.filePaths
            .map { $0.string }
            .filter { $0.hasSuffix(".xcstrings") }
        
        try _performCommand(toolUrl: swiftTranslateUrl, targetName: context.xcodeProject.displayName, catalogPaths: catalogPaths)
    }
}

#endif
