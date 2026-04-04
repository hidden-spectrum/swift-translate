// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription


let package = Package(
    name: "SwiftTranslate",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .plugin(
            name: "SwiftTranslate",
            targets: ["SwiftTranslate"]
        ),
        .executable(
            name: "swift-translate",
            targets: ["swift-translate"]
        ),
        .library(
            name: "SwiftStringCatalog",
            targets: ["SwiftStringCatalog"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", .upToNextMajor(from: "1.5.0")),
        .package(url: "https://github.com/MacPaw/OpenAI.git", revision: "3f2cac98d3e98d6b4d90279bd737190fc343dbc4"),
        .package(url: "https://github.com/google-gemini/generative-ai-swift", .upToNextMajor(from: "0.5.0")),
        .package(url: "https://github.com/onevcat/Rainbow.git", .upToNextMajor(from: "4.0.0")),
    ],
    targets: [
        
        // Main Plugin
        
        .plugin(
            name: "SwiftTranslate",
            capability: .command(
                intent: .custom(
                    verb: "swift-translate",
                    description: "Translates project String Catalogs using supported translation services"
                ),
                permissions: [
                    .writeToPackageDirectory(reason: "Translates string catalogs in your project"),
                    .allowNetworkConnections(scope: .all(ports: []), reason: "Needs access to translation provider servers")
                ]
            ),
            dependencies: [
                .target(name: "swift-translate")
            ]
        ),
        
        // Libraries
        
        .executableTarget(
            name: "swift-translate",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "GoogleGenerativeAI", package: "generative-ai-swift"),
                .product(name: "OpenAI", package: "OpenAI"),
                .product(name: "Rainbow", package: "Rainbow"),
                "SwiftStringCatalog"
            ],
            path: "Sources/SwiftTranslate"
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
