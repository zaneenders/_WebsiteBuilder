// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "_WebsiteBuilder",  // TODO better name
    products: [
        .library(
            name: "_WebsiteBuilder",
            targets: ["WebsiteBuilder", "Colors"]),
        .plugin(
            name: "generate-dockerfile",
            targets: ["GenerateDockerfile"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/apple/swift-nio.git",
            from: "2.0.0")
    ],
    targets: [
        .target(name: "Colors"),
        .target(
            name: "WebsiteBuilder",
            dependencies: [
                .product(name: "NIOCore", package: "swift-nio"),
                .product(name: "NIOPosix", package: "swift-nio"),
                .product(name: "NIOHTTP1", package: "swift-nio"),
                .product(name: "NIOWebSocket", package: "swift-nio"),
            ]
            /*
            // Swift 6 settings for local developement
            ,swiftSettings: [
                .enableUpcomingFeature("BareSlashRegexLiterals"),
                .enableUpcomingFeature("ConciseMagicFile"),
                .enableUpcomingFeature("ExistentialAny"),
                .enableUpcomingFeature("ForwardTrailingClosures"),
                .enableUpcomingFeature("ImplicitOpenExistentials"),
                .enableUpcomingFeature("StrictConcurrency"),
                .unsafeFlags([
                    "-warn-concurrency", "-enable-actor-data-race-checks",
                ]),
            ]
            */
        ),
        .testTarget(name: "PlayGroundTests", dependencies: ["WebsiteBuilder"]),

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
