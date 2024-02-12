// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftTranslate",
    platforms: [
        .macOS(.v11)
    ],
    products: [
        .plugin(
            name: "SwiftTranslate",
            targets: ["SwiftTranslate"]
        ),
        .library(
            name: "SwiftStringCatalog",
            targets: ["SwiftStringCatalog"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/MacPaw/OpenAI.git", .upToNextMajor(from: "0.2.5"))
    ],
    targets: [
        
        // Main Plugin
        
        .plugin(
            name: "SwiftTranslate",
            capability: .command(intent: .custom(
                verb: "SwiftTranslate",
                description: "Translates project String Catalogs using OpenAI's GPT 3.5 model"
            ))
        ),
        
        // Libraries
        
        .target(
            name: "SwiftStringCatalog"
        ),
        
        // Tests
        
        .testTarget(
            name: "SwiftStringCatalogTests",
            dependencies: ["SwiftStringCatalog"],
            resources: [.process("Resources")]
        )
    ]
)
