// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "_WebsiteBuilder",  // TODO better name
    products: [
        .library(
            name: "_WebsiteBuilder",
            targets: ["WebsiteBuilder", "Colors"])
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

    ]
)
