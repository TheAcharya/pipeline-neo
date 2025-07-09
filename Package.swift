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
        .package(url: "https://github.com/orchetect/TimecodeKit", from: "2.3.1")
    ],
    targets: [
        .target(
            name: "PipelineNeo",
            dependencies: ["TimecodeKit"],
            resources: [
                .copy("FCPXML DTDs")
            ]),
        .testTarget(
            name: "PipelineNeoTests",
            dependencies: ["PipelineNeo"]),
    ]
)
