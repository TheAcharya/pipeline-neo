# Pipeline Neo — Test Suite

This directory contains the test suite for Pipeline Neo, a Swift 6 framework for Final Cut Pro FCPXML processing with SwiftTimecode integration. The suite currently has 181 tests. They ensure correctness, concurrency safety, and performance across parsing, timecode conversion, document and element operations, file loading, timeline export, validation, and all supported FCPXML versions and frame rates. The suite is modular: shared utilities resolve sample paths, file tests exercise individual FCPXML samples, and logic-and-parsing tests cover model types and structure.

---

## Table of Contents

1. [Test structure](#1-test-structure)
2. [Running tests](#2-running-tests)
3. [Test categories and coverage](#3-test-categories-and-coverage)
4. [File tests (per-sample coverage)](#4-file-tests-per-sample-coverage)
5. [Logic and parsing tests](#5-logic-and-parsing-tests)
6. [Timeline, export, and validation tests](#6-timeline-export-and-validation-tests)
7. [API and edge case tests](#7-api-and-edge-case-tests)
8. [Performance tests](#8-performance-tests)
9. [Supported frame rates](#9-supported-frame-rates)
10. [FCPXML versions](#10-fcpxml-versions)
11. [Sample files](#11-sample-files)
12. [Writing and organising tests](#12-writing-and-organising-tests)
13. [Continuous integration](#13-continuous-integration)
14. [Debugging tests](#14-debugging-tests)
15. [Contributing to tests](#15-contributing-to-tests)
16. [Resources](#16-resources)
17. [Resolving common test/build messages](#17-resolving-common-testbuild-messages)
18. [Credits](#18-credits)

---

## 1. Test structure

```
Tests/
├── README.md
├── FCPXML Samples/
│   └── FCPXML/                 # Sample .fcpxml files (24.fcpxml, Structure.fcpxml, etc.)
└── PipelineNeoTests/
    ├── TestResources.swift    # packageRoot, fcpxmlSamplesDirectory, urlForFCPXMLSample, FCPXMLSampleName
    ├── FCPXMLTestUtilities.swift  # loadFCPXMLSampleData(named:), loadFCPXMLSample(named:), fcpxmlFrameRateSampleNames, allFCPXMLSampleNames()
    ├── FileTests/             # One test class per sample or category
    │   ├── FCPXMLFileTest_24.swift
    │   ├── FCPXMLFileTest_Complex.swift
    │   ├── FCPXMLFileTest_BasicMarkers.swift
    │   ├── FCPXMLFileTest_FrameRates.swift
    │   ├── FCPXMLFileTest_AllSamples.swift
    │   ├── FCPXMLFileTest_Annotations.swift
    │   ├── FCPXMLFileTest_StandaloneAssetClip.swift
    │   ├── FCPXMLFileTest_SyncClip.swift
    │   ├── FCPXMLFileTest_CompoundClips.swift
    │   ├── FCPXMLFileTest_Keywords.swift
    │   └── FCPXMLFileTest_Occlusion.swift
    ├── LogicAndParsing/
    │   ├── FCPXMLRootVersionTests.swift
    │   └── FCPXMLStructureTests.swift
    ├── APIAndEdgeCaseTests.swift
    ├── CutDetectionTests.swift   # Cut detection (same-clip vs different-clips, boundary types)
    ├── VersionConversionTests.swift  # Version conversion, save as .fcpxml / .fcpxmld (bundle 1.10+ only)
    ├── MediaExtractionTests.swift    # Media reference extraction and copy (asset media-rep, locators)
    ├── FCPXMLPerformanceTests.swift
    ├── PipelineNeoTests.swift
    ├── TimelineExportValidationTests.swift
    └── XCTestManifests.swift
```

TestResources.swift provides path resolution from the test file location to the package root and then to `Tests/FCPXML Samples/FCPXML/`, so sample URLs work from both Xcode and `swift test` without bundle resources. FCPXMLTestUtilities adds helpers that load sample data or a full FinalCutPro.FCPXML instance and throw XCTSkip when a sample is missing. PipelineNeoTests.swift holds the main test class with shared dependencies (parser, timecode converter, document manager, error handler) injected in setUpWithError. XCTestManifests.swift exposes tests for Swift Package Manager on Linux.

---

## 2. Running tests

### Swift Package Manager

```bash
# Run all tests
swift test

# Verbose output
swift test --verbose

# Run a single test by name
swift test --filter testAllSupportedFrameRates

# Run tests matching a pattern
swift test --filter PipelineNeoTests
```

### Xcode

1. Open the package (File → Open the folder or .swiftpm workspace).
2. Select the PipelineNeo scheme.
3. ⌃⌘U (or Product → Test) to run all tests.
4. Use the Test Navigator (⌘6) to run or re-run individual tests.

### Linux

Tests are discoverable on Linux via XCTestManifests.swift. Run with `swift test` in a Linux environment that provides XCTest.

---

## 3. Test categories and coverage

PipelineNeoTests.swift is organised with MARK sections. Summary of categories and what they cover:

Test dependencies / setup: setUpWithError and tearDownWithError create and tear down parser, timecodeConverter, documentManager, errorHandler, FCPXMLUtility, and FCPXMLService. All tests use these instances to validate the modular, protocol-oriented API.

FCPXMLUtility: testFCPXMLUtilityInitialisation, testFilterElements, testCMTimeFromFCPXMLTime, testFCPXMLTimeFromCMTime, testConformTime. Covers utility initialisation, element filtering by FCPXMLElementType, CMTime to and from FCPXML time string, and time conforming to frame duration.

FCPXMLService: testFCPXMLServiceInitialisation, testCreateFCPXMLDocument, testTimecodeConversion, testCMTimeFromTimecode. Covers service initialisation, document creation, and timecode and CMTime conversion via the service.

Modular components: testParserComponent, testTimecodeConverterComponent, testDocumentManagerComponent, testErrorHandlerComponent. Covers parser parse and validate, TimecodeConverter round-trip, DocumentManager create and add resource, ErrorHandler message formatting.

Modular utilities: testModularUtilitiesCreatePipeline. Ensures ModularUtilities.createPipeline() returns a configured FCPXMLService.

Async and concurrency: testSwift6ConcurrencySendableServiceInTaskGroup, testAsyncParserComponent, testAsyncTimecodeConverterComponent, testAsyncDocumentManagerComponent, testAsyncFCPXMLService, testAsyncModularUtilities, testAsyncElementFiltering, testAsyncTimeConforming, testAsyncFCPXMLTimeStringConversion, testAsyncXMLElementOperations, testAsyncConcurrentOperations. Covers Sendable service in TaskGroup, async variants of parser, timecode converter, document manager, service, utilities, element filtering, time conforming, FCPXML time string conversion, XML element operations, and concurrent async operations.

Performance (basic): testPerformanceFilterElements, testPerformanceTimecodeConversion. Measures filtering elements by type and timecode conversion throughput.

Frame rate: testAllSupportedFrameRates, testDropFrameTimecode. Covers all eight FCP-supported frame rates (timecode round-trip) and drop-frame (29.97, 59.94).

Time values: testVariousTimeValues, testLargeTimeValues. Various and large CMTime values and round-trip via timecode converter.

FCPXML time strings: testFCPXMLTimeStringFormats, testInvalidFCPXMLTimeStrings. Valid value/timescale formats and round-trip; invalid strings (empty, malformed, wrong count) produce CMTime.zero.

Time conforming: testTimeConformingWithDifferentFrameDurations. conform(time:toFrameDuration:) for all eight FCP frame durations; conformed time is a multiple of frame duration.

Error handling: testErrorHandlerWithAllErrorTypes, testParserWithInvalidXML. ErrorHandler for FCPXMLError cases; parser with invalid XML.

Document management: testDocumentManagerWithAllFCPXMLVersions, testDocumentManagerWithComplexStructure. Document creation for FCPXML versions 1.5 through 1.14; add resources and sequences and validate structure.

Element filtering: testElementFilteringWithAllElementTypes, testElementFilteringWithExtendedElementTypes, testElementFilteringWithAllFCPXMLElementTypes. Filter by core and extended types; filter by every FCPXMLElementType for full DTD element coverage.

Modular extensions: testCMTimeModularExtensionsWithAllFrameRates, testXMLElementModularExtensionsWithComplexAttributes, testXMLDocumentModularExtensionsWithComplexStructure. CMTime timecode, fcpxmlTime, and conformed with converter; XMLElement setAttribute, getAttribute, createChild; XMLDocument addResource, addSequence, isValid.

Performance (parameters): testPerformanceTimecodeConversionAllFrameRates, testPerformanceDocumentCreation, testPerformanceElementFilteringLargeDataset. Timecode conversion for all frame rates; document creation loop; element filtering over a large dataset.

Edge cases: testEdgeCaseTimeValues, testConcurrencySafety. Edge time values (zero, very small, large); concurrent timecode conversion (DispatchQueue).

FCPXMLElementType: testFCPXMLElementTypeTagNameAndIsInferred. tagName and isInferred for multicam, compound, asset, sequence, clip, none.

FCPXMLError: testFCPXMLErrorAllCasesHaveDescription. Every FCPXMLError case has a non-empty errorDescription.

ModularUtilities API: testModularUtilitiesCreateCustomPipeline, testModularUtilitiesValidateDocumentReturnsErrorsForInvalidDocument, testModularUtilitiesProcessFCPXMLFromDataViaTempURL, testModularUtilitiesProcessMultipleFCPXML, testModularUtilitiesConvertTimecodes. Custom pipeline; validateDocument with invalid document; processFCPXML from URL; processMultipleFCPXML; convertTimecodes.

XMLDocument extension: testXMLDocumentExtensionFcpxEventNamesAndAddEvents, testXMLDocumentExtensionResourceMatchingIDAndRemove, testXMLDocumentExtensionFcpxmlStringAndVersion, testXMLDocumentContentsOfFCPXMLInitializer. fcpxEventNames and add(events:); resource(matchingID:) and remove(resourceAtIndex:); fcpxmlString and fcpxmlVersion; init(contentsOfFCPXML:).

XMLElement extension: testXMLElementExtensionFcpxTypeAndIsFCPX, testXMLElementExtensionFcpxTypeMediaWithFirstChildMulticamOrSequence, testXMLElementExtensionFcpxEventAndEventClips, testXMLElementExtensionFcpxDuration, testXMLElementExtensionEventClipsThrowsWhenNotEvent. fcpxType (asset, sequence, clip, locator, media with first child multicam or sequence); isFCPXResource, isFCPXStoryElement; fcpxEvent, eventClips, addToEvent, removeFromEvent; fcpxDuration get and set; eventClips throws when element is not an event.

Parser filter: testParserFilterMulticamAndCompoundResources, testFCPXMLUtilityDefaultForExtensions. Filter media by first child (multicam or compound); FCPXMLUtility.defaultForExtensions filtering.

Media extraction: MediaExtractionTests. extractMediaReferences (Example Cut 1, baseURL, sync/async); copyReferencedMedia (missing file skipped, real file copied, sync/async); testExtractThenCopy_MultipleTypes_DetectedAndCopied (extract then copy with video + audio refs, same flow as CLI --media-copy). Covers MediaExtractor, MediaExtractionResult, MediaCopyResult.

---

## 4. File tests (per-sample coverage)

File tests live under PipelineNeoTests/FileTests/ and use samples from Tests/FCPXML Samples/FCPXML/. Each test class loads one or more samples and asserts parse success, version, root structure, events, projects, resources, or spine content as appropriate.

FCPXMLFileTest_24: testParse loads the 24.fcpxml sample as FinalCutPro.FCPXML and asserts root name, version ver1_11, at least one event and project, project sequence with format "r1", and spine with at least one story element. testLoadViaLoaderAndParseViaService loads the same file via FCPXMLFileLoader and FCPXMLService and asserts root element.

FCPXMLFileTest_Complex: testParse loads Complex.fcpxml and asserts root name, version ver1_11, and non-empty events and projects. testRootVersionAttribute asserts version major 1 and minor at least 10. testResourcesExist asserts root.resources has at least one child element.

FCPXMLFileTest_BasicMarkers: testParse loads BasicMarkers.fcpxml and asserts root name, version ver1_9, root equality, resources with at least one child, and presence of library. testAllEventsAndProjects asserts non-empty allEvents() and allProjects().

FCPXMLFileTest_FrameRates: testEachFrameRateSampleParsesAndHasValidRoot iterates over the ten frame-rate sample names (23.98, 24, 24With25Media, 25i, 29.97, 29.97d, 30, 50, 59.94, 60) and for each existing file parses as FinalCutPro.FCPXML and asserts root name and version at least 1.5. testFrameRateSample_24, testFrameRateSample_29_97, testFrameRateSample_60 load those three samples and assert root and (for 24) version ver1_11.

FCPXMLFileTest_AllSamples: testAllAvailableSamplesParseSuccessfully enumerates all .fcpxml files in the samples directory and loads each with FCPXMLFileLoader, asserting root element and name "fcpxml". testAllAvailableSamplesParseAsFinalCutProFCPXML does the same using loadFCPXMLSample and asserts root element name. Both skip if the samples directory is missing or empty.

FCPXMLFileTest_Annotations: testParse loads Annotations.fcpxml and asserts root name and non-empty events and projects.

FCPXMLFileTest_StandaloneAssetClip: testParse loads StandaloneAssetClip.fcpxml and asserts root name and at least one resource child.

FCPXMLFileTest_SyncClip: testParse loads SyncClip.fcpxml and asserts root name and non-empty projects.

FCPXMLFileTest_CompoundClips: testParse loads CompoundClips.fcpxml and asserts root name and non-empty projects.

FCPXMLFileTest_Keywords: testParse loads Keywords.fcpxml and asserts root name.

FCPXMLFileTest_Occlusion: testParse_Occlusion, testParse_Occlusion2, testParse_Occlusion3 load Occlusion.fcpxml, Occlusion2.fcpxml, and Occlusion3.fcpxml and assert root name for each.

All file tests that require a specific sample use loadFCPXMLSample(named:) or loadFCPXMLSampleData(named:), which throw XCTSkip when the file is missing, so the suite can run even if some samples are absent.

---

## 5. Logic and parsing tests

LogicAndParsing/ contains tests that focus on model types and parsing rules rather than a single file.

FCPXMLRootVersionTests: Exercises FinalCutPro.FCPXML.Version. testVersion_1_12 and testVersion_1_12_1 check init(major, minor) and init(major, minor, patch) and rawValue. testVersion_Equatable and testVersion_Comparable check equality and ordering. testVersion_RawValue_EdgeCase_MajorVersionOnly checks rawValue "2" parses to major 2, minor 0, patch 0. testVersion_RawValue_Invalid checks that invalid strings (empty, "1.", "1.A", "A", etc.) yield nil. testVersion_Init_RawValue and testVersion_RawValue_Roundtrip check init(rawValue:) and round-trip. testVersion_StaticMembers checks ver1_11, ver1_14, latest, and allCases.

FCPXMLStructureTests: Uses the Structure sample. testParse_Structure_AllEventsAndProjects asserts allEvents() returns exactly "Test Event" and "Test Event 2" and allProjects() returns "Test Project", "Test Project 2", "Test Project 3". testParse_Structure_RootHasResourcesOrLibrary asserts the root has a resources or library child. testParse_Structure_Version asserts version major at least 1 and minor at least 5.

---

## 6. Timeline, export, and validation tests

TimelineExportValidationTests covers the timeline model, exporters, validators, and file loader.

Timeline and TimelineClip: testTimelineClipEndTime builds a clip with offset 10 and duration 5 and asserts endTime is 15 seconds. testTimelineDurationFromPrimaryLane builds a timeline with two clips on lane 0 and asserts total duration. testTimelineSortedClips builds a timeline with out-of-order clips and asserts sortedClips order. testTimelineFormatHelpers checks TimelineFormat.hd1080p and uhd4K width and height.

FCPXMLExporter: testFCPXMLExporterExportMinimal exports a minimal timeline with one clip and one asset and asserts the XML contains fcpxml, resources, r1, r2, asset-clip, ref. testFCPXMLExporterMissingAssetThrows asserts that exporting a timeline whose clip references an asset not in the assets array throws FCPXMLExportError.missingAsset. testFCPXMLExporterEmptyTimelineThrows asserts that exporting an empty timeline throws invalidTimeline.

FCPXMLBundleExporter: testFCPXMLBundleExporterCreatesBundle exports to a temp directory with includeMedia false and asserts the bundle directory exists, contains Out.fcpxmld, Info.fcpxml, and Info.plist, and the XML contains fcpxml. testFCPXMLBundleExporterWithMediaCopiesFiles exports with includeMedia true and a real temp file, then asserts the bundle has a Media directory with one file and the Info.fcpxml references media.

FCPXMLValidator: testFCPXMLValidatorSuccessWithValidStructure builds a minimal valid document (fcpxml, resources, format) and asserts validate returns valid. testFCPXMLValidatorMissingRoot builds a document with a non-fcpxml root and asserts invalid and an error mentioning fcpxml. testFCPXMLValidatorUnresolvedRef builds a document with a ref to a missing resource and asserts invalid and an error about the ref.

FCPXMLDTDValidator: testFCPXMLDTDValidatorReturnsResult runs the DTD validator on a valid document and asserts validation succeeds (isValid true).

FCPXMLFileLoader: testFCPXMLFileLoaderLoadsSingleFile writes a minimal fcpxml to a temp file and loads it, asserting root element and name. testFCPXMLFileLoaderLoadsBundle creates a temp .fcpxmld bundle via FCPXMLBundleExporter, then loads it with the loader and asserts resolved URL is Info.fcpxml and root element exists. testFCPXMLFileLoaderThrowsForMissingURL asserts loading a nonexistent path throws FCPXMLLoadError.

---

## 7. API and edge case tests

APIAndEdgeCaseTests covers the async load API, optional logging, edge cases, and validation types.

FCPXMLFileLoader async load(from:): testFCPXMLFileLoaderAsyncLoadFromURL writes a minimal fcpxml to a temp file and calls loader.load(from:) async, asserting root element and name. testFCPXMLFileLoaderAsyncLoadThrowsForMissingFile calls load(from:) with a nonexistent URL and asserts FCPXMLLoadError (notAFile, readFailed, or parseFailed).

PipelineLogger injection: testFCPXMLServiceWithNoOpLoggerParsesSuccessfully creates FCPXMLService(logger: NoOpPipelineLogger()) and parses minimal XML successfully. testFCPXMLServiceWithPrintLoggerParsesSuccessfully does the same with PrintPipelineLogger. testCreateCustomPipelineWithLogger creates a pipeline via ModularUtilities.createCustomPipeline with a NoOpPipelineLogger and parses minimal XML. PipelineLogLevel tests: testPipelineLogLevelComparable (ordering and allCases count), testPipelineLogLevelFromStringAndLabel (from(string:), label).

Edge cases: testParseEmptyDataThrows, testParseInvalidXMLThrows, testParseMalformedXMLThrows assert that FCPXMLService.parseFCPXML(from: Data) throws for empty data, non-XML text, and malformed XML. testLoadDocumentFromInvalidPathThrowsCorrectError and testResolveFCPXMLFileURLForNonexistentPathThrows assert FCPXMLFileLoader throws FCPXMLLoadError for a nonexistent path and that resolveFCPXMLFileURL(from:) throws notAFile.

FCPXML creation: testCreateFCPXMLDocumentAllVersions creates documents with versions "1.5", "1.10", "1.14" and asserts fcpxmlVersion and root element.

Validation types: testValidationResultWithErrors builds a ValidationResult with one ValidationError (missingAssetReference) and asserts isValid false and error message. testValidationWarning builds a ValidationWarning and asserts non-empty message.

---

## 8. Performance tests

Performance is measured with measure { } (XCTest); results show duration and relative standard deviation.

In PipelineNeoTests.swift: testPerformanceFilterElements measures filtering elements by type over repeated runs. testPerformanceTimecodeConversion measures timecode conversion for a single frame rate. testPerformanceTimecodeConversionAllFrameRates measures timecode conversion across all eight frame rates per iteration. testPerformanceDocumentCreation measures creating FCPXML documents and adding a resource in a loop. testPerformanceElementFilteringLargeDataset measures filtering a large set of elements by type.

In FCPXMLPerformanceTests: testPerformanceParseFCPXMLDataRepeatedly parses an in-memory FCPXML document 50 times per iteration. testPerformanceLoadSampleFileWhenAvailable loads Structure.fcpxml from disk 20 times per iteration (skips if the sample is missing).

Guidelines: keep each test fast where possible; avoid heavy I/O or very large documents unless the test is explicitly for that; use the same dependency injection as the rest of the suite.

---

## 9. Supported frame rates

Pipeline Neo targets the eight frame rates supported by Final Cut Pro for timeline and export: 23.976 (.fps23_976), 24 (.fps24), 25 (.fps25), 29.97 (.fps29_97, drop-frame tested), 30 (.fps30), 50 (.fps50), 59.94 (.fps59_94, drop-frame tested), 60 (.fps60). They are collected in the test constant fcpSupportedFrameRates and used in testAllSupportedFrameRates, testCMTimeModularExtensionsWithAllFrameRates, testTimeConformingWithDifferentFrameDurations, and testPerformanceTimecodeConversionAllFrameRates. The FCPXML DTDs mention other values (e.g. conform-rate); the suite focuses on these eight.

---

## 10. FCPXML versions

Document manager tests create documents for FCPXML 1.5 through 1.14 and assert valid structure and resource/sequence handling. Parsing and validation use samples valid for their declared version; invalid XML is covered in testParserWithInvalidXML. DTDs live under Sources/PipelineNeo/FCPXML DTDs/; the suite does not exhaustively test every version-specific DTD attribute.

---

## 11. Sample files

Sample FCPXML files live at Tests/FCPXML Samples/FCPXML/ (sibling of PipelineNeoTests). Paths are resolved at runtime via packageRoot(relativeToFile: #file), so tests work from Xcode and swift test without adding bundle resources. TestResources.swift provides packageRoot, fcpxmlSamplesDirectory(), and urlForFCPXMLSample(named:). FCPXMLTestUtilities provides loadFCPXMLSampleData(named:) and loadFCPXMLSample(named:), which throw XCTSkip when the file is missing so the suite can run with a subset of samples.

---

## 12. Writing and organising tests

Naming: use test<FeatureOrBehaviour> (e.g. testAllSupportedFrameRates, testParserWithInvalidXML). Place new tests under the appropriate MARK section in the relevant file and keep this README updated.

Structure: use arrange–act–assert. In async tests use async throws and await. In performance tests use measure { } and avoid blocking or heavy I/O unless the test is for that. Concurrency: the main test class is @unchecked Sendable; shared properties are set in setUpWithError and cleared in tearDownWithError. Prefer async tests and await; for concurrent behaviour use withTaskGroup or async lets as in testSwift6ConcurrencySendableServiceInTaskGroup.

Adding a file test: add a new class under FileTests/ (e.g. FCPXMLFileTest_<Name>.swift). Use loadFCPXMLSample(named:) when the sample must exist, or urlForFCPXMLSample(named:) with FileManager.default.fileExists and XCTSkip when optional. Assert on fcpxml.root.element, fcpxml.version, fcpxml.allEvents(), fcpxml.allProjects(), resources, etc. as appropriate.

Adding logic/parsing tests: add under LogicAndParsing/ for model types (Version, structure, parsing rules) rather than a single sample file.

---

## 13. Continuous integration

GitHub Actions (e.g. .github/workflows/build.yml) run on push and pull requests. Jobs typically build and run unit tests (Xcode workspace, xcodebuild), with Swift 6 and strict concurrency where applicable. All tests must pass with no regressions.

---

## 14. Debugging tests

Run a single test with `swift test --filter testMethodName` or run the test in Xcode (diamond next to the method). Use print or breakpoints as needed; avoid leaving noisy prints in committed code. For async tests that hang, check for missing await or blocking work on the main actor. Prefer deterministic data and injected dependencies to avoid flakiness.

---

## 15. Contributing to tests

Add tests for new behaviour or edge cases; place them in the right file and MARK section and keep names descriptive. Update this README when adding a category or changing what a section covers. For "all FCP frame rates" use fcpSupportedFrameRates. Prefer minimal in-memory FCPXML or small fixtures; document assumptions (e.g. temp URL) in a comment or here.

---

## 16. Resources

XCTest (Apple documentation). Testing in Xcode (Apple documentation). Pipeline Neo README (project root) for overview and API usage. Final Cut Pro XML (FCPXML) at fcp.cafe for format reference. SwiftTimecode (GitHub) for timecode and frame rate types used by Pipeline Neo.

---

## 17. Resolving common test/build messages

Swift PM cache warnings: Messages like "configuration is not accessible or not writable" and "Caches is not accessible or not writable" mean Swift Package Manager cannot write to `~/Library/org.swift.swiftpm/` or `~/Library/Caches/org.swift.swiftpm/`. To resolve: ensure those directories exist and your user has write permission (e.g. `mkdir -p ~/Library/org.swift.swiftpm ~/Library/Caches/org.swift.swiftpm` and correct ownership). When running in a restricted environment (e.g. CI or sandbox), the warnings are harmless; Swift PM falls back to process-local cache.

Invalid connection: com.apple.coresymbolicationd: This is a macOS system message from the symbolication daemon. It is not from Pipeline Neo and does not affect test results. It can be ignored. There is no project-level fix.

Couldn't find the DTD file / Error setting the DTD: The DTD validator looks for FCPXML DTDs in (1) the PipelineNeo module bundle (root and "FCPXML DTDs" subdirectory), (2) all loaded bundles, (3) all frameworks with a "DTDs" subdirectory. DTDs live in `Sources/PipelineNeo/FCPXML DTDs/` and are declared in Package.swift with `.process("FCPXML DTDs")`. If you still see these messages when running tests, ensure you build and run from the package root (`swift build && swift test`). When the DTD is not found, the validator returns a result with a dtdValidation error; the test is written to accept either success or that error. To eliminate the messages, the lookup must find the DTD (correct Package.swift resources and running from package root).

Performance test relative standard deviation: XCTest prints measured average and relative standard deviation (RSD) for each `measure { }` run. These lines are informational; the tests pass as long as the run completes. High RSD is common for very fast operations (e.g. timecode conversion). To reduce variation you can record a baseline in Xcode (Editor → Add Baseline) or increase the number of iterations in the measure block. The suite does not fail on RSD unless a baseline is set and exceeded.

---

## 18. Credits

Inspired and modeled after [swift-daw-file-tools](https://github.com/orchetect/swift-daw-file-tools)'s Test Suites.
