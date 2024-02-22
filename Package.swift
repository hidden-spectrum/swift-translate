// swift-tools-version: 5.9
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
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.0.0"),
        .package(url: "https://github.com/MacPaw/OpenAI.git", .upToNextMajor(from: "0.2.5")),
        .package(url: "https://github.com/onevcat/Rainbow.git", .upToNextMajor(from: "4.0.0")),
    ],
    targets: [
        
        // Main Plugin
        
        .plugin(
            name: "SwiftTranslate",
            capability: .command(
                intent: .custom(
                    verb: "swift-translate",
                    description: "Translates project String Catalogs using OpenAI's GPT 3.5 model"
                ),
                permissions: [
                    .writeToPackageDirectory(reason: "Translates string catalogs in your project"),
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
