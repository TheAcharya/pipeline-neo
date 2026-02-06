# Pipeline Neo — Test Suite

This directory contains the test suite for **Pipeline Neo**, a Swift 6 framework for Final Cut Pro FCPXML processing with SwiftTimecode integration. The tests ensure correctness, concurrency safety, and performance across parsing, timecode conversion, document and element operations, and all supported FCPXML versions and frame rates.

---

## Table of Contents

1. [Test structure](#1-test-structure)
2. [Running tests](#2-running-tests)
3. [Test categories and coverage](#3-test-categories-and-coverage)
4. [Supported frame rates](#4-supported-frame-rates)
5. [FCPXML versions](#5-fcpxml-versions)
6. [Performance tests](#6-performance-tests)
7. [Writing and organising tests](#7-writing-and-organising-tests)
8. [Continuous integration](#8-continuous-integration)
9. [Debugging tests](#9-debugging-tests)
10. [Contributing to tests](#10-contributing-to-tests)
11. [Resources](#11-resources)

---

## 1. Test structure

```
Tests/
├── README.md                    # This file
└── PipelineNeoTests/
    ├── PipelineNeoTests.swift   # Main test suite (67+ tests)
    └── XCTestManifests.swift    # Linux test discovery
```

- **PipelineNeoTests.swift** — Single test class `PipelineNeoTests` with shared dependencies (parser, timecode converter, document manager, error handler) injected in `setUpWithError`. All tests use these instances for consistency and to validate the modular, protocol-oriented API.
- **XCTestManifests.swift** — Exposes the test cases for Swift Package Manager on Linux.

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

1. Open the package (e.g. **File → Open** the folder or `.swiftpm` workspace).
2. Select the **PipelineNeo** scheme.
3. **⌃⌘U** (or **Product → Test**) to run all tests.
4. Use the **Test Navigator** (⌘6) to run or re-run individual tests.

### Linux

Tests are discoverable on Linux via `XCTestManifests.swift`. Run with `swift test` in a Linux environment that provides XCTest.

---

## 3. Test categories and coverage

The test file is organised with `// MARK: -` sections. Below is a concise map of **categories → tests** and what they cover.

| Category | Tests | What they cover |
|----------|--------|------------------|
| **Test dependencies / setup** | (shared) | `setUpWithError` / `tearDownWithError`; creation of parser, timecodeConverter, documentManager, errorHandler, FCPXMLUtility, FCPXMLService. |
| **FCPXMLUtility** | `testFCPXMLUtilityInitialisation`, `testFilterElements`, `testCMTimeFromFCPXMLTime`, `testFCPXMLTimeFromCMTime`, `testConformTime` | Utility init, element filtering by `FCPXMLElementType`, CMTime ↔ FCPXML time string, time conforming to frame duration. |
| **FCPXMLService** | `testFCPXMLServiceInitialisation`, `testCreateFCPXMLDocument`, `testTimecodeConversion`, `testCMTimeFromTimecode` | Service init, document creation, timecode and CMTime conversion via service. |
| **Modular components** | `testParserComponent`, `testTimecodeConverterComponent`, `testDocumentManagerComponent`, `testErrorHandlerComponent` | Parser parse/validate, TimecodeConverter round-trip, DocumentManager create/add resource, ErrorHandler message formatting. |
| **Modular utilities** | `testModularUtilitiesCreatePipeline` | `ModularUtilities.createPipeline()` returns a configured `FCPXMLService`. |
| **Async / concurrency** | `testSwift6ConcurrencySendableServiceInTaskGroup`, `testAsyncParserComponent`, `testAsyncTimecodeConverterComponent`, `testAsyncDocumentManagerComponent`, `testAsyncFCPXMLService`, `testAsyncModularUtilities`, `testAsyncElementFiltering`, `testAsyncTimeConforming`, `testAsyncFCPXMLTimeStringConversion`, `testAsyncXMLElementOperations`, `testAsyncConcurrentOperations` | Sendable service in `TaskGroup`, async parser/timecode/document/service/utilities/element filtering/time conforming/FCPXML time/XML element ops; concurrent async operations. |
| **Performance (basic)** | `testPerformanceFilterElements`, `testPerformanceTimecodeConversion` | Filter-elements and timecode conversion throughput. |
| **Frame rate** | `testAllSupportedFrameRates`, `testDropFrameTimecode` | All 8 FCP-supported frame rates (timecode round-trip); drop-frame (29.97, 59.94). |
| **Time values** | `testVariousTimeValues`, `testLargeTimeValues` | Various and large CMTime values; round-trip via timecode converter. |
| **FCPXML time strings** | `testFCPXMLTimeStringFormats`, `testInvalidFCPXMLTimeStrings` | Valid `value/timescale` formats and round-trip; invalid strings (empty, malformed, wrong count) → `CMTime.zero`. |
| **Time conforming** | `testTimeConformingWithDifferentFrameDurations` | `conform(time:toFrameDuration:)` for all 8 FCP frame durations; conformed time is multiple of frame duration. |
| **Error handling** | `testErrorHandlerWithAllErrorTypes`, `testParserWithInvalidXML` | ErrorHandler for FCPXMLError cases; parser with invalid XML. |
| **Document management** | `testDocumentManagerWithAllFCPXMLVersions`, `testDocumentManagerWithComplexStructure` | Document creation for FCPXML versions 1.5–1.14; add resources/sequences and validate structure. |
| **Element filtering** | `testElementFilteringWithAllElementTypes`, `testElementFilteringWithExtendedElementTypes`, `testElementFilteringWithAllFCPXMLElementTypes` | Filter by core and extended types; filter by every `FCPXMLElementType` (full DTD element coverage). |
| **Modular extensions** | `testCMTimeModularExtensionsWithAllFrameRates`, `testXMLElementModularExtensionsWithComplexAttributes`, `testXMLDocumentModularExtensionsWithComplexStructure` | CMTime timecode/fcpxmlTime/conformed with converter; XMLElement setAttribute/getAttribute/createChild; XMLDocument addResource/addSequence/isValid. |
| **Performance (params)** | `testPerformanceTimecodeConversionAllFrameRates`, `testPerformanceDocumentCreation`, `testPerformanceElementFilteringLargeDataset` | Timecode conversion for all frame rates; document creation loop; element filtering over large dataset. |
| **Edge cases** | `testEdgeCaseTimeValues`, `testConcurrencySafety` | Edge time values (zero, very small, large); concurrent timecode conversion (DispatchQueue). |
| **FCPXMLElementType** | `testFCPXMLElementTypeTagNameAndIsInferred` | `tagName` and `isInferred` for multicam/compound/asset/sequence/clip/none. |
| **FCPXMLError** | `testFCPXMLErrorAllCasesHaveDescription` | Every `FCPXMLError` case has non-empty `errorDescription`. |
| **ModularUtilities API** | `testModularUtilitiesCreateCustomPipeline`, `testModularUtilitiesValidateDocumentReturnsErrorsForInvalidDocument`, `testModularUtilitiesProcessFCPXMLFromDataViaTempURL`, `testModularUtilitiesProcessMultipleFCPXML`, `testModularUtilitiesConvertTimecodes` | Custom pipeline; validateDocument (invalid doc); processFCPXML from URL; processMultipleFCPXML; convertTimecodes (placeholder). |
| **XMLDocument extension** | `testXMLDocumentExtensionFcpxEventNamesAndAddEvents`, `testXMLDocumentExtensionResourceMatchingIDAndRemove`, `testXMLDocumentExtensionFcpxmlStringAndVersion`, `testXMLDocumentContentsOfFCPXMLInitializer` | fcpxEventNames, add(events:); resource(matchingID:), remove(resourceAtIndex:); fcpxmlString, fcpxmlVersion; `init(contentsOfFCPXML:)`. |
| **XMLElement extension** | `testXMLElementExtensionFcpxTypeAndIsFCPX`, `testXMLElementExtensionFcpxTypeMediaWithFirstChildMulticamOrSequence`, `testXMLElementExtensionFcpxEventAndEventClips`, `testXMLElementExtensionFcpxDuration`, `testXMLElementExtensionEventClipsThrowsWhenNotEvent` | fcpxType (asset, sequence, clip, locator, media+multicam/sequence); isFCPXResource, isFCPXStoryElement; fcpxEvent, eventClips, addToEvent, removeFromEvent; fcpxDuration get/set; eventClips throws when not event. |
| **Parser filter** | `testParserFilterMulticamAndCompoundResources`, `testFCPXMLUtilityDefaultForExtensions` | Filter media by first child (multicam/compound); `FCPXMLUtility.defaultForExtensions` filtering. |

---

## 4. Supported frame rates

Pipeline Neo targets the **eight frame rates** supported by Final Cut Pro for timeline and export:

| Frame rate | SwiftTimecode / tests |
|------------|------------------------|
| 23.976 fps | `.fps23_976` |
| 24 fps     | `.fps24` |
| 25 fps     | `.fps25` |
| 29.97 fps  | `.fps29_97` (drop-frame tested) |
| 30 fps     | `.fps30` |
| 50 fps     | `.fps50` |
| 59.94 fps  | `.fps59_94` (drop-frame tested) |
| 60 fps     | `.fps60` |

These are collected in the test constant **`fcpSupportedFrameRates`** and used in:

- `testAllSupportedFrameRates` — timecode round-trip for each rate.
- `testCMTimeModularExtensionsWithAllFrameRates` — CMTime extension (timecode, fcpxmlTime, conform) for each rate.
- `testTimeConformingWithDifferentFrameDurations` — conform to frame boundary for each rate (using the corresponding `CMTime` frame duration).
- `testPerformanceTimecodeConversionAllFrameRates` — performance of timecode conversion across all rates.

The FCPXML DTDs also mention other values (e.g. 47.95, 48, 90, 100, 119.88, 120) for attributes like `conform-rate srcFrameRate`. The codebase and this test suite focus on the eight standard FCP frame rates above.

---

## 5. FCPXML versions

- **Document manager tests** create documents for **FCPXML 1.5 through 1.14** and assert valid structure and resource/sequence handling.
- **Parsing and validation** use sample FCPXML that is valid for the declared version; invalid XML is covered in `testParserWithInvalidXML`.
- **DTDs** are present under `Sources/PipelineNeo/FCPXML DTDs/` for reference and validation; the test suite does not exhaustively test every version-specific DTD attribute.

---

## 6. Performance tests

Performance is measured with `measure { ... }`; XCTest reports duration and relative standard deviation.

| Test | What is measured |
|------|-------------------|
| `testPerformanceFilterElements` | Filtering elements by type (repeated runs). |
| `testPerformanceTimecodeConversion` | Timecode conversion (single frame rate, repeated). |
| `testPerformanceTimecodeConversionAllFrameRates` | Timecode conversion for all 8 frame rates per iteration. |
| `testPerformanceDocumentCreation` | Creating FCPXML documents and adding a resource in a loop. |
| `testPerformanceElementFilteringLargeDataset` | Filtering a large set of elements by type. |

Guidelines:

- Keep each test fast (ideally &lt; 100 ms per iteration where possible).
- Avoid heavy I/O or large in-memory documents unless the test is explicitly for that.
- Use the same dependency injection (parser, documentManager, etc.) as the rest of the suite.

---

## 7. Writing and organising tests

### Naming and placement

- **Names:** `test<FeatureOrBehaviour>` (e.g. `testAllSupportedFrameRates`, `testParserWithInvalidXML`).
- **Placement:** Add new tests under the appropriate `// MARK: - ...` section in `PipelineNeoTests.swift` so the table in [Test categories and coverage](#3-test-categories-and-coverage) stays accurate.

### Structure (Arrange–Act–Assert)

```swift
// MARK: - Your Category
/// One-line summary of what this test validates.

func testYourFeature() {
    // Arrange — use shared utility, service, parser, etc.
    let input = ...

    // Act
    let result = utility.someMethod(input)

    // Assert
    XCTAssertNotNil(result)
    XCTAssertEqual(result, expected)
}
```

### Async tests

```swift
func testAsyncFeature() async throws {
    let result = await service.parseFCPXML(from: url)
    XCTAssertNotNil(result)
}
```

### Performance tests

```swift
func testPerformanceSomething() {
    measure {
        for _ in 0..<100 {
            // Operation to benchmark
        }
    }
}
```

### Concurrency

- The test class is `@unchecked Sendable`; shared properties are set in `setUpWithError` and cleared in `tearDownWithError`.
- Prefer `async` tests and `await` over raw threads. For concurrent behaviour, use `withTaskGroup` or async lets and assert inside the task (as in `testSwift6ConcurrencySendableServiceInTaskGroup`).

---

## 8. Continuous integration

- **GitHub Actions** (e.g. `.github/workflows/build.yml`) run on push/PR to the configured branches.
- Jobs typically include:
  - Build and unit tests (Xcode workspace, `xcodebuild`).
  - Swift 6 tools version and, where applicable, strict concurrency (`-strict-concurrency=complete`).
- **Requirements:** All tests must pass; no regressions in behaviour or (where baselines exist) performance.

---

## 9. Debugging tests

- **Single test:** Run with `swift test --filter testMethodName` or run the single test in Xcode (click the diamond next to the method).
- **Print / breakpoints:** Use `print(...)` or breakpoints; avoid leaving noisy prints in committed code.
- **Async:** If a test hangs, check for missing `await` or blocking work on the main actor.
- **Flakiness:** Prefer deterministic data and shared injected dependencies; avoid reliance on wall-clock time or unconstrained concurrency.

---

## 10. Contributing to tests

1. **Add tests** for new behaviour or edge cases; place them in the right `// MARK: -` section and keep names descriptive.
2. **Update this README** if you add a new category or change what a section covers (including the table in §3).
3. **Frame rates:** Use **`fcpSupportedFrameRates`** when testing “all FCP frame rates”; do not hard-code a subset unless the test is explicitly for that subset (e.g. drop-frame only).
4. **Test data:** Prefer minimal, in-memory FCPXML (e.g. string → `Data`) or small fixtures; document any assumption (e.g. file at temporary URL) in a comment or in this README.

---

## 11. Resources

- [XCTest](https://developer.apple.com/documentation/xctest) — Apple’s testing framework.
- [Testing in Xcode](https://developer.apple.com/documentation/xcode/testing-your-apps-in-xcode) — Running and writing tests.
- [Pipeline Neo README](../README.md) — Project overview and API usage.
- [Final Cut Pro XML (FCPXML)](https://fcp.cafe/developers/fcpxml/) — FCPXML format reference.
- [SwiftTimecode](https://github.com/orchetect/swift-timecode) — Timecode and frame rate types used by Pipeline Neo.
