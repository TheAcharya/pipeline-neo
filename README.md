<p align="center">
  <a href="https://github.com/TheAcharya/pipeline-neo"><img src="Assets/Pipeline Neo_Icon.png" height="200">
  <h1 align="center">Pipeline Neo</h1>
</p>

<p align="center"><a href="https://github.com/TheAcharya/pipeline-neo/blob/main/LICENSE"><img src="http://img.shields.io/badge/license-MIT-lightgrey.svg?style=flat" alt="license"/></a>&nbsp;<a href="https://github.com/TheAcharya/pipeline-neo"><img src="https://img.shields.io/badge/platform-macOS-lightgrey.svg?style=flat" alt="platform"/></a>&nbsp;<a href="https://github.com/TheAcharya/pipeline-neo/actions/workflows/build.yml"><img src="https://github.com/TheAcharya/pipeline-neo/actions/workflows/build.yml/badge.svg" alt="build"/></a></p>

A modern Swift framework for working with Final Cut Pro's FCPXML format, fully modernized for Swift 6. Pipeline Neo provides comprehensive tools for parsing, manipulating, and generating FCPXML documents with full TimecodeKit integration for accurate timecode handling. Built with Swift 6.0 and targeting macOS 12+, it offers type-safe operations, comprehensive error handling, and support for FCPXML versions 1.5 through 1.13.

Perfect for professional video editing workflows requiring precise timecode operations, FCPXML validation, and seamless integration with Final Cut Pro projects. Includes comprehensive error handling, performance optimization, and extensive test coverage for production use.

This codebase is developed using AI agents.

> [!IMPORTANT]
> Pipeline Neo has yet to be extensively tested in production environments, real-world workflows, or enterprise scenarios. This library serves as a modernized foundation for AI-assisted development and experimentation with FCPXML processing capabilities. 

## Table of Contents

