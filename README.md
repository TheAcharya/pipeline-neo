<p align="center">
  <a href="https://github.com/TheAcharya/pipeline-neo"><img src="Assets/Pipeline Neo_Icon.png" height="200">
  <h1 align="center">Pipeline Neo</h1>
</p>

<p align="center"><a href="https://github.com/TheAcharya/pipeline-neo/blob/main/LICENSE"><img src="http://img.shields.io/badge/license-MIT-lightgrey.svg?style=flat" alt="license"/></a>&nbsp;<a href="https://github.com/TheAcharya/pipeline-neo"><img src="https://img.shields.io/badge/platform-macOS-lightgrey.svg?style=flat" alt="platform"/></a>&nbsp;<a href="https://github.com/TheAcharya/pipeline-neo/actions/workflows/build.yml"><img src="https://github.com/TheAcharya/pipeline-neo/actions/workflows/build.yml/badge.svg" alt="build"/></a>&nbsp;<img src="https://img.shields.io/badge/Swift-6.0-orange.svg?style=flat" alt="Swift"/>&nbsp;<img src="https://img.shields.io/badge/Xcode-16+-blue.svg?style=flat" alt="Xcode"/></p>

A modern Swift 6 framework for working with Final Cut Pro's FCPXML with full concurrency support and TimecodeKit integration. Pipeline Neo is a spiritual successor to the original [Pipeline](https://github.com/reuelk/pipeline), modernised for Swift 6.0 and contemporary development practices. 

Pipeline Neo provides a comprehensive API for parsing, creating, and manipulating FCPXML files with advanced timecode operations, async/await patterns, and robust error handling. Built with Swift 6.0 and targeting macOS 12+, it offers type-safe operations, comprehensive test coverage, and seamless integration with TimecodeKit for professional video editing workflows.

Pipeline Neo is currently in an experimental stage and does not yet cover the full range of FCPXML attributes and parameters. It focuses on core functionality while providing a foundation for future expansion and feature completeness.

This codebase is developed using AI agents.

> [!IMPORTANT]
> Pipeline Neo has yet to be extensively tested in production environments, real-world workflows, or application integration. This library serves as a modernised foundation for AI-assisted development and experimentation with FCPXML processing capabilities. 

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
- Works with FCPXML v1.5 through v1.13 files
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

### Basic FCPXML Operations with Modular Architecture

```swift
import PipelineNeo

// Create a modular pipeline with default implementations
let service = ModularUtilities.createPipeline()

// Or create a custom pipeline with specific implementations
let customService = ModularUtilities.createCustomPipeline(
    parser: FCPXMLParser(),
    timecodeConverter: TimecodeConverter(),
    documentManager: XMLDocumentManager(),
    errorHandler: ErrorHandler()
)

// Create a new FCPXML document
let document = service.createFCPXMLDocument(version: "1.10")

// Add resources and sequences using modular operations
let resource = XMLElement(name: "asset")
resource.setAttribute(name: "id", value: "asset1", using: documentManager)
document.addResource(resource, using: documentManager)

let sequence = XMLElement(name: "sequence")
sequence.setAttribute(name: "id", value: "seq1", using: documentManager)
document.addSequence(sequence, using: documentManager)
```

### Time Conversions with Modular TimecodeKit Integration

```swift
import PipelineNeo
import TimecodeKit

// Create modular components
let timecodeConverter = TimecodeConverter()
let utility = FCPXMLUtility(
    timecodeConverter: timecodeConverter
)

// Convert CMTime to TimecodeKit Timecode
let cmTime = CMTime(value: 3600, timescale: 1) // 1 hour
let timecode = utility.timecode(from: cmTime, frameRate: ._24)
print("Timecode: \(timecode?.stringValue ?? "Invalid")")

// Convert TimecodeKit Timecode to CMTime
let newTimecode = try! Timecode(realTime: 7200, at: ._24) // 2 hours
let newCMTime = utility.cmTime(from: newTimecode)
print("CMTime: \(newCMTime.seconds) seconds")

// Use modular extensions for time operations
let frameDuration = CMTime(value: 1, timescale: 24)
let conformed = cmTime.conformed(toFrameDuration: frameDuration, using: timecodeConverter)
let fcpxmlTime = cmTime.fcpxmlTime(using: timecodeConverter)
```

### Working with Modular XML Operations

