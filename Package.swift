// swift-tools-version: 6.0
// Pipeline Neo supports Swift 6 concurrency: Sendable protocols/implementations,
// async/await APIs, and builds with -strict-concurrency=complete (see CI).

import PackageDescription

let package = Package(
    name: "PipelineNeo",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "PipelineNeo",
            targets: ["PipelineNeo"]),
        .executable(
            name: "pipeline-neo",
            targets: ["PipelineNeoCLI"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.6.0"),
        .package(url: "https://github.com/orchetect/swift-timecode", from: "3.0.0"),
        .package(url: "https://github.com/orchetect/swift-extensions", from: "2.0.0")
    ],
    targets: [
        .target(
            name: "PipelineNeo",
            dependencies: [
                .product(name: "SwiftTimecode", package: "swift-timecode"),
                .product(name: "SwiftExtensions", package: "swift-extensions")
            ],
            resources: [
                .process("FCPXML DTDs")
            ]),
        .testTarget(
            name: "PipelineNeoTests",
            dependencies: ["PipelineNeo"]),
        .executableTarget(
            name: "PipelineNeoCLI",
            dependencies: [
                "PipelineNeo",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ]),
    ]
)
