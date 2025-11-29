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
        .package(url: "https://github.com/orchetect/swift-timecode", from: "3.0.0")
    ],
    targets: [
        .target(
            name: "PipelineNeo",
            dependencies: [.product(name: "SwiftTimecode", package: "swift-timecode")],
            resources: [
                .process("FCPXML DTDs")
            ]),
        .testTarget(
            name: "PipelineNeoTests",
            dependencies: ["PipelineNeo"]),
    ]
)
