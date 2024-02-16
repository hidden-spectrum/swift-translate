//
//  Copyright © 2024 Hidden Spectrum, LLC.
//

import PackagePlugin


@main
struct SwiftTranslatePlugin: CommandPlugin {
    
    func performCommand(context: PluginContext, arguments: [String]) async throws {
    }
}

//#if canImport(XcodeProjectPlugin)
//import XcodeProjectPlugin
//
//extension MyCommandPlugin: XcodeCommandPlugin {
//    // Entry point for command plugins applied to Xcode projects.
//    func performCommand(context: XcodePluginContext, arguments: [String]) throws {
//        print("Hello, World!")
//    }
//}
//
//#endif
