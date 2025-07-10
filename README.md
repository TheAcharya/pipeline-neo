<p align="center">
  <a href="https://github.com/TheAcharya/pipeline-neo"><img src="Assets/Pipeline Neo_Icon.png" height="200">
  <h1 align="center">Pipeline Neo</h1>
</p>

<p align="center"><a href="https://github.com/TheAcharya/pipeline-neo/blob/main/LICENSE"><img src="http://img.shields.io/badge/license-MIT-lightgrey.svg?style=flat" alt="license"/></a>&nbsp;<a href="https://github.com/TheAcharya/pipeline-neo"><img src="https://img.shields.io/badge/platform-macOS-lightgrey.svg?style=flat" alt="platform"/></a>&nbsp;<a href="https://github.com/TheAcharya/pipeline-neo/actions/workflows/build.yml"><img src="https://github.com/TheAcharya/pipeline-neo/actions/workflows/build.yml/badge.svg" alt="build"/></a>&nbsp;<img src="https://img.shields.io/badge/Swift-6.0-orange.svg?style=flat" alt="Swift"/>&nbsp;<img src="https://img.shields.io/badge/Xcode-16+-blue.svg?style=flat" alt="Xcode"/></p>

A modern Swift 6 framework for working with Final Cut Pro's FCPXML with full concurrency support and TimecodeKit integration. Pipeline Neo is a spiritual successor to the original [Pipeline framework](https://github.com/reuelk/pipeline) by Reuel Kim, modernized for Swift 6.0 and contemporary development practices. 

Pipeline Neo provides a comprehensive API for parsing, creating, and manipulating FCPXML files with advanced timecode operations, async/await patterns, and robust error handling. Built with Swift 6.0 and targeting macOS 12+, it offers type-safe operations, comprehensive test coverage, and seamless integration with TimecodeKit for professional video editing workflows.

Pipeline Neo is currently in an experimental stage and does not yet cover the full range of FCPXML attributes and parameters. It focuses on core functionality while providing a foundation for future expansion and feature completeness.

This codebase is developed using AI agents.

> [!IMPORTANT]
> Pipeline Neo has yet to be extensively tested in production environments, real-world workflows, or enterprise scenarios. This library serves as a modernized foundation for AI-assisted development and experimentation with FCPXML processing capabilities. 

## Table of Contents