1. [What's New in Pipeline Neo](#whats-new-in-pipeline-neo)
2. [Core Features](#core-features)
3. [Requirements](#requirements)
4. [Installation](#installation)
5. [Platform Support](#platform-support)
6. [Quick Start](#quick-start)
7. [Modern Features](#modern-features)
8. [Documentation](#documentation)
9. [Examples](#examples)
10. [Understanding FCPXML](#understanding-fcpxml)
11. [Migration from Pipeline](#migration-from-pipeline)
12. [Contributing](#contributing)
13. [Testing](#testing)
14. [Credits](#credits)
15. [License](#license)
16. [Reporting Bugs](#reporting-bugs)

## What's New in Pipeline Neo

Pipeline Neo has been completely modernized for Swift 6 with the following improvements:

- Swift 6 Compatibility: Updated to use the latest Swift 6 features and best practices
- Modern Concurrency: Full support for async/await and structured concurrency
- Improved Performance: Optimized data structures and algorithms
- Better Error Handling: Comprehensive error types with detailed descriptions
- Type Safety: Enhanced type safety with modern Swift patterns
- Documentation: Complete documentation with modern DocC support
- Testing: Comprehensive test suite with performance benchmarks
- Sendable Conformance: Thread-safe types for modern concurrent programming

## Core Features

- Access an FCPXML document's resources, events, clips, and projects through simple object properties
- Create and modify resources, events, clips, and projects with included properties and methods
- Easily manipulate timing values with modern CMTime extensions
- Output FCPXML files with proper text formatting
- Validate FCPXML documents with the DTD
- Works with FCPXML v1.5 through v1.13 files
- NEW: Modern error handling with detailed error types
- NEW: Structured time components for better data handling
- NEW: Performance-optimized filtering and processing

## Requirements

- Platform: macOS 12.0+ (Final Cut Pro XML is macOS-only)
- Swift: 6.0+
- Xcode: 16.0+

## Installation

### Swift Package Manager

Add Pipeline Neo to your project using Swift Package Manager:

```swift
// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "MyPackage",
    platforms: [
        .macOS(.v12)
    ],
    dependencies: [
        .package(
            url: "https://github.com/TheAcharya/pipeline-neo",
            .upToNextMajor(from: "1.0.0")
        )
    ],
    targets: [
        .target(
            name: "MyTarget",
            dependencies: [
                .product(name: "PipelineNeo", package: "pipeline-neo")
            ]
        )
    ]
)
```

## Platform Support

Pipeline Neo is designed specifically for macOS applications that work with Final Cut Pro XML files. The library uses macOS-specific frameworks like `Cocoa` and `CoreMedia`, making it incompatible with other Apple platforms.

## Quick Start

```swift
import PipelineNeo
import Foundation

// Load an FCPXML file
let fileURL = URL(fileURLWithPath: "/path/to/your/project.fcpxml")

do {
    let fcpxmlDoc = try XMLDocument(contentsOfFCPXML: fileURL)
    
    // Get all event names
    let eventNames = fcpxmlDoc.fcpxEventNames
    print("Events: \(eventNames)")
    
    // Create a new event
    let newEvent = XMLElement().fcpxEvent(name: "My New Event")
    fcpxmlDoc.add(event: newEvent)
    
    // Work with time values using modern extensions
    let time = CMTime(value: 1000, timescale: 30000)
    let timeComponents = time.timeAsCounter()
    print("Time: \(timeComponents.counterString)")
    
    // Use modern utility methods
    let filteredClips = FCPXMLUtility.filter(
        fcpxElements: fcpxmlDoc.fcpxEvents.flatMap { $0.eventClips ?? [] },
        ofType: .clip
    )
    
    // Save the modified document
    try fcpxmlDoc.fcpxmlString.write(
        toFile: "/path/to/output.fcpxml",
        atomically: false,
        encoding: .utf8
    )
    
} catch {
    print("Error: \(error)")
}
```

## Modern Features

### Structured Time Components

```swift
// Get structured time components
let time = CMTime(value: 3661234, timescale: 1000)
let components = time.timeAsCounter()
print("\(components.hours):\(components.minutes):\(components.seconds),\(components.milliseconds)")

// Work with SMPTE timecode
let timecode = time.timeAsTimecode(usingFrameDuration: frameDuration, dropFrame: false)
print("Timecode: \(timecode.timecodeString)")
```

### Modern Error Handling

```swift
do {
    let time = try FCPXMLUtility.cmTime(fromFCPXMLTime: "1000/30000s")
    // Use the time value
} catch FCPXMLError.invalidTimeFormat(let timeString) {
    print("Invalid time format: \(timeString)")
} catch {
    print("Unexpected error: \(error)")
}
```

### Type-Safe Element Filtering

```swift
// Filter by multiple types
let resources = FCPXMLUtility.filter(
    fcpxElements: elements,
    ofTypes: [.assetResource, .formatResource, .mediaResource]
)

// Filter by single type
let clips = FCPXMLUtility.filter(
    fcpxElements: elements,
    ofType: .clip
)

// Use convenience methods
let resourceTypes = FCPXMLElementType.allCases.filter { $0.isResource }
```

## Documentation

The latest framework documentation is available at [reuelk.github.io/pipeline](https://reuelk.github.io/pipeline) and is also included in the project's `docs` folder as HTML files.

## Examples

### Open an FCPXML File

```swift
let fileURL = URL(fileURLWithPath: "/Users/[username]/Documents/sample.fcpxml")

do {
    try fileURL.checkResourceIsReachable()
} catch {
    print("The file cannot be found at the given path.")
    return
}

let fcpxmlDoc: XMLDocument

do {
    fcpxmlDoc = try XMLDocument(contentsOfFCPXML: fileURL)
} catch {
    print("Error loading FCPXML file.")
    return
}
```

### List the Names of All Events

```swift
let eventNames = fcpxmlDoc.fcpxEventNames
dump(eventNames)
```

### Create and Add a New Event

```swift
let newEvent = XMLElement().fcpxEvent(name: "My New Event")
fcpxmlDoc.add(event: newEvent)
dump(fcpxmlDoc.fcpxEventNames)
```

### Get Clips That Match a Resource ID and Delete Them

```swift
let firstEvent = fcpxmlDoc.fcpxEvents[0]
let matchingClips = try! firstEvent.eventClips(forResourceID: "r1")

try! firstEvent.removeFromEvent(items: matchingClips)

guard let resource = fcpxmlDoc.resource(matchingID: "r1") else {
    return
}
fcpxmlDoc.remove(resourceAtIndex: resource.index)
```

### Display the Duration of a Clip

```swift
let firstEvent = fcpxmlDoc.fcpxEvents[0]

guard let eventClips = firstEvent.eventClips else {
    return
}

if eventClips.count > 0 {
    let firstClip = eventClips[0]
    let duration = firstClip.fcpxDuration
    let timeDisplay = duration?.timeAsCounter().counterString
    print(timeDisplay)
}
```

### Save the FCPXML File

```swift
do {
    try fcpxmlDoc.fcpxmlString.write(
        toFile: "/Users/[username]/Documents/sample-output.fcpxml",
        atomically: false,
        encoding: .utf8
    )
    print("Wrote FCPXML file.")
} catch {
    print("Error writing to file.")
}
```

## Understanding FCPXML

Further information on FCPXML can be found [here](https://fcp.cafe/developers/fcpxml/).

## Migration from Pipeline

If you're migrating from the original Pipeline library, here are the key changes:

1. Package Name: Changed from `Pipeline` to `PipelineNeo`
2. Swift Version: Requires Swift 6.0+
3. Platform: Requires macOS 12.0+
4. Xcode: Requires Xcode 16.0+
5. Error Handling: Methods now throw errors instead of returning optionals
6. Time Components: Use structured types instead of tuples
7. Static Methods: Many utility methods are now static

## Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details.

## Testing

Run the test suite:

```bash
swift test
```

## Credits

Original Work by [Reuel Kim](https://github.com/reuelk) ([0.5 ... 0.6](https://github.com/reuelk/pipeline))

Icon Design by [Bor Jen Goh](https://www.artstation.com/borjengoh)

## License

Licensed under the MIT license. See [LICENSE](LICENSE) for details.

## Reporting Bugs

For bug reports, feature requests and other suggestions you can create [a new issue](https://github.com/TheAcharya/pipeline-neo/issues) to discuss.
