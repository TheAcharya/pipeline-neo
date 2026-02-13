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
   - [FCPXMLTimecode: Custom timecode type](#33b-fcpxmltimecode-custom-timecode-type)
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
   - [Experimental CLI](#316b-experimental-cli)
   - [Element extraction (presets and scope)](#317-element-extraction-presets-and-scope)
   - [Media extraction and copy](#318-media-extraction-and-copy)
   - [Timeline and export API](#319-timeline-and-export-api)
   - [Timeline manipulation: Ripple insert and auto lane](#319b-timeline-manipulation-ripple-insert-and-auto-lane)
   - [Timeline metadata and timestamps](#319c-timeline-metadata-and-timestamps)
   - [MIME type detection](#319d-mime-type-detection)
   - [Asset validation](#319e-asset-validation)
   - [Silence detection](#319f-silence-detection)
   - [Asset duration measurement](#319g-asset-duration-measurement)
   - [Parallel file I/O](#319h-parallel-file-io)
   - [Typed adjustment models](#319i-typed-adjustment-models)
   - [Typed effect and filter models](#319j-typed-effect-and-filter-models)
   - [Caption and title models](#319k-caption-and-title-models)
   - [Keyframe animation](#319l-keyframe-animation)
   - [CMTime Codable extension](#319m-cmtime-codable-extension)
   - [Collection folders and keyword collections](#319n-collection-folders-and-keyword-collections)
   - [XMLDocument extension API](#320-xmldocument-extension-api)
   - [XMLElement extension API](#321-xmlelement-extension-api)
   - [FinalCutPro.FCPXML model](#322-finalcutprofcpxml-model)
   - [Error types](#323-error-types)
   - [Progress bar (CLI)](#324-progress-bar-cli)
4. [Examples](#4-examples)
   - [Open an FCPXML file](#41-open-an-fcpxml-file)
   - [List event names](#42-list-event-names)
   - [Create and add events](#43-create-and-add-events)
   - [Work with clips](#44-work-with-clips)
   - [Display clip duration](#45-display-clip-duration)
   - [Save FCPXML file](#46-save-fcpxml-file)
   - [Complete timeline workflow](#47-complete-timeline-workflow)
   - [Validate assets before export](#48-validate-assets-before-export)

---

## 1. Introduction

Pipeline Neo provides a comprehensive API for parsing, creating, and manipulating FCPXML files with advanced timecode operations, async/await patterns, and robust error handling. The framework is protocol-oriented: you inject parsers, timecode converters, document managers, and error handlers to build a pipeline that fits your app. All major operations are available both synchronously and asynchronously.

**Main entry points:**
- **FCPXMLService** — Orchestrates parse, validate, create document, time conversion, filter, save
- **ModularUtilities** — Helper functions: `createPipeline`, `createCustomPipeline`, `processFCPXML`, `processMultipleFCPXML`, `validateDocument`, `convertTimecodes`
- **FCPXMLFileLoader** — Loads `.fcpxml` files and `.fcpxmld` bundles
- **FCPXMLValidator** and **FCPXMLDTDValidator** — Structural and DTD validation
- **FCPXMLExporter** and **FCPXMLBundleExporter** — Export Timeline to FCPXML string or `.fcpxmld` bundle

**Protocols:** `FCPXMLParsing`, `TimecodeConversion`, `XMLDocumentOperations`, `ErrorHandling`, `PipelineLogger`, `MIMETypeDetection`, `AssetValidation`, `SilenceDetection`, `AssetDurationMeasurement`, `ParallelFileIO`, `CutDetection`, `MediaExtraction`

**Default implementations:** `FCPXMLParser`, `TimecodeConverter`, `XMLDocumentManager`, `ErrorHandler`, `MIMETypeDetector`, `AssetValidator`, `SilenceDetector`, `AssetDurationMeasurer`, `ParallelFileIOExecutor`, `CutDetector`, `MediaExtractor`, `NoOpPipelineLogger`, `PrintPipelineLogger`, `FilePipelineLogger`

**Log levels:** `PipelineLogLevel` (trace, debug, info, notice, warning, error, critical)

**Extensions:** `XMLDocument` and `XMLElement` provide `fcpx*` properties and methods; use modular overloads (e.g. `addResource(_:using: documentManager)`) when injecting dependencies.

**High-level model:** `FinalCutPro.FCPXML` wraps a document for high-level access (root, version, allEvents, allProjects).

This manual covers usage patterns, code examples, and practical workflows. For project overview, installation, and architecture, see the main [README](../README.md).

---

## 2. API and documentation

API design and preferred naming (e.g. verb-based: `load(from:)`, `parse(_:)`, `export(timeline:...)`, `validate(_:)`) are documented in the main README.

---

## 3. Usage

### 3.1 Loading from file or bundle

Use `FCPXMLFileLoader` for any load from disk (single `.fcpxml` or `.fcpxmld` bundle). Prefer async for I/O:

```swift
let loader = FCPXMLFileLoader()

// Async load (preferred for I/O)
let document = try await loader.load(from: url)

// Or sync:
let document = try loader.loadDocument(from: url)
```

**Example: Loading a bundle**

```swift
let bundleURL = URL(fileURLWithPath: "/path/to/Project.fcpxmld")
let loader = FCPXMLFileLoader()

// Resolve URL (for .fcpxmld returns bundle/Info.fcpxml)
let fileURL = try loader.resolveFCPXMLFileURL(from: bundleURL)

// Load with FCPXML options (preserve whitespace, pretty print)
let document = try await loader.load(from: bundleURL)
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
    logger: PrintPipelineLogger(minimumLevel: .info)
)

// Create a new FCPXML document
let document = service.createFCPXMLDocument(version: "1.10")

// Add resources and sequences using modular operations
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

### 3.3b FCPXMLTimecode: Custom timecode type

Pipeline Neo provides `FCPXMLTimecode`, a custom timecode type optimized for FCPXML operations. It wraps SwiftTimecode's `Fraction` type and provides convenient FCPXML-specific operations.

```swift
import PipelineNeo

// Create from seconds
let fiveSeconds = FCPXMLTimecode(seconds: 5.0)
print(fiveSeconds.fcpxmlString) // "5s"

// Create from rational value (value/timescale)
let oneFrame = FCPXMLTimecode(value: 1001, timescale: 30000)
print(oneFrame.fcpxmlString) // "1001/30000s"

// Create from CMTime
let cmTime = CMTime(value: 1001, timescale: 30000)
let timecode = FCPXMLTimecode(cmTime: cmTime)

// Create from frames and frame rate
let tenFrames = FCPXMLTimecode(frames: 10, frameRate: .fps24)
print(tenFrames.seconds) // Approximately 0.4167 seconds

// Parse from FCPXML string
let parsed = FCPXMLTimecode(fcpxmlString: "1001/30000s")
print(parsed?.value) // 1001
print(parsed?.timescale) // 30000

// Arithmetic operations
let clip1Duration = FCPXMLTimecode(seconds: 5.0)
let clip2Duration = FCPXMLTimecode(seconds: 3.0)
let totalDuration = clip1Duration + clip2Duration
print(totalDuration.seconds) // 8.0

let doubled = clip1Duration * 2
print(doubled.seconds) // 10.0

// Comparison
let time1 = FCPXMLTimecode(seconds: 5.0)
let time2 = FCPXMLTimecode(seconds: 3.0)
print(time1 > time2) // true

// Convert to CMTime
let cmTime = timecode.toCMTime()

// Frame alignment
let aligned = FCPXMLTimecode.frameAligned(seconds: 0.6, frameRate: .fps24)
// Rounds to nearest frame boundary

let alignedTimecode = timecode.aligned(to: .fps24)
// Aligns existing timecode to frame boundaries
```

**Use cases:**
- Working with FCPXML time strings directly
- Frame-accurate time calculations
- Converting between different time representations
- Frame alignment for FCPXML export

### 3.4 Optional logging

You can inject a `PipelineLogger` into `FCPXMLService` or `FCPXMLUtility` to observe parse, conversion, validation, save, and media operations. Default is no-op.

**Log levels** (from most to least verbose): `trace`, `debug`, `info`, `notice`, `warning`, `error`, `critical`. Use `PipelineLogLevel.from(string:)` to parse a level from a string.

**Implementations:**

- **NoOpPipelineLogger** — No output (default when no logger is injected).
- **PrintPipelineLogger** — Writes to stdout with a level prefix; set `minimumLevel` to control verbosity.
- **FilePipelineLogger** — Writes to a file (and optionally to console); supports `minimumLevel`, `fileURL`, `alsoPrint`, and `quiet`. Thread-safe; uses a serial queue for file writes. Use for CLI or when you need persistent logs.

```swift
// Console only, info and above
let logger = PrintPipelineLogger(minimumLevel: .info)
let service = FCPXMLService(logger: logger)

// File and console, debug and above
let fileLogger = FilePipelineLogger(
    minimumLevel: .debug,
    fileURL: URL(fileURLWithPath: "/tmp/pipeline.log"),
    alsoPrint: true,
    quiet: false
)
let serviceWithFile = FCPXMLService(logger: fileLogger)

// No output
let noOp = NoOpPipelineLogger()
let quietService = FCPXMLService(logger: noOp)
```

The service logs parsing (from data or URL), version conversion, DTD validation, save operations, media reference extraction, and media copy results. Use `--log`, `--log-level`, and `--quiet` in the CLI to control logging from the command line (see [Experimental CLI](#316b-experimental-cli)).

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
newDocument.addResource(resource, using: documentManager)
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

FCPXMLFileLoader supports `.fcpxml` (single file) and `.fcpxmld` (bundle). Resolve the URL first for bundles (returns Info.fcpxml inside the bundle). Then load data, document, or FCPXML-optioned document. Prefer async `load(from:)` for I/O.

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

Use `FCPXMLVersion` for document version (1.5–1.14). Use `FCPXMLElementType` for typed filtering of elements (every DTD element is represented). `FCPXMLVersion.supportsBundleFormat` is `true` for 1.10 and later (`.fcpxmld` bundle); 1.5–1.9 support only single-file `.fcpxml`.

```swift
// Version: create documents or validate
let version = FCPXMLVersion.default  // .v1_14
let doc = service.createFCPXMLDocument(version: version.stringValue)
try document.validateFCPXMLAgainst(version: .v1_14)
if version.supportsBundleFormat { /* can save as .fcpxmld */ }

// Element types: filter elements by type
let types: [FCPXMLElementType] = [.assetResource, .sequence, .event]
let filtered = service.filterElements(elements, ofTypes: types)
let elementType = someElement.fcpxType  // FCPXMLElementType from XMLElement extension
```

### 3.14 Validation API

FCPXMLValidator performs semantic validation (root, resources, ref resolution). Refs are resolved against all element IDs in the document (including e.g. `text-style-def` inside titles/captions), not only top-level resources. FCPXMLDTDValidator validates against the DTD for a given version. FCPXMLService provides per-version DTD validation: `validateDocumentAgainstDTD(_:version:)` validates against a specific FCPXML version (1.5–1.14); `validateDocumentAgainstDeclaredVersion(_:)` reads the document's root version attribute and validates against that DTD (returns errors if version is missing or unsupported). For a single robust check combining both, use `performValidation(_:)` which returns a `DocumentValidationReport` (semantic + DTD; `report.isValid` is true only when both pass). All return or use `ValidationResult` (errors, warnings, isValid).

```swift
// Structural and reference validation
let validator = FCPXMLValidator()
let result = validator.validate(document)
if result.isValid { /* proceed */ } else {
    for err in result.errors { print(err.message) }
}

// DTD schema validation (standalone)
let dtdValidator = FCPXMLDTDValidator()
let dtdResult = dtdValidator.validate(document, version: .default)
if dtdResult.isValid { /* valid */ } else {
    for err in dtdResult.errors { print(err.message) }
}

// Per-version DTD validation via service (e.g. after convert or for any version)
let service = FCPXMLService()
let resultFor1_10 = service.validateDocumentAgainstDTD(document, version: .v1_10)
let resultDeclared = service.validateDocumentAgainstDeclaredVersion(document)

// Robust validation (semantic + DTD in one call)
let report = service.performValidation(document)
if report.isValid { /* proceed */ } else {
    print(report.summary)
    print(report.detailedDescription)
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

Convert an FCPXML document to a target format version (e.g. 1.14 → 1.10), then save as a single **.fcpxml** file or as a **.fcpxmld** bundle. Conversion (FCPXMLVersionConverter) sets the root `version` attribute and **automatically removes elements not in the target version's DTD** (e.g. adjust-colorConform, adjust-stereo-3D), similar to Capacitor, so the output validates and imports in Final Cut Pro. Saving as a bundle is only supported when the document version is **1.10 or higher**; otherwise `FCPXMLBundleExportError.bundleRequiresVersion1_10OrHigher` is thrown.

```swift
let service = ModularUtilities.createPipeline()
let document = try service.parseFCPXML(from: url)

// Convert to 1.10 (strips elements not in 1.10 DTD)
let converted = try service.convertToVersion(document, targetVersion: .v1_10)

// Optionally validate against target DTD before save
let validation = service.validateDocumentAgainstDTD(converted, version: .v1_10)
guard validation.isValid else { /* handle errors */ }

// Save as single .fcpxml file
try service.saveAsFCPXML(converted, to: URL(fileURLWithPath: "/path/to/Project.fcpxml"))

// Save as .fcpxmld bundle (allowed because converted is 1.10)
let bundleURL = try service.saveAsBundle(converted, to: outputDirectory, bundleName: "My Project")
```

Use `convertToVersion(_:targetVersion:)`, `saveAsFCPXML(_:to:)`, and `saveAsBundle(_:to:bundleName:)` (sync and async).

### 3.16b Experimental CLI

The package includes an experimental command-line tool, `pipeline-neo`, for inspecting and converting FCPXML files and .fcpxmld bundles. It is a **single binary**: FCPXML DTDs (1.5–1.14) are embedded in the executable, so you can copy `pipeline-neo` to any directory (including external storage) and run it without a resource bundle. Build with `swift build` (or use the PipelineNeoCLI scheme in Xcode); run with `swift run pipeline-neo --help`. Help groups options under **GENERAL**, **EXTRACTION** (e.g. `--media-copy`), and **LOG**.

**General options:**

- **--check-version** — Load the FCPXML at the given path and print its document version. Does not require an output directory.
- **--convert-version &lt;VERSION&gt;** — Load the FCPXML, convert to the target version (1.5–1.14) with automatic element stripping and DTD validation, and save to the output directory. Output format is controlled by **--extension-type**: default is **.fcpxmld** (bundle) for target versions 1.10 and higher; for target versions 1.5–1.9 the output is always **.fcpxml** (single file), since the bundle format is not supported for those versions. Fails if the converted document does not pass DTD validation.
- **--extension-type &lt;fcpxml|fcpxmld&gt;** — Output format for `--convert-version`: `fcpxmld` (bundle, default) or `fcpxml` (single file). For target versions 1.5–1.9, `.fcpxml` is always used regardless of this option.
- **--validate** — Load the FCPXML or FCPXMLD at the given path and perform robust validation: semantic (root, resources, ref resolution) and DTD (against the document's declared version). Shows a progress indicator when not using `--quiet`. Prints a summary and, if invalid, full error/warning details. Does not require an output directory. Exits with a non-zero code when validation fails.
- **--media-copy** — Load the FCPXML or FCPXMLD at the given path, scan for all referenced media (asset media-rep and locator file URLs), and copy those files to the output directory. Shows a progress bar when not using `--quiet`. Reports how many media files were detected by type (video, audio, images) and prints a success message when copying completes. Prints each destination path to stdout; prints "Media detected: X video, Y audio, Z images (N total)" and "Successfully copied N media file(s) to &lt;path&gt;" (or errors) to stderr. Exits with an error if any copy failed.

**Log options:**

- **--log &lt;path&gt;** — Append log output to this file. When set, all CLI commands (check-version, convert-version, validate, media-copy) write their user-visible messages (version, write path, validation summary, media detected/copied, errors) to the log file in addition to library-level logs. Also prints to the console unless `--quiet` is set.
- **--log-level &lt;level&gt;** — Minimum log level: `trace`, `debug`, `info`, `notice`, `warning`, `error`, or `critical`. Default: `info`.
- **--quiet** — Disable all log output.

Example: `pipeline-neo --convert-version 1.10 /path/to/project.fcpxml /path/to/output-dir`  
Example: `pipeline-neo --convert-version 1.14 --extension-type fcpxmld /path/to/project.fcpxmld /path/to/output-dir`  
Example: `pipeline-neo --convert-version 1.9 /path/to/project.fcpxml /path/to/output-dir` (output is always .fcpxml)  
Example: `pipeline-neo --validate /path/to/project.fcpxmld`  
Example: `pipeline-neo --media-copy /path/to/project.fcpxmld /path/to/media-folder`  
Example: `pipeline-neo --log /tmp/pipeline.log --log-level debug --check-version /path/to/project.fcpxml`

For full CLI usage, options, and how to extend it, see [PipelineNeoCLI/README.md](../Sources/PipelineNeoCLI/README.md). To regenerate the embedded DTD source after changing `Sources/PipelineNeo/FCPXML DTDs/`, run `./Scripts/generate_embedded_dtds.sh` or `swift run GenerateEmbeddedDTDs` from the package root, then rebuild.

### 3.17 Element extraction (presets and scope)

Extract elements from an FCPXML tree by type or using presets. Use `FinalCutPro.FCPXML.ExtractionScope` to control scope (e.g. `.mainTimeline`); you can constrain to a local timeline, set max container depth, filter auditions/multicam angles, and include or exclude element types. **FCPXMLExtractionPreset** defines a preset that returns typed results; built-in presets include **CaptionsExtractionPreset**, **MarkersExtractionPreset**, **RolesExtractionPreset**, and **FrameDataPreset**. Call `extract(types:scope:)` on an `FCPXMLElement` (or `fcpExtract(types:scope:)` on `XMLElement`) to get `[FinalCutPro.FCPXML.ExtractedElement]`; call `extract(preset:scope:)` to get a preset's result type. These APIs are async.

```swift
let element: FCPXMLElement = // ... e.g. from document
let scope = FinalCutPro.FCPXML.ExtractionScope.mainTimeline

// Extract by element types
let extracted = await element.extract(
    types: [.marker, .chapter],
    scope: scope
)

// Extract using a preset (e.g. markers with typed result)
let markersResult = await element.extract(
    preset: FinalCutPro.FCPXML.MarkersExtractionPreset(),
    scope: scope
)
```

### 3.18 Media extraction and copy

Extract media references (asset `<media-rep>` `src` and `<locator>` `url`) from an FCPXML document, and optionally copy referenced file URLs to a destination directory. Use `extractMediaReferences(from:baseURL:)` to get a list of references; pass `baseURL` (e.g. the document or bundle URL) to resolve relative paths. Use `copyReferencedMedia(from:to:baseURL:progress:)` to copy only file URLs into a folder; pass an optional `ProgressReporter` (e.g. `ProgressBar`) for CLI-style progress. Sources are deduplicated and destination filenames are uniquified on conflict. Results: `MediaExtractionResult` (references, baseURL, fileReferences) and `MediaCopyResult` (entries: copied, skipped, failed). Both sync and async APIs are available on `FCPXMLService` and `FCPXMLUtility`.

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
let copyResult = service.copyReferencedMedia(from: document, to: destDir, baseURL: baseURL, progress: nil)
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

### 3.19b Timeline manipulation: Ripple insert and auto lane

Pipeline Neo provides advanced timeline manipulation features for inserting clips with automatic shifting (ripple insert) and automatic lane assignment.

**Ripple Insert**

When inserting a clip, subsequent clips can be automatically shifted forward:

```swift
var timeline = Timeline(name: "My Timeline")

// Add initial clips
let clip1 = TimelineClip(
    assetRef: "r1",
    offset: CMTime(value: 0, timescale: 1),
    duration: CMTime(value: 10, timescale: 1),
    lane: 0
)
let clip2 = TimelineClip(
    assetRef: "r2",
    offset: CMTime(value: 10, timescale: 1),
    duration: CMTime(value: 10, timescale: 1),
    lane: 0
)
timeline.clips = [clip1, clip2]

// Insert a new clip at 5 seconds with ripple (shifts clip2 forward)
let newClip = TimelineClip(
    assetRef: "r3",
    offset: .zero,
    duration: CMTime(value: 5, timescale: 1),
    lane: 0
)

// Immutable version (returns new timeline)
let (updatedTimeline, result) = timeline.insertingClipWithRipple(
    newClip,
    at: CMTime(value: 5, timescale: 1),
    lane: 0,
    rippleLanes: .primaryOnly  // Only shift clips on lane 0
)

// Or mutating version
timeline.insertClipWithRipple(
    newClip,
    at: CMTime(value: 5, timescale: 1),
    lane: 0,
    rippleLanes: .primaryOnly
)

// Result contains information about shifted clips
print("Inserted clip at: \(result.insertedClip.offset)")
print("Shifted \(result.shiftedClips.count) clips")
for shift in result.shiftedClips {
    print("Clip at index \(shift.clipIndex) moved from \(shift.originalOffset) to \(shift.newOffset)")
}
```

**Ripple Lane Options:**

- `.all` — Ripple all lanes
- `.single(Int)` — Ripple only a specific lane
- `.range(ClosedRange<Int>)` — Ripple a range of lanes
- `.primaryOnly` — Ripple only lane 0 (default)

**Auto Lane Assignment**

Automatically find an available lane when inserting a clip:

```swift
var timeline = Timeline(name: "My Timeline")

// Add a clip on lane 0
let clip1 = TimelineClip(
    assetRef: "r1",
    offset: CMTime(value: 0, timescale: 1),
    duration: CMTime(value: 10, timescale: 1),
    lane: 0
)
timeline.clips = [clip1]

// Try to insert at the same time on lane 0
let newClip = TimelineClip(
    assetRef: "r2",
    offset: .zero,
    duration: CMTime(value: 5, timescale: 1),
    lane: 0
)

// Immutable version (returns new timeline and placement)
let (updatedTimeline, placement) = try timeline.insertingClipAutoLane(
    newClip,
    at: CMTime(value: 0, timescale: 1),
    preferredLane: 0,
    autoAssignLane: true  // Automatically assign lane 1 if lane 0 is occupied
)

// Or mutating version
try timeline.insertClipAutoLane(
    newClip,
    at: CMTime(value: 0, timescale: 1),
    preferredLane: 0,
    autoAssignLane: true
)

print("Clip placed on lane: \(placement.lane)")

// Find available lane manually
let availableLane = timeline.findAvailableLane(
    at: CMTime(value: 0, timescale: 1),
    duration: CMTime(value: 5, timescale: 1),
    startingFrom: 0
)
```

**Clip Queries**

Query clips by various criteria:

```swift
let timeline = Timeline(name: "My Timeline", clips: clips)

// Get all clips on a specific lane
let lane0Clips = timeline.clips(onLane: 0)

// Get clips in a time range
let clipsInRange = timeline.clips(
    inRange: start: CMTime(value: 10, timescale: 1),
    end: CMTime(value: 20, timescale: 1)
)

// Get clips referencing a specific asset
let assetClips = timeline.clips(withAssetRef: "r1")

// Get lane range (min and max lanes used)
if let laneRange = timeline.laneRange {
    print("Lanes used: \(laneRange.lowerBound) to \(laneRange.upperBound)")
}
```

### 3.19c Timeline metadata and timestamps

Timelines support rich metadata and track creation/modification times.

**Timestamps**

```swift
// Create timeline with automatic timestamps
var timeline = Timeline(name: "My Timeline")
print("Created: \(timeline.createdAt)")
print("Modified: \(timeline.modifiedAt)")

// Create with custom timestamps
let createdAt = Date(timeIntervalSince1970: 1000)
let timeline2 = Timeline(
    name: "My Timeline",
    createdAt: createdAt,
    modifiedAt: createdAt
)

// Timestamps are automatically updated on mutations
timeline.addMarker(Marker(start: CMTime(value: 5, timescale: 1), value: "Marker"))
// modifiedAt is now updated to current time
```

**Metadata**

```swift
var timeline = Timeline(name: "My Timeline")

// Add markers
let marker = Marker(start: CMTime(value: 5, timescale: 1), value: "Important moment")
timeline.addMarker(marker)

// Add chapter markers
let chapter = ChapterMarker(start: CMTime(value: 0, timescale: 1), value: "Chapter 1")
timeline.addChapterMarker(chapter)

// Add keywords
let keyword = Keyword(
    start: CMTime(value: 0, timescale: 1),
    duration: CMTime(value: 10, timescale: 1),
    value: "Action"
)
timeline.addKeyword(keyword)

// Add ratings
let rating = Rating(
    start: CMTime(value: 0, timescale: 1),
    duration: CMTime(value: 10, timescale: 1),
    value: .favorite
)
timeline.addRating(rating)

// Add custom metadata
var metadata = Metadata()
metadata.setCameraName("Camera A")
metadata.setScene("Scene 1")
timeline.metadata = metadata

// Get sorted metadata
let sortedMarkers = timeline.sortedMarkers
let sortedChapters = timeline.sortedChapterMarkers
```

**Clip Metadata**

Clips also support metadata:

```swift
var clip = TimelineClip(
    assetRef: "r1",
    offset: .zero,
    duration: CMTime(value: 10, timescale: 1),
    lane: 0
)

// Add markers to clip
clip.addMarker(Marker(start: CMTime(value: 2, timescale: 1), value: "Clip marker"))

// Add keywords, ratings, etc.
clip.addKeyword(keyword)
clip.addRating(rating)
```

### 3.19d MIME type detection

Pipeline Neo provides comprehensive MIME type detection using UTType and AVFoundation.

```swift
import PipelineNeo

let detector = MIMETypeDetector()

// Detect MIME type synchronously
let url = URL(fileURLWithPath: "/path/to/video.mp4")
let mimeType = detector.detectMIMETypeSync(at: url)
print(mimeType) // "video/mp4"

// Detect MIME type asynchronously (uses AVFoundation for media files)
let mimeTypeAsync = await detector.detectMIMEType(at: url)

// Supported formats:
// Video: mp4, mov, avi, mkv, mpg, mpeg, webm, flv
// Audio: mp3, m4a, aac, wav, aiff, caf, flac, ogg, opus
// Image: jpg, jpeg, png, gif, tiff, heic, heif, webp, bmp, svg
```

**Custom MIME Type Detector**

```swift
// Create custom detector implementing MIMETypeDetection protocol
struct CustomMIMEDetector: MIMETypeDetection {
    func detectMIMEType(at url: URL) async -> String? {
        // Custom detection logic
        return "custom/type"
    }
}

let customDetector = CustomMIMEDetector()
let mimeType = await customDetector.detectMIMEType(at: url)
```

### 3.19e Asset validation

Validate assets for existence and MIME type compatibility with lanes.

```swift
import PipelineNeo

let validator = AssetValidator()

// Validate asset for a specific lane
let url = URL(fileURLWithPath: "/path/to/audio.mp3")
let result = await validator.validateAsset(
    at: url,
    forLane: -1,  // Negative lanes = audio only
    mimeTypeDetector: nil  // Uses default MIMETypeDetector
)

if result.isValid {
    print("Asset is valid: \(result.mimeType ?? "unknown")")
} else {
    print("Validation failed: \(result.reason ?? "unknown error")")
}

// Lane compatibility rules:
// - Negative lanes (< 0): Must be audio/* MIME type
// - Non-negative lanes (>= 0): Can be video/*, image/*, or audio/*
```

**TimelineClip Integration**

```swift
var clip = TimelineClip(
    assetRef: "r1",
    offset: .zero,
    duration: CMTime(value: 10, timescale: 1),
    lane: -1  // Audio lane
)

let audioURL = URL(fileURLWithPath: "/path/to/audio.mp3")

// Validate asset for this clip's lane
let result = await clip.validateAsset(at: audioURL)
if result.isValid {
    print("Audio asset is valid for lane \(clip.lane)")
}

// Check asset type
let isAudio = await clip.isAudioAsset(at: audioURL)
let isVideo = await clip.isVideoAsset(at: audioURL)
let isImage = await clip.isImageAsset(at: audioURL)
```

**Synchronous Validation**

```swift
let result = validator.validateAssetSync(
    at: url,
    forLane: 0,
    mimeTypeDetector: nil
)
```

### 3.19f Silence detection

Detect silence in audio files for trimming or analysis.

```swift
import PipelineNeo
#if canImport(AVFoundation)
import AVFoundation
#endif

let detector = SilenceDetector()

// Detect silence asynchronously
let audioURL = URL(fileURLWithPath: "/path/to/audio.wav")
let result = await detector.detectSilence(
    at: audioURL,
    threshold: -60.0,  // dB threshold (default: -60)
    minimumDuration: 0.1  // Minimum silence duration in seconds (default: 0.1)
)

print("Silence detected: \(result.hasSilence)")
if result.hasSilence {
    print("Silence at start: \(result.silenceAtStart) seconds")
    print("Silence at end: \(result.silenceAtEnd) seconds")
    print("Total silence: \(result.totalSilenceDuration) seconds")
}

// Synchronous detection
let syncResult = detector.detectSilenceSync(
    at: audioURL,
    threshold: -60.0,
    minimumDuration: 0.1
)
```

**Custom Silence Detector**

```swift
struct CustomSilenceDetector: SilenceDetection {
    func detectSilence(
        at url: URL,
        threshold: Float,
        minimumDuration: TimeInterval
    ) async throws -> SilenceDetectionResult {
        // Custom silence detection logic
        return SilenceDetectionResult(
            hasSilence: false,
            silenceAtStart: 0,
            silenceAtEnd: 0,
            totalSilenceDuration: 0
        )
    }
}
```

### 3.19g Asset duration measurement

Measure the actual duration of media assets (audio, video, images).

```swift
import PipelineNeo
#if canImport(AVFoundation)
import AVFoundation
#endif

let measurer = AssetDurationMeasurer()

// Measure duration asynchronously
let url = URL(fileURLWithPath: "/path/to/video.mov")
let result = try await measurer.measureDuration(at: url)

print("Media type: \(result.mediaType)")  // .audio, .video, .image, .unknown
if let duration = result.duration {
    print("Duration: \(duration) seconds")
} else {
    print("No duration (image or measurement failed)")
}

// Check if asset has duration
if result.hasDuration {
    print("Asset has measurable duration")
}

// Check if asset is an image
if result.isImage {
    print("Asset is a static image")
}

// Synchronous measurement
let syncResult = try measurer.measureDurationSync(at: url)
```

**Media Types**

- `.audio` — Audio media (has duration)
- `.video` — Video media (has duration)
- `.image` — Image media (no duration, static)
- `.unknown` — Unknown or unsupported media type

### 3.19h Parallel file I/O

Perform parallel read and write operations for improved performance.

```swift
import PipelineNeo

let executor = ParallelFileIOExecutor()

// Write multiple files in parallel
let filesToWrite: [(URL, Data)] = [
    (URL(fileURLWithPath: "/path/to/file1.txt"), Data("content1".utf8)),
    (URL(fileURLWithPath: "/path/to/file2.txt"), Data("content2".utf8)),
    (URL(fileURLWithPath: "/path/to/file3.txt"), Data("content3".utf8))
]

let writeResult = await executor.writeFiles(filesToWrite)
print("Written: \(writeResult.successCount)")
print("Failed: \(writeResult.failureCount)")
for (url, error) in writeResult.failures {
    print("Failed to write \(url.path): \(error.localizedDescription)")
}

// Read multiple files in parallel
let urlsToRead = [
    URL(fileURLWithPath: "/path/to/file1.txt"),
    URL(fileURLWithPath: "/path/to/file2.txt"),
    URL(fileURLWithPath: "/path/to/file3.txt")
]

let readResult = await executor.readFiles(urlsToRead)
print("Read: \(readResult.successCount)")
print("Failed: \(readResult.failureCount)")
for (url, data) in readResult.successes {
    print("Read \(url.path): \(data.count) bytes")
}
```

**Configuration**

```swift
// Configure executor
let executor = ParallelFileIOExecutor(
    maxConcurrentOperations: 4,  // Default: number of CPU cores
    useFileHandleOptimization: true  // Default: true for better performance
)
```

### 3.19i Typed adjustment models

Pipeline Neo provides typed models for all major FCPXML adjustments, enabling type-safe manipulation of clip adjustments:

**Available Adjustment Models:**
- `CropAdjustment` — Crop, trim, and pan modes
- `TransformAdjustment` — Position, scale, rotation, anchor
- `BlendAdjustment` — Blend amount and mode
- `StabilizationAdjustment` — Stabilization type (automatic, inertiaCam, smoothCam)
- `VolumeAdjustment` — Volume level
- `LoudnessAdjustment` — Loudness parameters
- `NoiseReductionAdjustment` — Noise reduction amount
- `HumReductionAdjustment` — Hum reduction frequency (50Hz, 60Hz)
- `EqualizationAdjustment` — EQ modes (flat, voiceEnhance, musicEnhance, loudness, humReduction, bassBoost, bassReduce, trebleBoost, trebleReduce) with parameters
- `MatchEqualizationAdjustment` — Match EQ with keyed data
- `Transform360Adjustment` — 360° video transform with coordinate types (spherical, cartesian)

**Usage Example:**

```swift
import PipelineNeo
import CoreMedia
import SwiftTimecode

// Access adjustments from a clip
var clip = FinalCutPro.FCPXML.Clip(duration: Fraction(5, 1))

// Set Transform360 adjustment
var transform360 = FinalCutPro.FCPXML.Transform360Adjustment(
    coordinateType: .spherical,
    isEnabled: true,
    autoOrient: true
)
transform360.latitude = 45.0
transform360.longitude = 90.0
clip.transform360Adjustment = transform360

// Set audio enhancement adjustments
var noiseReduction = FinalCutPro.FCPXML.NoiseReductionAdjustment(amount: 0.5)
clip.noiseReductionAdjustment = noiseReduction

var equalization = FinalCutPro.FCPXML.EqualizationAdjustment(
    mode: .voiceEnhance,
    parameters: []
)
clip.equalizationAdjustment = equalization

// All adjustments are Codable and can be serialized
let encoder = JSONEncoder()
let data = try encoder.encode(transform360)
```

### 3.19j Typed effect and filter models

Pipeline Neo provides typed models for video/audio filters and effects with full parameter support:

**Available Models:**
- `VideoFilter` — Video filters with parameters
- `AudioFilter` — Audio filters with parameters
- `VideoFilterMask` — Filter masks with shape and isolation
- `FilterParameter` — Parameters with fade in/out and keyframe animation support

**Usage Example:**

```swift
import PipelineNeo
import CoreMedia
import SwiftTimecode

// Create a video filter with parameters
var filter = FinalCutPro.FCPXML.VideoFilter(name: "Color Correction")
filter.parameters = [
    FinalCutPro.FCPXML.FilterParameter(name: "Brightness", value: "1.0"),
    FinalCutPro.FCPXML.FilterParameter(name: "Contrast", value: "1.2")
]

// Access filters from a clip
var clip = FinalCutPro.FCPXML.Clip(duration: Fraction(5, 1))
clip.videoFilters = [filter]

// All filter models are Codable
let encoder = JSONEncoder()
let data = try encoder.encode(filter)
```

### 3.19k Caption and title models

Pipeline Neo provides enhanced Caption and Title models with typed text style support:

**Available Models:**
- `Caption` — Closed captions with typed text style definitions
- `Title` — Title clips with typed text style definitions
- `TextStyle` — Text formatting (font, color, alignment, shadows, etc.)
- `TextStyleDefinition` — Reusable text style definitions

**Usage Example:**

```swift
import PipelineNeo
import SwiftTimecode

// Create a caption with text style
var caption = FinalCutPro.FCPXML.Caption(duration: Fraction(5, 1))

var textStyle = FinalCutPro.FCPXML.TextStyle()
textStyle.font = "Helvetica"
textStyle.fontSize = 24
textStyle.fontColor = "1.0 1.0 1.0 1.0"
textStyle.isBold = true
textStyle.alignment = .center

let styleDef = FinalCutPro.FCPXML.TextStyleDefinition(
    id: "ts1",
    name: "Caption Style",
    textStyles: [textStyle]
)

caption.typedTextStyleDefinitions = [styleDef]

// Create a title with text style
var title = FinalCutPro.FCPXML.Title(ref: "r1", duration: Fraction(10, 1))

var titleTextStyle = FinalCutPro.FCPXML.TextStyle()
titleTextStyle.font = "Helvetica"
titleTextStyle.fontSize = 48
titleTextStyle.fontColor = "1.0 1.0 0.0 1.0"
titleTextStyle.alignment = .center

let titleStyleDef = FinalCutPro.FCPXML.TextStyleDefinition(
    id: "ts2",
    name: "Title Style",
    textStyles: [titleTextStyle]
)

title.typedTextStyleDefinitions = [titleStyleDef]
```

### 3.19l Keyframe animation

Pipeline Neo provides typed models for keyframe animations, fade in/out effects, and parameter animations:

**Available Models:**
- `KeyframeAnimation` — Animation curves with keyframes
- `Keyframe` — Individual keyframe points with interpolation and curve types
- `FadeIn` — Fade in effects with fade types
- `FadeOut` — Fade out effects with fade types
- `FadeType` — Fade type enum (linear, easeIn, easeOut, easeInOut)
- `KeyframeInterpolation` — Interpolation modes (linear, ease, easeIn, easeOut)
- `KeyframeCurve` — Curve types (linear, smooth)

**Usage Example:**

```swift
import PipelineNeo
import CoreMedia

// Create a fade in effect
let fadeIn = FinalCutPro.FCPXML.FadeIn(
    type: .easeIn,
    duration: CMTime(seconds: 1.0, preferredTimescale: 600)
)

// Create a fade out effect
let fadeOut = FinalCutPro.FCPXML.FadeOut(
    type: .easeOut,
    duration: CMTime(seconds: 1.0, preferredTimescale: 600)
)

// Create keyframe animation
let keyframe1 = FinalCutPro.FCPXML.Keyframe(
    time: CMTime(seconds: 0.0, preferredTimescale: 600),
    value: "0.0",
    interpolation: .linear,
    curve: .smooth
)

let keyframe2 = FinalCutPro.FCPXML.Keyframe(
    time: CMTime(seconds: 1.0, preferredTimescale: 600),
    value: "1.0",
    interpolation: .ease,
    curve: .smooth
)

let animation = FinalCutPro.FCPXML.KeyframeAnimation(
    keyframes: [keyframe1, keyframe2]
)

// Use with filter parameters
let parameter = FinalCutPro.FCPXML.FilterParameter(
    name: "Opacity",
    fadeIn: fadeIn,
    fadeOut: fadeOut,
    keyframeAnimation: animation
)

// All animation models are Codable
let encoder = JSONEncoder()
let data = try encoder.encode(animation)
```

### 3.19m CMTime Codable extension

Pipeline Neo provides a Codable extension for CMTime, enabling direct encoding/decoding as FCPXML time strings:

**Usage Example:**

```swift
import PipelineNeo
import CoreMedia

// CMTime is now Codable
let time = CMTime(seconds: 5.0, preferredTimescale: 600)

// Encode to JSON (as FCPXML time string)
let encoder = JSONEncoder()
let data = try encoder.encode(time)
// Encodes as: "3000/600s"

// Decode from JSON (from FCPXML time string)
let decoder = JSONDecoder()
let decoded = try decoder.decode(CMTime.self, from: data)

// Works with any Codable container
struct AnimationData: Codable {
    let duration: CMTime
    let startTime: CMTime
}

let animation = AnimationData(
    duration: CMTime(seconds: 2.0, preferredTimescale: 600),
    startTime: CMTime(seconds: 0.0, preferredTimescale: 600)
)

let animationData = try encoder.encode(animation)
```

### 3.19n Collection folders and keyword collections

Pipeline Neo provides typed models for organizing clips and media using collection folders and keyword collections:

**Available Models:**
- `CollectionFolder` — Container for organizing collections (supports nested folders)
- `KeywordCollection` — Keyword-based collection for organizing clips

**Usage Example:**

```swift
import PipelineNeo

// Create keyword collections
let keywords1 = FinalCutPro.FCPXML.KeywordCollection(name: "Action Scenes")
let keywords2 = FinalCutPro.FCPXML.KeywordCollection(name: "Dialogue")

// Create nested collection folders
let subfolder = FinalCutPro.FCPXML.CollectionFolder(
    name: "Subfolder",
    keywordCollections: [keywords1]
)

let parentFolder = FinalCutPro.FCPXML.CollectionFolder(
    name: "My Project",
    collectionFolders: [subfolder],
    keywordCollections: [keywords2]
)

// All collection models are Codable
let encoder = JSONEncoder()
let data = try encoder.encode(parentFolder)
```

### 3.20 XMLDocument extension API

XMLDocument gains FCPXML-specific properties and methods: `fcpxmlString`, `fcpxmlVersion`, `fcpxEventNames`, `fcpxEvents`, `fcpxResources`, `fcpxLibraryElement`, `fcpxAllProjects`, `fcpxAllClips`; `add(events:)`, `add(resourceElements:)`, `resource(matchingID:)`, `remove(resourceAtIndex:)`; `validateFCPXMLAgainst(version:)`; `init(contentsOfFCPXML:)`. Use `document.addResource(_:using: documentManager)` and `document.addSequence(_:using: documentManager)` for modular add. `document.isValid(using: parser)` for parser validation.

```swift
let document = try XMLDocument(contentsOfFCPXML: url)

// Access FCPXML properties
let version = document.fcpxmlVersion
let eventNames = document.fcpxEventNames
let events = document.fcpxEvents
let resources = document.fcpxResources

// Add elements
document.add(events: [newEvent])
document.add(resourceElements: [newResource])

// Find resources
if let resource = document.resource(matchingID: "r1") {
    // Work with resource
}

// Remove resources
document.remove(resourceAtIndex: 0)

// Validate
try document.validateFCPXMLAgainst(version: .v1_14)
```

### 3.21 XMLElement extension API

XMLElement gains `fcpxType`, `fcpxName`, `fcpxDuration`, `fcpxOffset`, `fcpxStart`, `fcpxRef`, `fcpxID`, `fcpxLane`, `fcpxRole`, `fcpxFormatRef`, and many other typed attribute accessors; `fcpxEvent(name:)`, `fcpxProject(...)`, `eventClips`, `eventClips(forResourceID:)`, `addToEvent(items:)`, `removeFromEvent(items:)`; `fcpxResource`, `fcpxParentEvent`, `fcpxSequenceClips`, `fcpxAnnotations`. Use `element.setAttribute(name:value:using: documentManager)` and `element.getAttribute(name:using: documentManager)` for modular attribute access. `element.createChild(name:attributes:using: documentManager)` for creating children.

```swift
let element: XMLElement = // ... from document

// Access FCPXML attributes
let elementType = element.fcpxType
let name = element.fcpxName
let duration = element.fcpxDuration
let offset = element.fcpxOffset
let ref = element.fcpxRef
let id = element.fcpxID
let lane = element.fcpxLane

// Work with events
let event = element.fcpxEvent(name: "My Event")
let clips = event.eventClips
let clipsForResource = event.eventClips(forResourceID: "r1")

// Add/remove from events
event.addToEvent(items: [clip])
event.removeFromEvent(items: [clip])

// Access parent/children
let resource = element.fcpxResource
let parentEvent = element.fcpxParentEvent
let sequenceClips = element.fcpxSequenceClips
```

### 3.22 FinalCutPro.FCPXML model

For a high-level wrapper around the XML document, use `FinalCutPro.FCPXML`: `init(fileContent: Data)` or `init(fileContent: XMLDocument)`; `.root` (Root wrapper); `.version` (Version); `.allEvents()`, `.allProjects()` for event and project names. Useful for quick inspection and tests.

```swift
let data = try loader.loadData(from: url)
let fcpxml = try FinalCutPro.FCPXML(fileContent: data)
let eventNames = fcpxml.allEvents()
let projectNames = fcpxml.allProjects()
let root = fcpxml.root
let version = fcpxml.version
```

### 3.23 Error types

Pipeline Neo uses explicit error types: `FCPXMLError` (e.g. `parsingFailed`); `FCPXMLLoadError` (`notAFile`, `readFailed`); `FinalCutPro.FCPXML.ParseError` (general, with `LocalizedError`); `FCPXMLExportError` (`missingAsset`, `invalidTimeline`, etc.); `FCPXMLBundleExportError`; `TimelineError` (`noAvailableLane`, `assetNotFound`, `invalidFormat`, `invalidAssetReference`); `ValidationError` and `ValidationWarning` (type, message, context; warning types include `negativeTimeAttribute`). All conform to `LocalizedError` where applicable. Use the `ErrorHandling` protocol (sync-only) and `ErrorHandler` to turn errors into messages, or switch on the error type in your code.

```swift
do {
    let document = try service.parseFCPXML(from: url)
} catch let error as FCPXMLError {
    switch error {
    case .parsingFailed(let underlyingError):
        print("Parse failed: \(underlyingError.localizedDescription)")
    default:
        print("FCPXML error: \(error.localizedDescription)")
    }
} catch let error as TimelineError {
    switch error {
    case .noAvailableLane(let offset, let duration):
        print("No lane available at \(offset) for duration \(duration)")
    case .assetNotFound(let url):
        print("Asset not found: \(url.path)")
    case .invalidFormat(let reason):
        print("Invalid format: \(reason)")
    case .invalidAssetReference(let assetRef, let reason):
        print("Invalid asset '\(assetRef)': \(reason)")
    }
} catch {
    print("Unknown error: \(error.localizedDescription)")
}
```

### 3.24 Progress bar (CLI)

For CLI or terminal workflows, use **ProgressBar** (TQDM-inspired) to show progress. **ProgressReporter** is a protocol with `advance(by:)` and `finish()`; **ProgressBar** conforms to it and draws a bar with percentage, rate, and ETA. Create with `ProgressBar(total: count, desc: "Copying media")`, then pass it as the `progress` parameter to `copyReferencedMedia(from:to:baseURL:progress:)`. The CLI uses it for `--media-copy` (one step per file) and `--validate` (one-step indicator); progress is hidden when `--quiet` is set.

```swift
let total = fileRefs.count
let bar = ProgressBar(total: total, desc: "Copying media")
let result = service.copyReferencedMedia(from: document, to: destDir, baseURL: baseURL, progress: bar)
```

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

### 4.7 Complete timeline workflow

```swift
import PipelineNeo
import CoreMedia

// Create timeline format
let format = TimelineFormat.hd1080p(
    frameDuration: CMTime(value: 1001, timescale: 24000),
    colorSpace: .rec709
)

// Create clips
let clip1 = TimelineClip(
    assetRef: "r1",
    offset: CMTime(value: 0, timescale: 1),
    duration: CMTime(value: 10, timescale: 1),
    start: .zero,
    lane: 0
)

let clip2 = TimelineClip(
    assetRef: "r2",
    offset: CMTime(value: 10, timescale: 1),
    duration: CMTime(value: 5, timescale: 1),
    start: .zero,
    lane: 0
)

// Create timeline with metadata
var timeline = Timeline(
    name: "My Project",
    format: format,
    clips: [clip1, clip2]
)

// Add markers
timeline.addMarker(Marker(start: CMTime(value: 5, timescale: 1), value: "Marker 1"))
timeline.addChapterMarker(ChapterMarker(start: CMTime(value: 0, timescale: 1), value: "Chapter 1"))

// Insert clip with ripple
let newClip = TimelineClip(
    assetRef: "r3",
    offset: .zero,
    duration: CMTime(value: 3, timescale: 1),
    lane: 0
)
let (updatedTimeline, result) = timeline.insertingClipWithRipple(
    newClip,
    at: CMTime(value: 5, timescale: 1),
    lane: 0
)
print("Shifted \(result.shiftedClips.count) clips")

// Create export assets
let assets = [
    FCPXMLExportAsset(
        id: "r1",
        name: "Clip 1",
        src: URL(fileURLWithPath: "/path/to/clip1.mov"),
        duration: CMTime(value: 10, timescale: 1),
        hasVideo: true,
        hasAudio: true
    ),
    FCPXMLExportAsset(
        id: "r2",
        name: "Clip 2",
        src: URL(fileURLWithPath: "/path/to/clip2.mov"),
        duration: CMTime(value: 5, timescale: 1),
        hasVideo: true,
        hasAudio: true
    ),
    FCPXMLExportAsset(
        id: "r3",
        name: "Clip 3",
        src: URL(fileURLWithPath: "/path/to/clip3.mov"),
        duration: CMTime(value: 3, timescale: 1),
        hasVideo: true,
        hasAudio: true
    )
]

// Export to bundle
let exporter = FCPXMLBundleExporter(version: .default, includeMedia: false)
let bundleURL = try exporter.exportBundle(
    timeline: updatedTimeline,
    assets: assets,
    to: outputDirectory,
    bundleName: "My Project"
)
print("Exported to: \(bundleURL.path)")
```

### 4.8 Validate assets before export

```swift
import PipelineNeo

// Validate all assets before export
let validator = AssetValidator()
let detector = MIMETypeDetector()

for asset in assets {
    guard let src = asset.src else { continue }
    
    // Validate asset exists and MIME type is compatible
    // Assume clips are on lane 0 (video/image/audio allowed)
    let result = await validator.validateAsset(
        at: src,
        forLane: 0,
        mimeTypeDetector: detector
    )
    
    if !result.isValid {
        print("Warning: Asset \(asset.id) failed validation: \(result.reason ?? "unknown")")
        // Handle invalid asset (skip, fix, or error)
    } else {
        print("Asset \(asset.id) validated: \(result.mimeType ?? "unknown")")
    }
}

// Validate clip-specific assets
for clip in timeline.clips {
    if let asset = assets.first(where: { $0.id == clip.assetRef }),
       let src = asset.src {
        let result = await clip.validateAsset(at: src)
        if !result.isValid {
            print("Clip \(clip.assetRef) on lane \(clip.lane) has invalid asset")
        }
    }
}
```

---

For FCPXML format details, see [fcp.cafe/developers/fcpxml](https://fcp.cafe/developers/fcpxml). For project overview, installation, and architecture, see the main [README](../README.md).
