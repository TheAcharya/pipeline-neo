# Pipeline Neo — User Manual

Complete manual and usage guide for Pipeline Neo, a Swift 6 framework for Final Cut Pro FCPXML processing with SwiftTimecode integration.

---

## Table of Contents

1. [Introduction](#1-introduction)
2. [API and documentation](#2-api-and-documentation)
3. [Usage](#3-usage)
   - [Loading from file or bundle](#31-loading-from-file-or-bundle)
   - [Basic FCPXML operations with modular architecture](#32-basic-fcpxml-operations-with-modular-architecture)
   - [Time conversions with SwiftTimecode](#33-time-conversions-with-swifttimecode)
   - [Optional logging](#34-optional-logging)
   - [Working with modular XML operations](#35-working-with-modular-xml-operations)
   - [Error handling with modular components](#36-error-handling-with-modular-components)
   - [Advanced modular operations](#37-advanced-modular-operations)
   - [Modern Swift 6 async/await operations](#38-modern-swift-6-asyncawait-operations)
   - [Concurrent operations with task groups](#39-concurrent-operations-with-task-groups)
   - [Async component-level operations](#310-async-component-level-operations)
   - [Modular extensions usage](#311-modular-extensions-usage)
   - [File loader API](#312-file-loader-api)
   - [FCPXML version and element types](#313-fcpxml-version-and-element-types)
   - [Validation API](#314-validation-api)
   - [Cut detection API](#315-cut-detection-api)
   - [Version conversion and save](#316-version-conversion-and-save)
   - [Timeline and export API](#317-timeline-and-export-api)
   - [Media extraction and copy](#318-media-extraction-and-copy)
   - [Timeline and export API](#319-timeline-and-export-api)
   - [XMLDocument extension API](#320-xmldocument-extension-api)
   - [XMLElement extension API](#321-xmlelement-extension-api)
   - [FinalCutPro.FCPXML model](#322-finalcutprofcpxml-model)
   - [Error types](#323-error-types)
4. [Examples](#4-examples)
   - [Open an FCPXML file](#41-open-an-fcpxml-file)
   - [List event names](#42-list-event-names)
   - [Create and add events](#43-create-and-add-events)
   - [Work with clips](#44-work-with-clips)
   - [Display clip duration](#45-display-clip-duration)
   - [Save FCPXML file](#46-save-fcpxml-file)

---

## 1. Introduction

Pipeline Neo provides a comprehensive API for parsing, creating, and manipulating FCPXML files with advanced timecode operations, async/await patterns, and robust error handling. The framework is protocol-oriented: you inject parsers, timecode converters, document managers, and error handlers to build a pipeline that fits your app. All major operations are available both synchronously and asynchronously.

Main entry points: FCPXMLService (orchestrates parse, validate, create document, time conversion, filter, save); ModularUtilities (createPipeline, createCustomPipeline, processFCPXML, processMultipleFCPXML, validateDocument, convertTimecodes); FCPXMLFileLoader (resolveFCPXMLFileURL, loadData, loadDocument, loadFCPXMLDocument, load async); FCPXMLValidator and FCPXMLDTDValidator (structural and DTD validation); FCPXMLExporter and FCPXMLBundleExporter (Timeline and FCPXMLExportAsset to FCPXML string or .fcpxmld bundle). Protocols: FCPXMLParsing, TimecodeConversion, XMLDocumentOperations, ErrorHandling, PipelineLogger. Default implementations: FCPXMLParser, TimecodeConverter, XMLDocumentManager, ErrorHandler, NoOpPipelineLogger, PrintPipelineLogger. Extensions on XMLDocument and XMLElement provide fcpx* properties and methods; use the modular overloads (e.g. addResource(_:using: documentManager)) when injecting dependencies. FinalCutPro.FCPXML wraps a document for high-level access (root, version, allEvents, allProjects).

This manual covers usage patterns, code examples, and practical workflows. For project overview, installation, and architecture, see the main [README](../README.md).

---

## 2. API and documentation

API design and preferred naming (e.g. verb-based: load(from:), parse(_:), export(timeline:...), validate(_:)) are documented in the main README.

---

## 3. Usage

### 3.1 Loading from file or bundle

Use `FCPXMLFileLoader` for any load from disk (single `.fcpxml` or `.fcpxmld` bundle). Prefer async for I/O:

```swift
let loader = FCPXMLFileLoader()
let document = try await loader.load(from: url)  // async
// or sync:
let document = try loader.loadDocument(from: url)
```

### 3.2 Basic FCPXML operations with modular architecture

```swift
import PipelineNeo

// Create a modular pipeline (default or custom), then a document, resources, and sequences.
let service = ModularUtilities.createPipeline()

// Or create a custom pipeline with optional logger
let customService = ModularUtilities.createCustomPipeline(
    parser: FCPXMLParser(),
    timecodeConverter: TimecodeConverter(),
    documentManager: XMLDocumentManager(),
    errorHandler: ErrorHandler(),
    logger: NoOpPipelineLogger()  // or PrintPipelineLogger(minimumLevel: .info)
)

// Create a new FCPXML document
let document = service.createFCPXMLDocument(version: "1.10")

// Add resources and sequences using modular operations (documentManager from XMLDocumentManager())
let documentManager = XMLDocumentManager()
let resource = XMLElement(name: "asset")
resource.setAttribute(name: "id", value: "asset1", using: documentManager)
document.addResource(resource, using: documentManager)

let sequence = XMLElement(name: "sequence")
sequence.setAttribute(name: "id", value: "seq1", using: documentManager)
document.addSequence(sequence, using: documentManager)
```

### 3.3 Time conversions with SwiftTimecode

```swift
import PipelineNeo
import SwiftTimecode

// Create converter/utility and convert between CMTime, Timecode, and FCPXML time.
let timecodeConverter = TimecodeConverter()
let utility = FCPXMLUtility(
    timecodeConverter: timecodeConverter
)

// Convert CMTime to SwiftTimecode Timecode
let cmTime = CMTime(value: 3600, timescale: 1) // 1 hour
let timecode = utility.timecode(from: cmTime, frameRate: .fps24)
print("Timecode: \(timecode?.stringValue ?? "Invalid")")

// Convert SwiftTimecode Timecode to CMTime
let newTimecode = try! Timecode(.realTime(seconds: 7200), at: .fps24) // 2 hours
let newCMTime = utility.cmTime(from: newTimecode)
print("CMTime: \(newCMTime.seconds) seconds")

// Use modular extensions for time operations
let frameDuration = CMTime(value: 1, timescale: 24)
let conformed = cmTime.conformed(toFrameDuration: frameDuration, using: timecodeConverter)
let fcpxmlTime = cmTime.fcpxmlTime(using: timecodeConverter)
```

### 3.4 Optional logging

You can inject a `PipelineLogger` into `FCPXMLService` or `FCPXMLUtility` to observe parse/load operations. Default is no-op.

```swift
let logger = PrintPipelineLogger(minimumLevel: .info)
let service = FCPXMLService(logger: logger)
// parse and load calls will log at the specified level
```

### 3.5 Working with modular XML operations

```swift
// Create elements, children, and attributes via documentManager and extensions.
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

### 3.6 Error handling with modular components

```swift
// Process FCPXML from a URL and handle success/failure via Result.
let errorHandler = ErrorHandler()

// Process FCPXML with error handling
let url = URL(fileURLWithPath: "/path/to/file.fcpxml")
let result = ModularUtilities.processFCPXML(
    from: url,
    using: service
)

switch result {
case .success(let document):
    print("Successfully parsed FCPXML")
    // Work with document
case .failure(let error):
    print("Error: \(error.localizedDescription)")
}
```

### 3.7 Advanced modular operations

```swift
// Use a custom TimecodeConverter and validate documents with the parser.
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
let validation = ModularUtilities.validateDocument(document)
if validation.isValid {
    print("Document is valid")
} else {
    print("Validation errors: \(validation.errors)")
}
```

### 3.8 Modern Swift 6 async/await operations

Pipeline Neo provides comprehensive async/await support for all operations:

```swift
import PipelineNeo

// Create a service with async capabilities and call async APIs.
let service = ModularUtilities.createPipeline()

// Asynchronously parse FCPXML files
let document = try await service.parseFCPXML(from: fileURL)
let isValid = await service.validateDocument(document)

// Asynchronously convert timecodes
let time = CMTime(value: 3600, timescale: 60000)
let frameRate = TimecodeFrameRate.fps24
let timecode = await service.timecode(from: time, frameRate: frameRate)

// Asynchronously create and manipulate documents
let newDocument = await service.createFCPXMLDocument(version: "1.10")
let documentManager = XMLDocumentManager()
newDocument.addResource(resource, using: documentManager)  // addResource is on XMLDocument extension
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

### 3.9 Concurrent operations with task groups

```swift
// Process multiple files and elements concurrently; use TaskGroup for parsing.
let urls = [url1, url2, url3, url4, url5]
let results = await ModularUtilities.processMultipleFCPXML(
    from: urls,
    using: service
)

// Convert timecodes for multiple elements concurrently
let timecodes = await ModularUtilities.convertTimecodes(
    for: elements,
    using: timecodeConverter,
    frameRate: .fps24
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

### 3.10 Async component-level operations

```swift
// Call async APIs on parser, timecode converter, and document manager.
let parser = FCPXMLParser()
let document = try await parser.parse(data)
let isValid = await parser.validate(document)
let filtered = await parser.filter(elements: elements, ofTypes: [.assetResource])

// Async timecode converter operations
let timecodeConverter = TimecodeConverter()
let timecode = await timecodeConverter.timecode(from: time, frameRate: .fps24)
let cmTime = await timecodeConverter.cmTime(from: timecode)
let conformed = await timecodeConverter.conform(time: time, toFrameDuration: frameDuration)

// Async document manager operations
let documentManager = XMLDocumentManager()
let document = await documentManager.createFCPXMLDocument(version: "1.10")
let element = await documentManager.createElement(name: "asset", attributes: ["id": "test1"])
await documentManager.addResource(element, to: document)
try await documentManager.saveDocument(document, to: url)
```

### 3.11 Modular extensions usage

```swift
// Use extensions on CMTime, XMLElement, and XMLDocument with injected utilities.
let time = CMTime(value: 3600, timescale: 60000)
let frameRate = TimecodeFrameRate.fps24

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

### 3.12 File loader API

FCPXMLFileLoader supports .fcpxml (single file) and .fcpxmld (bundle). Resolve the URL first for bundles (returns Info.fcpxml inside the bundle). Then load data, document, or FCPXML-optioned document. Prefer async load(from:) for I/O.

```swift
let loader = FCPXMLFileLoader()

// Resolve URL (for .fcpxmld returns bundle/Info.fcpxml)
let fileURL = try loader.resolveFCPXMLFileURL(from: url)

// Load raw data
let data = try loader.loadData(from: url)

// Load as XMLDocument (Foundation default options)
let doc = try loader.loadDocument(from: url)

// Load with FCPXML options (preserve whitespace, pretty print)
let fcpxmlDoc = try loader.loadFCPXMLDocument(from: url)

// Async load (preferred for I/O)
let document = try await loader.load(from: url)
```

### 3.13 FCPXML version and element types

Use FCPXMLVersion for document version (1.5–1.14). Use FCPXMLElementType for typed filtering of elements (every DTD element is represented).

```swift
// Version: create documents or validate
let version = FCPXMLVersion.default  // .v1_14
let doc = service.createFCPXMLDocument(version: version.stringValue)
try document.validateFCPXMLAgainst(version: .v1_14)

// Element types: filter elements by type
let types: [FCPXMLElementType] = [.assetResource, .sequence, .event]
let filtered = service.filterElements(elements, ofTypes: types)
let elementType = someElement.fcpxType  // FCPXMLElementType from XMLElement extension
```

### 3.14 Validation API

FCPXMLValidator performs semantic validation (root, resources, ref resolution). FCPXMLDTDValidator validates against the DTD for a given version. Both return or use ValidationResult (errors, warnings, isValid).

```swift
// Structural and reference validation
let validator = FCPXMLValidator()
let result = validator.validate(document)
if result.isValid { /* proceed */ } else {
    for err in result.errors { print(err.message) }
}

// DTD schema validation
let dtdValidator = FCPXMLDTDValidator()
let dtdResult = dtdValidator.validate(document, version: .default)
if dtdResult.isValid { /* valid */ } else {
    for err in dtdResult.errors { print(err.message) }
}
```

### 3.15 Cut detection API

Detect edit points (cuts) on the first project spine: boundary type (hard cut, transition, gap) and source relationship (same-clip vs different-clips). Use `FCPXMLService.detectCuts(in:)` or `detectCuts(inSpine:)` (sync and async). Result is `CutDetectionResult` with `editPoints: [EditPoint]`, `totalEditPoints`, `sameClipCutCount`, `differentClipsCutCount`, `hardCutCount`, `transitionCount`, `gapCutCount`. Each `EditPoint` has `index`, `timelineOffset` (FCPXML time string), `editType`, `sourceRelationship`, `transitionName`, clip names and refs.

```swift
let service = ModularUtilities.createPipeline()
let document = try service.parseFCPXML(from: data)
let result = service.detectCuts(in: document)
for point in result.editPoints {
    print("Edit \(point.index): \(point.editType) at \(point.timelineOffset), \(point.sourceRelationship)")
}
```

### 3.16 Version conversion and save

Convert an FCPXML document to a target format version (e.g. 1.14 → 1.10), then save as a single **.fcpxml** file or as a **.fcpxmld** bundle. Saving as a bundle is only supported when the document version is **1.10 or higher**; otherwise `FCPXMLBundleExportError.bundleRequiresVersion1_10OrHigher` is thrown.

```swift
let service = ModularUtilities.createPipeline()
let document = try service.parseFCPXML(from: url)

// Convert to 1.10
let converted = try service.convertToVersion(document, targetVersion: .v1_10)

// Save as single .fcpxml file
try service.saveAsFCPXML(converted, to: URL(fileURLWithPath: "/path/to/Project.fcpxml"))

// Save as .fcpxmld bundle (allowed because converted is 1.10)
let bundleURL = try service.saveAsBundle(converted, to: outputDirectory, bundleName: "My Project")
```

Use `convertToVersion(_:targetVersion:)`, `saveAsFCPXML(_:to:)`, and `saveAsBundle(_:to:bundleName:)` (sync and async). Conversion sets the root `version` attribute and returns a new document; content is otherwise preserved.

### 3.18 Media extraction and copy

Extract media references (asset `<media-rep>` `src` and `<locator>` `url`) from an FCPXML document, and optionally copy referenced file URLs to a destination directory. Use `extractMediaReferences(from:baseURL:)` to get a list of references; pass `baseURL` (e.g. the document or bundle URL) to resolve relative paths. Use `copyReferencedMedia(from:to:baseURL:)` to copy only file URLs into a folder; sources are deduplicated and destination filenames are uniquified on conflict. Results: `MediaExtractionResult` (references, baseURL, fileReferences) and `MediaCopyResult` (entries: copied, skipped, failed). Both sync and async APIs are available on `FCPXMLService` and `FCPXMLUtility`.

```swift
let service = ModularUtilities.createPipeline()
let document = try service.parseFCPXML(from: url)
let baseURL = url.deletingLastPathComponent()

// Extract references (asset media-rep and locators)
let extraction = service.extractMediaReferences(from: document, baseURL: baseURL)
for ref in extraction.references {
    if let u = ref.url { print(ref.resourceID, u, ref.isLocator) }
}

// Copy referenced files to a directory
let destDir = URL(fileURLWithPath: "/path/to/Media")
let copyResult = service.copyReferencedMedia(from: document, to: destDir, baseURL: baseURL)
for (src, dest) in copyResult.copied { print("Copied \(src.lastPathComponent) to \(dest.path)") }
for entry in copyResult.skipped { /* reason: duplicate, missing file, not file URL */ }
for entry in copyResult.failed { /* error message */ }
```

### 3.19 Timeline and export API

Build a Timeline with TimelineClip and optional TimelineFormat; provide FCPXMLExportAsset for each referenced asset; export to string or bundle with FCPXMLExporter or FCPXMLBundleExporter.

```swift
// Build timeline
let clip = TimelineClip(
    assetRef: "r2",
    offset: CMTime(value: 0, timescale: 1),
    duration: CMTime(value: 1001, timescale: 24000),
    start: .zero,
    lane: 0
)
let format = TimelineFormat.hd1080p(
    frameDuration: CMTime(value: 1001, timescale: 24000),
    colorSpace: .rec709
)
let timeline = Timeline(name: "My Timeline", format: format, clips: [clip])

// Export assets (id must match clip.assetRef)
let asset = FCPXMLExportAsset(
    id: "r2",
    name: "Clip1",
    src: URL(fileURLWithPath: "/path/to/media.mov"),
    duration: CMTime(value: 1001, timescale: 24000),
    hasVideo: true,
    hasAudio: true
)

// Export to FCPXML string
let exporter = FCPXMLExporter(version: .default)
let xmlString = try exporter.export(timeline: timeline, assets: [asset])

// Export to .fcpxmld bundle (exportBundle returns URL of created bundle)
let bundleExporter = FCPXMLBundleExporter(version: .default, includeMedia: false)
let bundleURL = try bundleExporter.exportBundle(
    timeline: timeline,
    assets: [asset],
    to: outputDirectoryURL,
    bundleName: "My Project"
)
```

### 3.20 XMLDocument extension API

XMLDocument gains FCPXML-specific properties and methods: fcpxmlString, fcpxmlVersion, fcpxEventNames, fcpxEvents, fcpxResources, fcpxLibraryElement, fcpxAllProjects, fcpxAllClips; add(events:), add(resourceElements:), resource(matchingID:), remove(resourceAtIndex:); validateFCPXMLAgainst(version:); init(contentsOfFCPXML:). Use document.addResource(_:using: documentManager) and document.addSequence(_:using: documentManager) for modular add. document.isValid(using: parser) for parser validation.

### 3.21 XMLElement extension API

XMLElement gains fcpxType, fcpxName, fcpxDuration, fcpxOffset, fcpxStart, fcpxRef, fcpxID, fcpxLane, fcpxRole, fcpxFormatRef, and many other typed attribute accessors; fcpxEvent(name:), fcpxProject(...), eventClips, eventClips(forResourceID:), addToEvent(items:), removeFromEvent(items:); fcpxResource, fcpxParentEvent, fcpxSequenceClips, fcpxAnnotations. Use element.setAttribute(name:value:using: documentManager) and element.getAttribute(name:using: documentManager) for modular attribute access. element.createChild(name:attributes:using: documentManager) for creating children.

### 3.22 FinalCutPro.FCPXML model

For a high-level wrapper around the XML document, use FinalCutPro.FCPXML: init(fileContent: Data) or init(fileContent: XMLDocument); .root (Root wrapper); .version (Version); .allEvents(), .allProjects() for event and project names. Useful for quick inspection and tests.

```swift
let data = try loader.loadData(from: url)
let fcpxml = try FinalCutPro.FCPXML(fileContent: data)
let eventNames = fcpxml.allEvents()
let projectNames = fcpxml.allProjects()
```

### 3.23 Error types

Pipeline Neo uses explicit error types: FCPXMLError (e.g. parsingFailed); FCPXMLLoadError (notAFile, readFailed); FinalCutPro.FCPXML.ParseError (general, with LocalizedError); FCPXMLExportError (missingAsset, invalidTimeline, etc.); FCPXMLBundleExportError; ValidationError and ValidationWarning (type, message, context; warning types include negativeTimeAttribute). All conform to LocalizedError where applicable. Use the ErrorHandling protocol (sync-only) and ErrorHandler to turn errors into messages, or switch on the error type in your code.

---

## 4. Examples

### 4.1 Open an FCPXML file

```swift
// Load an FCPXML file from disk and parse it into an XMLDocument.
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

### 4.2 List event names

```swift
// Read event names from the loaded FCPXML document.
let eventNames = fcpxmlDoc.fcpxEventNames
print("Event names: \(eventNames)")
```

### 4.3 Create and add events

```swift
// Create a new event element and append it to the document's library.
let newEvent = XMLElement().fcpxEvent(name: "My New Event")
fcpxmlDoc.add(events: [newEvent])
print("Updated event names: \(fcpxmlDoc.fcpxEventNames)")
```

### 4.4 Work with clips

```swift
// Find clips that reference a given resource, then remove them and the resource.
let firstEvent = fcpxmlDoc.fcpxEvents[0]
let matchingClips = try firstEvent.eventClips(forResourceID: "r1")

// Remove clips from the event.
try firstEvent.removeFromEvent(items: matchingClips)

// Remove the resource from the document.
if let resource = fcpxmlDoc.resource(matchingID: "r1") {
    fcpxmlDoc.remove(resourceAtIndex: resource.index)
}
```

### 4.5 Display clip duration

```swift
// Get the first event's first clip and display its duration as a counter string.
let firstEvent = fcpxmlDoc.fcpxEvents[0]

if let eventClips = firstEvent.eventClips, eventClips.count > 0 {
    let firstClip = eventClips[0]
    if let duration = firstClip.fcpxDuration {
        let timeDisplay = duration.timeAsCounter().counterString
        print("Duration: \(timeDisplay)")
    }
}
```

### 4.6 Save FCPXML file

```swift
// Serialise the document to FCPXML string and write it to disk.
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

---

For FCPXML format details, see [fcp.cafe/developers/fcpxml](https://fcp.cafe/developers/fcpxml). For project overview, installation, and architecture, see the main [README](../README.md).