- [Core Features](#core-features)
- [Requirements](#requirements)
- [Installation](#installation)
- [Usage](#usage)
- [Examples](#examples)
- [Understanding FCPXML](#understanding-fcpxml)
- [Migration from Original Pipeline](#migration-from-original-pipeline)
- [Credits](#credits)
- [License](#license)
- [Reporting Bugs](#reporting-bugs)

## Core Features

- Access an FCPXML document's resources, events, clips, and projects through simple object properties
- Create and modify resources, events, clips, and projects with included properties and methods
- Easily manipulate timing values with modern Swift concurrency
- Output FCPXML files with proper text formatting
- Validate FCPXML documents with the DTD
- Works with FCPXML v1.6 through v1.8 files
- Full TimecodeKit integration for advanced timecode operations
- Swift 6 concurrency support with async/await patterns
- macOS 12+ support with modern Swift features

## Requirements

- macOS 12.0+
- Xcode 16.0+
- Swift 6.0+

## Installation

### Swift Package Manager

Add Pipeline Neo to your project in Xcode:

1. File → Add Package Dependencies
2. Enter the repository URL: `https://github.com/TheAcharya/pipeline-neo`
3. Select the version you want to use
4. Click Add Package

Or add it to your `Package.swift`:

```swift
// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "MyPackage",
    platforms: [
        .macOS(.v12)
    ],
    dependencies: [
        .package(url: "https://github.com/TheAcharya/pipeline-neo", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "MyTarget",
            dependencies: ["PipelineNeo"]
        )
    ]
)
```

## Usage

### Basic FCPXML Operations

```swift
import PipelineNeo

// Create a new FCPXML document
let resources: [XMLElement] = []
let events: [XMLElement] = []
let fcpxmlDoc = XMLDocument(resources: resources, events: events, fcpxmlVersion: "1.8")

// Add an event
let newEvent = XMLElement().fcpxEvent(name: "My New Event")
fcpxmlDoc.add(events: [newEvent])

// Get event names
let eventNames = fcpxmlDoc.fcpxEventNames
print("Events: \(eventNames)")
```

### Time Conversions with TimecodeKit

```swift
import PipelineNeo
import TimecodeKit

// Initialize utility
let utility = FCPXMLUtility()

// Convert CMTime to TimecodeKit Timecode
let cmTime = CMTime(value: 3600, timescale: 1) // 1 hour
let timecode = await utility.timecode(from: cmTime, frameRate: .fps24)
print("Timecode: \(timecode?.stringValue ?? "Invalid")")

// Convert TimecodeKit Timecode to CMTime
let newTimecode = Timecode(at: .fps24, time: 7200) // 2 hours
let newCMTime = await utility.cmTime(from: newTimecode)
print("CMTime: \(newCMTime.seconds) seconds")
```

### Working with Clips and Projects

```swift
// Create a project
let formatRef = "r1"
let duration = CMTime(value: 3600, timescale: 1) // 1 hour
let tcStart = CMTime(value: 0, timescale: 1)
let clips: [XMLElement] = []

let project = XMLElement().fcpxProject(
    name: "My Project",
    formatRef: formatRef,
    duration: duration,
    tcStart: tcStart,
    tcFormat: .nonDropFrame,
    audioLayout: .stereo,
    audioRate: .rate48kHz,
    renderColorSpace: .rec709,
    clips: clips
)

// Add project to event
newEvent.addChild(project)
```

### Async Operations

```swift
// Async line break conversion
let url = URL(fileURLWithPath: "/path/to/file.fcpxml")
let convertedDoc = await utility.convertLineBreaksInAttributes(inXMLDocumentURL: url)

// Filter elements asynchronously
let elements: [XMLElement] = []
let filtered = await utility.filter(fcpxElements: elements, ofTypes: [.clip, .audio])
```

### Timecode Operations

```swift
// Convert timecode to CMTime
let frameDuration = CMTime(value: 1, timescale: 24) // 24fps
let cmTime = utility.CMTimeFrom(
    timecodeHours: 1,
    timecodeMinutes: 30,
    timecodeSeconds: 15,
    timecodeFrames: 12,
    frameDuration: frameDuration
)

// Convert CMTime to FCPXML time string
let fcpxmlTime = utility.fcpxmlTime(fromCMTime: cmTime)
print("FCPXML Time: \(fcpxmlTime)")

// Conform time to frame boundary
let conformed = utility.conform(time: cmTime, toFrameDuration: frameDuration)
```

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

### List Event Names

```swift
let eventNames = fcpxmlDoc.fcpxEventNames
print("Event names: \(eventNames)")
```

### Create and Add Events

```swift
let newEvent = XMLElement().fcpxEvent(name: "My New Event")
fcpxmlDoc.add(events: [newEvent])
print("Updated event names: \(fcpxmlDoc.fcpxEventNames)")
```

### Work with Clips

```swift
let firstEvent = fcpxmlDoc.fcpxEvents[0]
let matchingClips = try firstEvent.eventClips(forResourceID: "r1")

// Remove clips
try firstEvent.removeFromEvent(items: matchingClips)

// Remove resource
if let resource = fcpxmlDoc.resource(matchingID: "r1") {
    fcpxmlDoc.remove(resourceAtIndex: resource.index)
}
```

### Display Clip Duration

```swift
let firstEvent = fcpxmlDoc.fcpxEvents[0]

if let eventClips = firstEvent.eventClips, eventClips.count > 0 {
    let firstClip = eventClips[0]
    if let duration = firstClip.fcpxDuration {
        let timeDisplay = duration.timeAsCounter().counterString
        print("Duration: \(timeDisplay)")
    }
}
```

### Save FCPXML File

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

## Migration from Original Pipeline

Pipeline Neo is a modernized fork of the original Pipeline library. Key changes include:

- Swift 6 concurrency support with async/await
- TimecodeKit integration for advanced timecode operations
- Modern Swift patterns and syntax
- macOS 12+ requirement
- Updated package name to `PipelineNeo`
- Comprehensive test suite
- Improved error handling

## Credits

Created by [Vigneswaran Rajkumar](https://bsky.app/profile/vigneswaranrajkumar.com)

Icon Design by [Bor Jen Goh](https://www.artstation.com/borjengoh)

## License

Licensed under the MIT license. See [LICENSE](https://github.com/TheAcharya/pipeline-neo/blob/main/LICENSE) for details.

## Reporting Bugs

For bug reports, feature requests and other suggestions you can create [a new issue](https://github.com/TheAcharya/pipeline-neo/issues) to discuss.
