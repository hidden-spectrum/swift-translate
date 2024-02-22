//
//  Copyright © 2024 Hidden Spectrum, LLC.
//

import Foundation
import PackagePlugin


@main
struct SwiftTranslatePlugin: CommandPlugin {
    
    func performCommand(context: PluginContext, arguments: [String]) async throws {
        let swiftTranslate = try context.tool(named: "swift-translate")
        let swiftTranslateUrl = URL(fileURLWithPath: swiftTranslate.path.string)
        
        var argExtractor = ArgumentExtractor(arguments)
        let targetNames = argExtractor.extractOption(named: "target")
        let targets = targetNames.isEmpty
            ? context.package.targets
            : try context.package.targets(named: targetNames)
        
        // Iterate over the targets we've been asked to format.
        for target in targets {
            guard let target = target.sourceModule else {
                continue
            }
            let stringCatalogs = target.sourceFiles(withSuffix: "xcstrings")
            
            if stringCatalogs.underestimatedCount == 0 {
                print("No string catalogs found in target (\(target.name)), skipping")
                continue
            }
            
            for stringCatalog in stringCatalogs {
                let swiftTranslateArgs = ["--skip-confirmation", "--catalog", stringCatalog.path.string]
                let process = try Process.run(swiftTranslateUrl, arguments: swiftTranslateArgs)
                process.waitUntilExit()
                if process.terminationReason == .exit && process.terminationStatus == 0 {
                    print("Translated string catalogs for \(target.name)")
                } else {
                    let problem = "\(process.terminationReason):\(process.terminationStatus)"
                    Diagnostics.error("Translating catalog failed: \(problem)")
                }
            }
        }
        
        print("Done!")
    }
}

#if canImport(XcodeProjectPlugin)
import XcodeProjectPlugin

extension SwiftTranslatePlugin: XcodeCommandPlugin {
    func performCommand(context: XcodePluginContext, arguments: [String]) throws {
//        try SwiftTranslatePlugin().performCommand(context: context, arguments: arguments)
    }
}

#endif
