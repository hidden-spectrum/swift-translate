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
            name: "SwiftTranslatePlugin",
            targets: ["SwiftTranslatePlugin"]
        ),
        .executable(
            name: "swift-translate",
            targets: ["SwiftTranslate"]
        ),
        .library(
            name: "SwiftStringCatalog",
            targets: ["SwiftStringCatalog"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.0.0"),
        .package(url: "https://github.com/MacPaw/OpenAI.git", .upToNextMajor(from: "0.2.5"))
    ],
    targets: [
        
        // Main Plugin
        
        .plugin(
            name: "SwiftTranslatePlugin",
            capability: .command(
                intent: .custom(
                    verb: "Swift Translate",
                    description: "Translates project String Catalogs using OpenAI's GPT 3.5 model"
                ),
                permissions: [
                    .allowNetworkConnections(scope: .all(), reason: "Boop"),
                    .writeToPackageDirectory(reason: "Boop"),
                ]
            ),
            dependencies: [
                .target(name: "SwiftTranslate")
            ]
        ),
        
        // Libraries
        
        .executableTarget(
            name: "SwiftTranslate",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "OpenAI", package: "OpenAI"),
                "SwiftStringCatalog"
            ]
        ),
        
        .target(
            name: "SwiftStringCatalog"
        ),
        
        // Tests
        
        .testTarget(
            name: "SwiftStringCatalogTests",
            dependencies: ["SwiftStringCatalog"],
            exclude: ["SwiftStringCatalog.xctestplan"],
            resources: [.process("Resources")]
        )
    ]
)