```swift
// Create modular XML components
let documentManager = XMLDocumentManager()
let parser = FCPXMLParser()

// Create elements with modular operations
let project = documentManager.createElement(
    name: "project",
    attributes: [
        "name": "My Project",
        "id": "proj1"
    ]
)

// Add child elements using modular extensions
let sequence = project.createChild(
    name: "sequence",
    attributes: ["id": "seq1"],
    using: documentManager
)

// Set attributes using modular operations
project.setAttribute(name: "formatRef", value: "r1", using: documentManager)
let formatRef = project.getAttribute(name: "formatRef", using: documentManager)
```

### Error Handling with Modular Components

```swift
// Create modular error handler
let errorHandler = ErrorHandler()

// Process FCPXML with error handling
let url = URL(fileURLWithPath: "/path/to/file.fcpxml")
let result = ModularUtilities.processFCPXML(
    from: url,
    using: service,
    errorHandler: errorHandler
)

switch result {
case .success(let document):
    print("Successfully parsed FCPXML")
    // Work with document
case .failure(let error):
    print("Error: \(error.localizedDescription)")
}
```

### Advanced Modular Operations

```swift
// Create custom implementations for specific needs
class CustomTimecodeConverter: TimecodeConverter {
    override func timecode(from time: CMTime, frameRate: TimecodeFrameRate) -> Timecode? {
        // Custom timecode conversion logic
        return super.timecode(from: time, frameRate: frameRate)
    }
}

// Use custom implementation in pipeline
let customService = FCPXMLService(
    timecodeConverter: CustomTimecodeConverter()
)

// Validate documents using modular validation
let validation = ModularUtilities.validateDocument(document, using: parser)
if validation.isValid {
    print("Document is valid")
} else {
    print("Validation errors: \(validation.errors)")
}
```

### Modern Swift 6 Async/Await Operations

Pipeline Neo now provides comprehensive async/await support for all operations, enabling modern concurrent programming patterns:

```swift
import PipelineNeo

// Create a service with async capabilities
let service = ModularUtilities.createPipeline()

// Asynchronously parse FCPXML files
let document = try await service.parseFCPXML(from: fileURL)
let isValid = await service.validateDocument(document)

// Asynchronously convert timecodes
let time = CMTime(value: 3600, timescale: 60000)
let frameRate = TimecodeFrameRate._24
let timecode = await service.timecode(from: time, frameRate: frameRate)

// Asynchronously create and manipulate documents
let newDocument = await service.createFCPXMLDocument(version: "1.10")
await service.addResource(resource, to: newDocument)
try await service.saveDocument(newDocument, to: outputURL)

// Asynchronously filter elements
let elements = [element1, element2, element3]
let filtered = await service.filterElements(elements, ofTypes: [.assetResource, .sequence])

// Asynchronously convert FCPXML time strings
let cmTime = await service.cmTime(fromFCPXMLTime: "3600/60000")
let timeString = await service.fcpxmlTime(fromCMTime: cmTime)

// Asynchronously conform times to frame boundaries
let conformed = await service.conform(time: time, toFrameDuration: frameDuration)
```

### Concurrent Operations with Task Groups

```swift
// Process multiple FCPXML files concurrently
let urls = [url1, url2, url3, url4, url5]
let results = await ModularUtilities.processMultipleFCPXML(
    from: urls,
    using: service,
    errorHandler: errorHandler
)

// Convert timecodes for multiple elements concurrently
let timecodes = await ModularUtilities.convertTimecodes(
    for: elements,
    using: timecodeConverter,
    frameRate: ._24
)

// Use structured concurrency for complex workflows
await withTaskGroup(of: XMLDocument.self) { group in
    for url in urls {
        group.addTask {
            try await service.parseFCPXML(from: url)
        }
    }
    
    for await document in group {
        // Process each document
        let isValid = await service.validateDocument(document)
        if isValid {
            // Further processing
        }
    }
}
```

### Async Component-Level Operations

```swift
// Async parser operations
let parser = FCPXMLParser()
let document = try await parser.parse(data)
let isValid = await parser.validate(document)
let filtered = await parser.filter(elements: elements, ofTypes: [.assetResource])

// Async timecode converter operations
let timecodeConverter = TimecodeConverter()
let timecode = await timecodeConverter.timecode(from: time, frameRate: ._24)
let cmTime = await timecodeConverter.cmTime(from: timecode)
let conformed = await timecodeConverter.conform(time: time, toFrameDuration: frameDuration)

// Async document manager operations
let documentManager = XMLDocumentManager()
let document = await documentManager.createFCPXMLDocument(version: "1.10")
let element = await documentManager.createElement(name: "asset", attributes: ["id": "test1"])
await documentManager.addResource(element, to: document)
try await documentManager.saveDocument(document, to: url)
```

