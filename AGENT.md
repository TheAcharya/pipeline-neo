# Pipeline Neo — AI Agent Development Guide

Pipeline Neo is a modern, fully modular Swift 6 framework for Final Cut Pro FCPXML processing with SwiftTimecode integration. The codebase underwent a complete rewrite and refactor: it is now 100% protocol-oriented, with all major operations defined as protocols and implemented via dependency injection for maximum flexibility, testability, and future-proofing. This guide is for AI agents and contributors working on the project.

Keep this file in sync with `.cursorrules`. Both should describe the same overview, architecture, test structure, and conventions. When you update one, update the other.

---

## Table of Contents

- [Project Overview](#project-overview)
- [Codebase Rewrite and Refactor](#codebase-rewrite-and-refactor)
- [Architecture](#architecture)
- [Modularity and Safety](#modularity-and-safety)
- [Development Guidelines](#development-guidelines)
- [Code Style and Formatting](#code-style-and-formatting)
- [File Organisation](#file-organisation)
- [Test Structure](#test-structure)
- [Dependencies](#dependencies)
- [Common Patterns](#common-patterns)
- [Error Handling](#error-handling)
- [Performance](#performance)
- [Documentation](#documentation)
- [Git Workflow](#git-workflow)
- [Documentation Sync](#documentation-sync)
- [References](#references)

---

## Project Overview

Pipeline Neo targets macOS 12+, Xcode 16+, and Swift 6.0 with full concurrency support. It provides FCPXML parsing, creation, and manipulation with timecode operations via SwiftTimecode. All core behaviour is behind protocols with both synchronous and async/await APIs; default implementations exist but any component can be swapped or extended via dependency injection.

Current status: all 177 tests passing; FCPXML versions 1.5–1.14 supported (DTDs included, full parsing, typed element-type coverage for all DTD elements via FCPXMLElementType); Final Cut Pro frame rates (23.976, 24, 25, 29.97, 30, 50, 59.94, 60); thread-safe and concurrency-compliant with comprehensive async/await support; no known security vulnerabilities. Version conversion (FCPXMLVersionConverter) automatically strips elements not in the target version’s DTD (e.g. adjust-colorConform, adjust-stereo-3D); per-version DTD validation via FCPXMLService.validateDocumentAgainstDTD(_:version:) and validateDocumentAgainstDeclaredVersion(_:); CLI convert runs DTD validation after conversion. Experimental CLI (pipeline-neo): --check-version, --convert-version; see Sources/PipelineNeoCLI/README.md.

---

## Codebase Rewrite and Refactor

The project was fully rewritten and refactored to achieve:

- A protocol-oriented design: parsing, timecode conversion, XML manipulation, and error handling are defined as protocols (e.g. FCPXMLParsing, TimecodeConversion, XMLDocumentOperations, ErrorHandling) with sync and async/await methods.
- A single injection point for extension APIs that cannot take parameters: `FCPXMLUtility.defaultForExtensions` (concurrency-safe). No hidden concrete types in extensions; for custom pipelines use the modular API with the `using:` parameter.
- Consistent source layout: Classes, Delegates, Errors, Extensions (including +Modular), Implementations, Protocols, Services, Utilities, and FCPXML DTDs.
- A structured test suite: shared resources, file tests per sample, logic/parsing tests, timeline/export/validation tests, API and edge-case tests, and performance tests, all documented in Tests/README.md.

Foundation XML types (XMLDocument, XMLElement) and SwiftTimecode types are not Sendable. The codebase avoids Task-based concurrency for these types but provides async/await APIs that are concurrency-safe for Swift 6. If these dependencies become Sendable in the future, further parallelisation can be introduced.

---

## Architecture

- Protocols: Core operations are defined as protocols with both sync and async/await methods. Default implementations are provided; components can be swapped via dependency injection.
- Implementations: FCPXMLParser, TimecodeConverter, XMLDocumentManager, ErrorHandler, CutDetector implement the protocols.
- Analysis: Cut detection (CutDetection protocol, CutDetector implementation) produces EditPoint and CutDetectionResult; classifies edit points by boundary type (hard cut, transition, gap) and source relationship (same-clip vs different-clips). FCPXMLService and FCPXMLUtility expose detectCuts(in:) and detectCuts(inSpine:) (sync and async).
- Version conversion: FCPXMLVersionConverting protocol and FCPXMLVersionConverter; convertToVersion(_:targetVersion:) sets root version, strips elements not in the target version’s DTD (e.g. adjust-colorConform, adjust-stereo-3D), and returns a copy; saveAsFCPXML(_:to:) saves as .fcpxml; saveAsBundle(_:to:bundleName:) saves as .fcpxmld (FCPXMLBundleExporter.saveDocumentAsBundle; only for document version 1.10 or higher). DTD validation: FCPXMLService.validateDocumentAgainstDTD(_:version:) and validateDocumentAgainstDeclaredVersion(_:); FCPXMLDTDValidator injectable; CLI convert runs validation after conversion and fails if invalid. Async methods are concurrency-safe; Task-based concurrency is avoided for non-Sendable types. FCPXMLParser delegates URL loading to FCPXMLFileLoader for unified file/bundle handling and consistent parse options. TimecodeConverter guards against invalid/non-finite CMTime inputs.
- Media extraction: MediaExtraction protocol and MediaExtractor; extractMediaReferences(from:baseURL:) returns MediaExtractionResult (references from asset media-rep and locator resources; fileReferences for file URLs); copyReferencedMedia(from:to:baseURL:) copies file references to a directory with deduplication and unique filenames, returning MediaCopyResult (copied, skipped, failed). FCPXMLService and FCPXMLUtility expose both (sync and async).
- Extensions: Modular extensions for CMTime, XMLElement, and XMLDocument support dependency-injected operations and async/await. Extension APIs that cannot take parameters use FCPXMLUtility.defaultForExtensions (e.g. CMTime.fcpxmlString delegates to FCPXMLUtility.defaultForExtensions.fcpxmlTime(fromCMTime:)).
- Service: FCPXMLService orchestrates modular components for high-level workflows (sync and async). FCPXMLUtility is the legacy/convenience facade; FCPXMLService is the modern DI facade. Both delegate timecode operations to TimecodeConverter.
- Utilities: ModularUtilities provides pipeline creation (createPipeline, createCustomPipeline), validation (validateDocument delegates to FCPXMLValidator for semantic checks; the `parser:` parameter is deprecated), and helpers (processFCPXML, processMultipleFCPXML — the `errorHandler:` parameter is deprecated — and convertTimecodes using TimecodeConversion and FCPXMLTimeStringConversion protocols). For per-version DTD validation use FCPXMLService.validateDocumentAgainstDTD(_:version:) or validateDocumentAgainstDeclaredVersion(_:).
- Logging: FCPXMLUtility routes debugLog through its injected PipelineLogger; extension types (XMLDocumentExtension, XMLElementExtension) use #if canImport(Logging) as a fallback for contexts that cannot use DI.
- Versioning: FCPXMLVersion (DTD validation, 1.5-1.14) and FinalCutPro.FCPXML.Version (parsing, 1.0-1.14) are bridged via .fcpxmlVersion, .dtdVersion, and init(from:) converters. init(from:) uses safe fallback to `.latest` instead of force unwrap.
- Errors: Module-scoped error types (FCPXMLError for parsing, FCPXMLLoadError for file I/O, FCPXMLExportError/FCPXMLBundleExportError for export, FinalCutPro.FCPXML.ParseError with LocalizedError). Parse failures from FCPXMLFileLoader surface as FCPXMLError.parsingFailed so consumers handle a single parse-error type. FCPXMLElementError uses String element names for Sendable compliance.

---

## Modularity and Safety

- All major functionality is protocol-based and dependency-injected, with both sync and async/await APIs.
- Code is Sendable where appropriate; `@unchecked Sendable` removed from delegates (AttributeParserDelegate, FCPXMLParserDelegate) since they are internal-only and used synchronously. The project builds and tests with Swift 6 strict concurrency (`-strict-concurrency=complete`). CI runs a job that enforces this.
- No known vulnerabilities in dependencies (including SwiftTimecode 3.0.0) as of July 2025. No unsafe pointers, dynamic code execution, or C APIs; concurrency is structured and type-safe.

---

## Development Guidelines

Use Swift 6.0 syntax and features. Use async/await for asynchronous operations; all major operations have async/await APIs. Use structured concurrency (Task, TaskGroup) only where types are Sendable; for Foundation XML and SwiftTimecode types, provide async APIs without Task-based concurrency. Use @unchecked Sendable for classes that cannot be made final; avoid capturing non-Sendable types in concurrent contexts.

Error handling: use Swift Result for operations that can fail; provide meaningful errors; use do-catch for sync and propagate FCPXMLError in async. Use strongly typed enums for FCPXML elements (FCPXMLElementType) and type-safe timecode operations; avoid force unwrapping.

---

## Code Style and Formatting

Follow Swift API Design Guidelines. Use camelCase for variables and functions, PascalCase for types and protocols, descriptive names for all identifiers. Include comprehensive /// doc comments for all public APIs; document parameters, return values, and exceptions; provide usage examples. Group related functionality in extensions; keep files focused on single responsibilities; use clear file names and logical imports.

### File Header

All new Swift files must use this exact header format:

```
//
//  FileName.swift
//  Pipeline Neo • https://github.com/TheAcharya/pipeline-neo
//  © 2026 • Licensed under MIT License
//

//
//	Brief description of the file's purpose.
//
```

Rules:
- Replace `FileName.swift` with the actual file name.
- Replace the purpose line with a concise description of what the file contains.
- The purpose block uses a tab character after `//`, not spaces.
- Two blank lines separate the header block from the purpose block.
- Do not add `//  PipelineNeo`, `Created by`, or `Copyright ©` lines.

---

## File Organisation

Source layout under Sources/PipelineNeo/:

- Analysis: EditPoint (edit type, source relationship), CutDetectionResult (edit points and counts).
- Classes: FinalCutPro (namespace enum), FCPXML (core struct, init, properties), FCPXML Root, FCPXML Root Version, FCPXMLElementType, FCPXMLUtility, FCPXMLVersion.
- Delegates: AttributeParserDelegate (property: `values`), FCPXMLParserDelegate (properties: `roles`, `resourceIDs`, `textStyleIDs`; O(1) deduplication via Set).
- Errors: FCPXMLError, FCPXML ParseError.
- Extensions: CMTime+Modular, CMTimeExtension, XMLDocument+Modular, XMLDocumentExtension, XMLElement+Modular, XMLElementExtension.
- Implementations: FCPXMLParser, TimecodeConverter, XMLDocumentManager, ErrorHandler, CutDetector, FCPXMLVersionConverter.
- Protocols: FCPXMLParsing, TimecodeConversion, XMLDocumentOperations, ErrorHandling, CutDetection, FCPXMLVersionConverting.
- Services: FCPXMLService.
- Utilities: ModularUtilities, FCPXML Time Utilities, SequencePlusAnySequence, XMLElementAncestorWalking, XMLElementSequenceAttributes.
- Annotations: ChapterMarker, Keyword, Marker, Metadata, Rating (creation-oriented value types; for parsing models see Model/).
- Export: FCPXMLExporter, FCPXMLBundleExporter, FCPXMLExportAsset.
- Timeline: Timeline, TimelineClip.
- Validation: FCPXMLValidator, FCPXMLDTDValidator, ValidationResult, ValidationError/Warning.
- FileIO: FCPXMLFileLoader.
- Logging: PipelineLogger, NoOpPipelineLogger, PrintPipelineLogger.
- Format: ColorSpace.
- Model: FCPXML element models for the parsing layer (previously nested under FinalCutPro/FCPXML/). Subfolders: Attributes (AudioLayout, AudioRate, ClipSourceEnable, FrameSampling, TimecodeFormat), Clips (AssetClip, Audio, Audition, Clip, Gap, MCClip, MulticamSource, RefClip, SyncClip, SyncSource, Title, Transition, Video), CommonElements (AudioChannelSource, AudioRoleSource, ConformRate, MediaRep, Metadata, Text, TimeMap), ElementTypes (AnyElementModelType, ElementModelType, ElementType, protocols), Occlusion (ElementOcclusion, Element Occlusion), Protocols (FCPXMLElement, FCPXMLAttribute, element attribute/children/story protocols), Resources (Asset, Effect, Format, Locator, Media, MediaMulticam, ObjectTracker), Roles (AudioRole, CaptionRole, VideoRole, AncestorRoles, AnyRole, RoleType, FCPXMLRole), Structure (Event, Library, Project). Root files: AnyTimeline, Caption, Keyword, Marker, Sequence, Spine.
- Parsing: XML parsing extensions (Attributes, Clip Parsing, Elements Parsing, Metadata Parsing, Resources Parsing, Roles Parsing, Root Parsing, Time and Frame Rate Parsing).
- Extraction: Element extraction logic. Subfolders: Context (ElementContext, FrameRateSource), Presets (CaptionsExtractionPreset, FrameDataPreset, MarkersExtractionPreset, RolesExtractionPreset, FCPXMLExtractionPreset). Root files: Extract, ExtractableChildren, ExtractedElement, Extraction, ExtractionScope, FCPXMLExtractedElement, FCPXMLExtractedModelElement.
- FCPXML DTDs: version 1.5-1.14 and README.

Maintain this structure; do not introduce new top-level categories without aligning both AGENT.md and .cursorrules.

---

## Test Structure

Tests live under Tests/. The suite is organised as follows.

- Tests/README.md: Full description of test categories, how to run tests (Swift PM, Xcode, Linux), sample files, frame rates, FCPXML versions, and contributing. Keep it current when adding or changing tests.

- Tests/FCPXML Samples/FCPXML/: Sample .fcpxml files (e.g. 24.fcpxml, Structure.fcpxml, frame-rate samples). File tests and logic tests load these via shared utilities; tests that require a missing sample use XCTSkip.

- Tests/PipelineNeoTests/: Test code.
  - TestResources.swift: Path resolution (packageRoot, fcpxmlSamplesDirectory, urlForFCPXMLSample, FCPXMLSampleName) so samples work from Xcode and `swift test`.
  - FCPXMLTestUtilities.swift: loadFCPXMLSampleData(named:), loadFCPXMLSample(named:), fcpxmlFrameRateSampleNames, allFCPXMLSampleNames(); throws XCTSkip when a sample is missing.
  - CutDetectionTests.swift: Cut detection (same-clip vs different-clips, boundary types, Example FCPXML Cut 1/Cut 2, 24.fcpxml, empty spine, async).
  - VersionConversionTests.swift: Version conversion (convert to target version, element stripping for 1.10/1.12, save as .fcpxml, save as .fcpxmld with 1.10+ check, bundle error when < 1.10, async).
  - PipelineNeoTests.swift: Main test class; setUpWithError injects parser, timecodeConverter, documentManager, errorHandler, FCPXMLUtility, FCPXMLService. MARK sections group tests (FCPXMLUtility, FCPXMLService, modular components, async/concurrency, performance, frame rates, time values, FCPXML time strings, time conforming, error handling, document management, element filtering, modular extensions, edge cases, FCPXMLElementType, FCPXMLError, ModularUtilities API, XMLDocument extension, XMLElement extension, parser filter).
  - FileTests/: One test class per sample or category (e.g. FCPXMLFileTest_24, FCPXMLFileTest_AllSamples, FCPXMLFileTest_FrameRates). Each loads one or more samples and asserts parse success, root, version, events, projects, or resources as appropriate.
  - LogicAndParsing/: FCPXMLRootVersionTests (Version init, rawValue, Equatable, Comparable, invalid strings), FCPXMLStructureTests (Structure sample, allEvents/allProjects, root structure).
  - TimelineExportValidationTests: Timeline and TimelineClip, FCPXMLExporter, FCPXMLBundleExporter, FCPXMLValidator, FCPXMLDTDValidator, FCPXMLService.validateDocumentAgainstDTD/validateDocumentAgainstDeclaredVersion (per-version), FCPXMLFileLoader.
  - APIAndEdgeCaseTests: FCPXMLFileLoader async load(from:), PipelineLogger injection (NoOp, Print), edge cases (empty/invalid/malformed XML, invalid paths), validation types.
  - FCPXMLPerformanceTests: Parameterised and basic performance tests (timecode conversion, document creation, element filtering).

Test organisation: use descriptive test method names; group related tests logically; include setup and teardown; use meaningful assertions. Test all supported frame rates (Final Cut Pro compatible). Use realistic FCPXML samples and edge cases; validate against actual FCP behaviour where applicable. Current total: 177 comprehensive tests covering all functionality including async/await, cut detection, version conversion stripping, per-version DTD validation, and extract-then-copy (CLI --extract-media flow).

---

## Dependencies

- SwiftTimecode 3.0.0+ for timecode operations.
- SwiftExtensions 2.0.0+ (orchetect/swift-extensions) for String, Collection, Optional, XML helpers where useful.
- Foundation for XML and data; CoreMedia for CMTime.

Swift 6.0+, Xcode 16.0+, macOS 12.0+.

SwiftTimecode usage: use `Timecode(.realTime(seconds: seconds), at: frameRate)` (not the old realTime: at: initialiser). Use frame rate cases `.fps23_976`, `.fps24`, `.fps25`, `.fps29_97`, `.fps30`, `.fps50`, `.fps59_94`, `.fps60` (not the old ._24, ._25, etc.).

---

## Common Patterns

Async operations: async methods return Timecode? or throw as appropriate; Task-based concurrency only when element types are Sendable. Example:

```swift
public func timecode(from time: CMTime, frameRate: TimecodeFrameRate) async -> Timecode? {
    // Implementation
}
```

Error handling: sync APIs use Result<_, FCPXMLError>; async APIs throw and propagate FCPXMLError (e.g. parsingFailed(Error)). FCPXMLError cases: invalidFormat, parsingFailed(Error), unsupportedVersion, validationFailed(String), timecodeConversionFailed(String), documentOperationFailed(String). See Errors/FCPXMLError.swift.

---

## Error Handling

Use Swift Result for sync; do-catch and throw for async. Provide meaningful messages and context. Implement graceful degradation where possible; proper cleanup on error. FCPXMLError is Sendable; use it for all public failure cases.

---

## Performance

Use value types where appropriate; avoid retain cycles; use weak references for delegates. Use appropriate concurrency levels and task cancellation; avoid blocking the main thread. For XML: stream when possible, use efficient parsing, cache frequently accessed data.

---

## Documentation

Public APIs: comprehensive header comments, ///, parameters/return values/exceptions, usage examples. README: project overview, installation, usage, API/modularity notes. Inline comments: explain non-obvious logic and reference external specs. Update README and Tests/README.md when adding features or changing test layout.

---

## Git Workflow

Branches: main (production-ready), dev, feature/*, bugfix/*. Commits: clear, descriptive, imperative; reference issues when applicable; separate subject and body with a blank line. Pull requests: descriptive title and description; ensure all tests pass.

---

## Documentation Sync

Keep AGENT.md and .cursorrules in sync. Both must reflect:

- Project overview and codebase rewrite/refactor.
- Architecture (protocols, implementations, extensions, service, utilities) and single injection point (FCPXMLUtility.defaultForExtensions).
- Source layout (Classes, Delegates, Errors, Extensions including +Modular, Implementations, Protocols, Services, Utilities, Annotations, Export, Timeline, Validation, FileIO, Logging, Format, Model, Parsing, Extraction, FCPXML DTDs).
- Test structure (Tests/ layout, TestResources, FCPXMLTestUtilities, FileTests/, LogicAndParsing/, CutDetectionTests, VersionConversionTests, PipelineNeoTests.swift, TimelineExportValidationTests, APIAndEdgeCaseTests, FCPXMLPerformanceTests; 177 tests).
- FCPXML 1.5–1.14 and FCPXMLElementType; version conversion with element stripping and per-version DTD validation; experimental CLI (pipeline-neo, --check-version, --convert-version); Final Cut Pro frame rates; Swift 6 concurrency (Sendable, async/await, CI strict-concurrency job).

When updating either file, apply the same information to both and keep terminology and examples consistent.

---

## References

External: Final Cut Pro XML (fcp.cafe/developers/fcpxml/), SwiftTimecode (github.com/orchetect/swift-timecode), Swift Concurrency (docs.swift.org). Internal: Package.swift, README.md, .cursorrules, CHANGELOG.md, Tests/README.md, Documentation/Manual.md.
