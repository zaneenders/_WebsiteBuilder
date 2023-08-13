// swift-tools-version: 5.8
import PackageDescription

let package = Package(
    name: "_WebsiteBuilder",
    platforms: [
        // MacOS Requirements for Concurrency
        .macOS(.v13),
        .iOS(.v16),
        .tvOS(.v16),
        .watchOS(.v8),
    ],
    products: [
        .library(name: "WebServer", targets: ["WebServer"]),
        .library(name: "HTMLBuilder", targets: ["HTMLBuilder"]),
        .plugin(
            name: "GenerateDockerfile",
            targets: ["GenerateDockerfile"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/apple/swift-crypto.git", "1.0.0"..<"3.0.0")
    ],
    targets: [
        .executableTarget(
            name: "SampleWebsite",
            dependencies: ["WebServer", "HTMLBuilder"]),
        .target(
            name: "WebServer",
            dependencies: [
                "HTMLBuilder",
                "CHelpers",
                .product(name: "Crypto", package: "swift-crypto"),
            ]),
        // Target for wrapping C code
        .target(name: "CHelpers", publicHeadersPath: "include"),
        // HTML Builder
        .target(name: "HTMLBuilder"),
        // Testing
        .testTarget(
            name: "HTMLBuilderTests",
            dependencies: ["HTMLBuilder"]),

        // Plugins
        .plugin(
            name: "GenerateDockerfile",
            capability: .command(
                intent: .custom(
                    verb: "generate-dockerfile",
                    description: "Generates Dockerfile"),
                permissions: [
                    .writeToPackageDirectory(
                        reason: "This command generates Dockerfile")
                ]
            )
        ),
    ]
)
