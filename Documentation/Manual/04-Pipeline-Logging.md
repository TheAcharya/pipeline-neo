# 04 — Pipeline & Logging

[← Manual Index](00-Index.md)

---

## Creating a pipeline

**ModularUtilities** provides factory methods for default or custom pipelines:

```swift
import PipelineNeo

// Default pipeline (parser, timecode converter, document manager, error handler, no-op logger)
let service = ModularUtilities.createPipeline()

// Custom pipeline with optional logger
let customService = ModularUtilities.createCustomPipeline(
    parser: FCPXMLParser(),
    timecodeConverter: TimecodeConverter(),
    documentManager: XMLDocumentManager(),
    errorHandler: ErrorHandler(),
    logger: PrintPipelineLogger(minimumLevel: .info)
)
```

---

## FCPXMLService

**FCPXMLService** is the main orchestrator. Inject components or use defaults:

```swift
let service = FCPXMLService(
    parser: FCPXMLParser(),
    timecodeConverter: TimecodeConverter(),
    documentManager: XMLDocumentManager(),
    errorHandler: ErrorHandler(),
    logger: PrintPipelineLogger(minimumLevel: .info)
)

// Create document
let document = service.createFCPXMLDocument(version: "1.10")

// Parse (sync/async)
let doc = try service.parseFCPXML(from: url)
let docAsync = try await service.parseFCPXML(from: url)

// Validate
let isValid = await service.validateDocument(document)

// Save
try service.saveAsFCPXML(document, to: outputURL)
let bundleURL = try service.saveAsBundle(document, to: outputDir, bundleName: "My Project")
```

---

## Logging

**PipelineLogLevel** (most to least verbose): `trace`, `debug`, `info`, `notice`, `warning`, `error`, `critical`. Use `PipelineLogLevel.from(string:)` to parse from a string.

**Implementations:**

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

The service logs parsing, version conversion, DTD validation, save, media extraction, and media copy. CLI supports `--log`, `--log-level`, `--quiet` (see [16 — CLI](16-CLI.md)).

---

## Error handling with modular components

**ModularUtilities.processFCPXML** returns `Result<XMLDocument, Error>`:

```swift
let result = ModularUtilities.processFCPXML(from: url, using: service)

switch result {
case .success(let document):
    print("Parsed successfully")
case .failure(let error):
    print("Error: \(error.localizedDescription)")
}
```

**ErrorHandling** protocol (sync-only) and **ErrorHandler** format errors into user-facing messages.

---

## Async and concurrent operations

```swift
// Process multiple files
let results = await ModularUtilities.processMultipleFCPXML(from: urls, using: service)

// Convert timecodes for multiple elements
let timecodes = await ModularUtilities.convertTimecodes(
    for: elements,
    using: timecodeConverter,
    frameRate: .fps24
)

// TaskGroup example
await withTaskGroup(of: XMLDocument.self) { group in
    for url in urls {
        group.addTask { try await service.parseFCPXML(from: url) }
    }
    for await document in group {
        let isValid = await service.validateDocument(document)
        if isValid { /* process */ }
    }
}
```

---

## Next

- [05 — Validation & Cut Detection](05-Validation-CutDetection.md) — Semantic and DTD validation, cut detection.
