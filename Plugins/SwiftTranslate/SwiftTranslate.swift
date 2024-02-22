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
            let targetDirectoryPath =  target.directory.string
            let targetDirectoryUrl: URL = .init(filePath: targetDirectoryPath)
            guard let fileEnumerator = fileManager.enumerator(
                at: targetDirectoryUrl,
                includingPropertiesForKeys: nil,
                options: .skipsHiddenFiles
            ) else {
                print("Could not get enumerator for path \(targetDirectoryPath)")
                continue
            }
            
            var stringCatalogs: [URL] = []
            for case let fileURL as URL in fileEnumerator {
                if fileURL.pathExtension == "xcstrings" {
                    stringCatalogs.append(fileURL)
                }
            }
            
            if stringCatalogs.count == 0 {
                print("No string catalogs found in target (\(target.name)), skipping")
                continue
            } else {
                print("Found \(stringCatalogs.count) string catalogs in target (\(target.name))")
            }
            
            try _performCommand(
                toolUrl: swiftTranslateUrl,
                apiKey: apiKey,
                targetName: target.name,
                catalogPaths: stringCatalogs.map { $0.path }
            )
        }
        
        print("Done!")
    }
    
    private func preflight(with arguments: [String]) throws -> String {
        var argumentExtractor = ArgumentExtractor(arguments)
        guard let apiKey = argumentExtractor.extractOption(named: "api-key").last else {
            throw SwiftTranslatePluginError.apiKeyMissing
        }
        print("Translating string catalogs...")
        return apiKey
    }
    
    private func _performCommand(toolUrl: URL, apiKey: String, targetName: String, catalogPaths: [String]) throws {
        for catalogPath in catalogPaths {
            let swiftTranslateArgs = ["--api-key", apiKey, "--skip-confirmation", "--catalog", catalogPath]
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
        let apiKey = try preflight(with: arguments)
        
        let swiftTranslate = try context.tool(named: "swift-translate")
        let swiftTranslateUrl = URL(fileURLWithPath: swiftTranslate.path.string)
        let catalogPaths = context.xcodeProject.filePaths
            .map { $0.string }
            .filter { $0.hasSuffix(".xcstrings") }
        
        try _performCommand(
            toolUrl: swiftTranslateUrl,
            apiKey: apiKey,
            targetName: context.xcodeProject.displayName,
            catalogPaths: catalogPaths
        )
    }
}

#endif
