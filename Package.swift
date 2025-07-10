// swift-tools-version: 6.0

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
    ],
    dependencies: [
        .package(url: "https://github.com/orchetect/TimecodeKit", from: "1.6.0")
    ],
    targets: [
        .target(
            name: "PipelineNeo",
            dependencies: ["TimecodeKit"],
            resources: [
                .process("FCPXML DTDs")
            ]),
        .testTarget(
            name: "PipelineNeoTests",
            dependencies: ["PipelineNeo"]),
    ]
)