### Modular Extensions Usage

```swift
// Use modular extensions for CMTime operations
let time = CMTime(value: 3600, timescale: 60000)
let frameRate = TimecodeFrameRate._24

let timecode = time.timecode(frameRate: frameRate, using: timecodeConverter)
let fcpxmlTime = time.fcpxmlTime(using: timecodeConverter)
let conformed = time.conformed(toFrameDuration: frameDuration, using: timecodeConverter)

// Use modular extensions for XMLElement operations
let element = XMLElement(name: "test")
element.setAttribute(name: "id", value: "test1", using: documentManager)
let attribute = element.getAttribute(name: "id", using: documentManager)

// Use modular extensions for XMLDocument operations
document.addResource(resource, using: documentManager)
document.addSequence(sequence, using: documentManager)
let isValid = document.isValid(using: parser)
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

## FCPXML Version Support

Pipeline Neo supports FCPXML versions 1.5 through 1.13. All DTDs for these versions are included in the codebase, ensuring compatibility with the latest Final Cut Pro XML workflows.

## Migration from Original Pipeline

Pipeline Neo is a modernised successor to [Pipeline](https://github.com/reuelk/pipeline). Key changes include:

- Swift 6 concurrency support with async/await
- TimecodeKit integration for advanced timecode operations
- Modern Swift patterns and syntax
- macOS 12+ requirement
- Updated package name to `PipelineNeo`
- Comprehensive test suite
- Improved error handling

## Modularity & Safety

Pipeline Neo is now fully modular, built on a protocol-oriented architecture. All major operations (parsing, timecode conversion, XML manipulation, error handling) are defined as protocols with default implementations, enabling easy extension, testing, and future-proofing. Dependency injection is used throughout for maximum flexibility and testability.

- Thread-safe and concurrency-compliant: All code is Sendable or @unchecked Sendable as appropriate, and passes thread sanitizer checks.
- No known vulnerabilities: All dependencies (including TimecodeKit 1.6.13) are up to date and have no published security advisories as of July 2025.
- No unsafe code patterns: No use of unsafe pointers, dynamic code execution, or C APIs. All concurrency is structured and type-safe.

## Architecture Overview

- Protocols: All core functionality is defined via protocols (e.g., FCPXMLParsing, TimecodeConversion, XMLDocumentOperations, ErrorHandling).
- Implementations: Default implementations are provided, but you can inject your own for custom behaviour or testing.
- Extensions: Modular extensions for CMTime, XMLElement, and XMLDocument allow dependency-injected operations.
- Service Layer: FCPXMLService orchestrates all modular components for high-level workflows.
- Utilities: ModularUtilities provides pipeline creation, validation, and error-handling helpers.

See AGENT.md for a detailed breakdown for AI agents and contributors.

## Credits

Created by [Vigneswaran Rajkumar](https://bsky.app/profile/vigneswaranrajkumar.com)

Icon Design by [Bor Jen Goh](https://www.artstation.com/borjengoh)

## License

Licensed under the MIT license. See [LICENSE](https://github.com/TheAcharya/pipeline-neo/blob/main/LICENSE) for details.

## Reporting Bugs

For bug reports, feature requests and suggestions you can create a new [issue](https://github.com/TheAcharya/pipeline-neo/issues) to discuss.

## Contribution

Community contributions are welcome and appreciated. Developers are encouraged to fork the repository and submit pull requests to enhance functionality or introduce thoughtful improvements. However, a key requirement is that nothing should break—all existing features and behaviours and logic must remain fully functional and unchanged. Once reviewed and approved, updates will be merged into the main branch.

### AI Agent Development Collaboration

Pipeline Neo is developed using AI agents and we welcome developers who are interested in maintaining or contributing to the project using similar AI-assisted development approaches. If you're passionate about AI-driven development workflows and would like to collaborate on expanding Pipeline Neo's capabilities, we'd love to hear from you. 

Developers with experience in AI agent development and FCPXML processing are invited to get in touch. We can provide repository access and collaborate on advancing the framework's functionality.
