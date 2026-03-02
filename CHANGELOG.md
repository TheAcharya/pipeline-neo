# Changelog

All notable changes to Pipeline Neo are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).  
Pipeline Neo uses **New Features**, **Improvements**, and **Bug Fixes** for each release.

---

## [2.4.1](https://github.com/TheAcharya/pipeline-neo/releases/tag/2.4.1) - 2026-03-02

### ✨ New Features

- None in this release.

### 🔧 Improvements

- **Test suite:** Expanded to **655 tests**. Added in TimelineExportValidationTests: testFCPXMLExporterExportsClipMarkers, testFCPXMLExporterExportsClipChapterMarkers, testFCPXMLExporterExportsClipKeywords, testFCPXMLExporterExportsClipRatings, testFCPXMLExporterExportsClipMetadata, testFCPXMLExporterClipMetadataAllTypesValidatesAgainstDTD (export with all metadata types then DTD validate), testFCPXMLExporterXmlDeclarationStandaloneNo (assert exported XML uses standalone="no" for DTD/xmllint compatibility).
- **PR #14 (clip-level metadata export):** Test coverage for FCPXMLExporter exporting clip-level metadata (markers, chapter-markers, keywords, ratings, custom metadata) as children of `<asset-clip>` per FCPXML DTD; tests in TimelineExportValidationTests; Tests/README.md updated with coverage and XML declaration standalone note. Thanks @stovak!
- **TimelineManipulationTests:** Addressed GitHub Code Scan findings: replaced actor-based `NowBox` + `DispatchSemaphore` with a lock-based class (`NSLock`) to avoid thread exhaustion and deadlock risk when providing injectable "now" in timestamp tests; replaced `XCTAssertNoThrow` with do-catch and non-optional bindings for `insertClipAutoLane` and `insertingClipAutoLane` to properly verify success and handle thrown errors.

### 🐛 Bug Fixes

- **xmllint / DTD validation:** Resolved "standalone" warnings when validating exported FCPXML with `xmllint --dtdvalid`. XML declaration now outputs `standalone="no"` instead of removing the attribute, so libxml2 treats the document as dependent on an external DTD and no longer warns about whitespace nodes from pretty-printing. Change in XMLDocumentExtension.fcpxmlString.

---

## [2.4.0](https://github.com/TheAcharya/pipeline-neo/releases/tag/2.4.0) - 2026-02-23

### ✨ New Features

- **CLI `--create-project`:** Create a new empty FCPXML project from the command line. Under the TIMELINE section: `--create-project` with `--width`, `--height`, `--rate`, optional `--version` (default 1.14), and a single positional output directory. Project name is derived from format (e.g. `1920x1080@25p`). Mandatory DTD validation after build and before write; FCP-style output with DOCTYPE, format `colorSpace`, and optional default smart collections. Logging options (`--log`, `--log-level`, `--quiet`) apply to create-project output.
- **FCPXMLExporter:** New `includeDefaultSmartCollections` parameter (default `false`). When `true`, adds five FCP-style default smart collections under the library (Projects, All Video, Audio Only, Stills, Favorites). Exported document includes DOCTYPE; format elements always include `name` and `colorSpace` for compatibility with Final Cut Pro.

### 🔧 Improvements

- **Test suite:** Expanded to **648 tests**. Added `testEmptyTimelineCreationAtDifferentSizesAndFrameRates` (barebone empty `Timeline` at multiple sizes and frame rates: 720p, 1080p, 4K UHD, DCI 4K, custom 640×480; asserts name, clips, duration, format, aspectRatio). Added `testProjectCreationStyleExportValidatesAgainstDTD` (empty timeline export with `includeDefaultSmartCollections`, parse, and DTD validation). Added `testProjectCreationAtDifferentSizesAndFrameRates` (export at multiple sizes and frame rates, then parse and validate against DTD).
- **Documentation:** Updated `.cursorrules`, `AGENT.md`, `Tests/README.md`, and `README.md` with CLI create-project, test count 648, and empty timeline / project-creation test coverage. Manual (Timeline & Export, CLI, Examples) and `Sources/PipelineNeoCLI/README.md` updated for create-project usage and TIMELINE options.

### 🐛 Bug Fixes

- **FCP import:** Resolved "No declaration for attribute name of element library" by no longer writing a `name` attribute on the `library` element (FCPXML DTD allows only `location` and `colorProcessing`).
- **FCP import:** Resolved "unexpected value" for `format="r1"` by always writing a format `name` (e.g. `FFVideoFormatRateUndefined` for custom dimensions) and `colorSpace` on format elements in exported FCPXML.

---

## [2.3.1](https://github.com/TheAcharya/pipeline-neo/releases/tag/2.3.1) - 2026-02-18

### ✨ New Features

- None in this release.

### 🔧 Improvements

- **Test suite:** Expanded to **638 tests** (from 587). Added comprehensive file tests for new FCPXML samples: `FCPXMLFileTest_360Video` (360 video features, color conform, bookmarks, smart collections), `FCPXMLFileTest_AuditionSample` (audition elements, conform-rate, keywords), `FCPXMLFileTest_ImageSample` (still image assets), `FCPXMLFileTest_Multicam` (multicam resources and clips), `FCPXMLFileTest_Photoshop` (Photoshop-specific FCPXML), `FCPXMLFileTest_SmartCollection` (smart collection parsing across multiple samples with match-clip, match-media, match-ratings). Updated existing file tests: `FCPXMLFileTest_CompoundClips` (CompoundClipSample), `FCPXMLFileTest_Keywords` (EventsWithKeywords, KeywordsWithinFolders), `CaptionTitleTests` (CaptionSample), `TimelineManipulationTests` (TimelineSample, TimelineWithSecondaryStoryline, TimelineWithSecondaryStorylineWithAudioKeyframes), `CutDetectionTests` (CutSample).
- **Audio keyframe tests:** Added `AudioKeyframeTests` (10 tests) for comprehensive audio keyframe validation: parsing `adjust-volume > param name="amount" > keyframeAnimation > keyframe` structures from FCPXML samples; decibel value validation (-3dB, -37dB format); time value validation (FCPXML fractional format); fadeIn/fadeOut integration; multiple keyframes in sequence; secondary storyline and nested clip detection. File tests: `TimelineWithSecondaryStorylineWithAudioKeyframes`, `TimelineSample`.
- **FCPXML samples:** Added 15 new sample files covering 360 video, auditions, conform-rate, still images, multicam, secondary storylines, audio keyframes, keyword collections/folders, and Photoshop integration. All samples verified for parsing and feature extraction.
- **Documentation:** Updated `Tests/README.md` with new test files (including `AudioKeyframeTests`), expanded file tests table, updated test count to 638, and enhanced scope description to include new FCPXML features tested.

### 🐛 Bug Fixes

- None in this release.

---

## [2.3.0](https://github.com/TheAcharya/pipeline-neo/releases/tag/2.3.0) - 2026-02-16

### ✨ New Features

- **Live Drawing (FCPXML 1.11+):** Typed `LiveDrawing` model for the `live-drawing` story element (drawn/sketch content). Attributes: `role`, `dataLocator`, `animationType`; conforms to `FCPXMLElementClipAttributes` and `FCPXMLElementMetaTimeline`. Wired into `allTimelineCases`, `FCPXMLAnyTimeline` (`.liveDrawing(LiveDrawing)`), and `ElementModelType` / `AnyElementModelType`. Tests in APIAndEdgeCaseTests (init, attributes, AnyTimeline round-trip).
- **HiddenClipMarker (FCPXML 1.13+):** Typed `HiddenClipMarker` model (empty marker element). Included in `fcpxAnnotations` and `addToClip(annotationElements:)`. Version converter strips `hidden-clip-marker` when converting to &lt; 1.13. Tests in APIAndEdgeCaseTests and VersionConversionTests.
- **Format and Asset 1.13+:** Format `heroEye` (left | right) and Asset `heroEyeOverride`, `mediaReps` (multiple `media-rep`) with get/set, inits, and round-trip. Version converter strips `heroEye`/`heroEyeOverride` when converting to &lt; 1.13. Tests in FCPXMLFormatAssetTests and VersionConversionTests.
- **SmartCollection match rules:** Typed models and SmartCollection properties for `MatchUsage` (1.9+), `MatchRepresentation`, `MatchMarkers` (1.10+), `MatchAnalysisType` (1.14). Round-trip and version stripping. Tests in SmartCollectionTests.
- **Additional typed adjustments and Clip integration:** `ReorientAdjustment`, `OrientationAdjustment` (1.7+), `CinematicAdjustment` (1.10+), `ColorConformAdjustment` (1.11+), `Stereo3DAdjustment` (1.13+), `VoiceIsolationAdjustment` (1.14), `ConformAdjustment`, `RollingShutterAdjustment` with Clip accessors (`reorientAdjustment`, `orientationAdjustment`, `cinematicAdjustment`, `colorConformAdjustment`, `stereo3DAdjustment`, `voiceIsolationAdjustment`, `conformAdjustment`, `rollingShutterAdjustment`). Tests in AdjustmentTests.
- **FilterParameter and Keyframe auxValue (1.11+):** `FilterParameter` and `Keyframe` support `auxValue`; version converter strips param `auxValue` when target DTD does not include it. Tests in FilterTests.

### 🔧 Improvements

- **Version conversion:** `FCPXMLVersionConverter` uses DTD-derived allowlists (`FCPXMLDTDAllowlistGenerator.allowlist(fromDTDContent:)`) for element and attribute stripping; `EmbeddedDTDProvider` for CLI. Fallback to hand-maintained lists when DTD unavailable.
- **Documentation:** Manual restructured into chapter-based layout. New `Documentation/Manual/` with 18 files: 00-Index (table of contents), 01–17 covering Overview, Loading & Parsing, Timecode, Pipeline & Logging, Validation & Cut Detection, Version Conversion & Export, Timeline & Export, Timeline Manipulation, Timeline Metadata, Extraction & Media, Media Processing, Typed Models, XML Extensions, High-Level Model, Errors & Utilities, CLI, and Examples. `Documentation/README.md` updated with manual index and chapter links. Root `Documentation/Manual.md` now redirects to the structured manual.
- **Documentation:** Typed Models chapter (12) documents Live Drawing, HiddenClipMarker, Format/Asset 1.13+, SmartCollection match rules, and all adjustment/filter/caption/keyframe/collection models with examples.
- **Tests:** `Tests/README.md` reorganized with clear sections: table of contents by category (Structure & running, Coverage, Reference, Contributing & troubleshooting), test structure tree, shared utilities summary, tables for PipelineNeoTests MARK categories and for file tests (class | sample | asserts), and dedicated test files grouped by theme. Test count updated to **587 tests**. Added FCPXMLFormatAssetTests (LogicAndParsing).
- **Project rules:** `.cursorrules` and `AGENT.md` updated (backward compatibility note, Changelog section with styling: version links to release tags, ✨ New Features / 🔧 Improvements / 🐛 Bug Fixes).
- **FCPXMLClip+Adjustments:** Attribute names (e.g. `amount`, `enabled`, `type`) centralized in a private `AttributeName` enum to avoid typos and improve maintainability.
- **FCPXMLTitle+Typed:** Simplified optional-bold/italic/underline assignment from `condition ? true : nil` to `if condition { textStyle.property = true }` for clarity.
- **MediaRep:** Conforms to `@unchecked Sendable` for concurrent usage; bookmark child documented (single `bookmark` element for security-scoped bookmark data).

### 🐛 Bug Fixes

- **Gap `lane` setter:** Replaced `assertionFailure` with a no-op so setting `lane` on a gap clip no longer risks a crash in production.
- **MediaRep:** Added `FCPXMLElement` conformance so `_isElementTypeSupported` is correctly available and the type is consistent with other element models.
- **MediaRep init(bookmark: String):** Uses lossy UTF-8 encoding so the string-to-data conversion cannot fail silently by returning `nil`.

---

## [2.2.0](https://github.com/TheAcharya/pipeline-neo/releases/tag/2.2.0) - 2026-02-14

### ✨ New Features

- **Typed adjustment models:** `CropAdjustment`, `TransformAdjustment`, `BlendAdjustment`, `StabilizationAdjustment`, `VolumeAdjustment`, `LoudnessAdjustment` with full `Clip` integration via computed properties.
- **Audio enhancement adjustments:** `NoiseReductionAdjustment`, `HumReductionAdjustment`, `EqualizationAdjustment`, `MatchEqualizationAdjustment` with parameter validation and `Clip` integration.
- **Transform360:** `Transform360Adjustment` model for 360° video (coordinate types spherical/cartesian, position/orientation, auto-orient, convergence, interaxial) with `Clip` integration.
- **Typed filter models:** `VideoFilter`, `AudioFilter`, `VideoFilterMask`, `FilterParameter` with keyframe animation support (`FadeIn`, `FadeOut`, `KeyframeAnimation`).
- **Caption and Title models:** `Caption` and `Title` with `TextStyle` and `TextStyleDefinition` for rich text formatting (font, fontSize, textAlignment, etc.).
- **Keyframe animation:** `KeyframeAnimation`, `Keyframe` (interpolation types), `FadeIn`/`FadeOut` (fade types), integrated with `FilterParameter`.
- **CMTime Codable:** Direct `CMTime` encoding/decoding as FCPXML time strings (`"value/timescale"s` format).
- **Collection organization:** `CollectionFolder` and `KeywordCollection` models for organizing clips and media with nested folder structures.

### 🔧 Improvements

- **CutDetector:** Edit type classification for non-adjacent clips now prioritizes transitions over gaps when multiple elements exist between clips.
- **XMLElementExtension:** Synchronized clip matching fixed to prevent duplicate entries when multiple nested children match the same resource.
- **XMLElementExtension:** Compound clip traversal fixed to properly check secondary storylines (spine elements) for matching resources.
- **XMLElementExtension:** `childElementsWithinRangeOf` now explicitly handles elements with missing timing attributes (`fcpxOffset`/`fcpxDuration`).
- **MediaExtractor:** URL resolution documentation enhanced for `nil` URLs and non-file URLs (automatically skipped during copy).
- **FCPXMLVersionConverter:** Explicit error handling for edge case where `rootElement()` returns `nil` during version conversion (debug assertion in development builds).
- **FCPXMLUtility:** Added validation methods `validateDocumentAgainstDTD`, `validateDocumentAgainstDeclaredVersion`, `performValidation` for API parity with `FCPXMLService` (sync and async).
- **FCPXMLUtility:** Added `filterElements(_:ofTypes:)` alias for API consistency with `FCPXMLService`.
- **ModularUtilities:** Validator instance creation optimized using a shared static validator instance.
- **FCPXMLUtility:** Refactored deprecated project time conversion methods (`projectTimecode`, `projectCounterTime`) to delegate to sequence methods, removing duplication.
- **FCPXMLService / FCPXMLUtility:** Async validation method documentation improved (CPU-bound behavior, non-Sendable type constraints).
- **ProgressBar:** Thread safety documentation enhanced with usage guidelines.
- **ProgressReporter:** Protocol documentation clarified for thread safety expectations.
- **Test suite:** Expanded to 535 tests; added AdjustmentTests, AudioEnhancementTests, Transform360Tests, CaptionTitleTests, KeyframeAnimationTests, CMTimeCodableTests, CollectionTests, FilterTests, CodableTests, ImportOptionsTests, SmartCollectionTests.
- **Documentation:** AGENT.md, .cursorrules, Tests/README.md, README.md, Documentation/Manual.md, and Documentation/README.md updated for new features and test count.

### 🐛 Bug Fixes

- None explicitly called out in this release (improvements above include behavioral fixes in CutDetector and XMLElementExtension).

---

## [2.1.0](https://github.com/TheAcharya/pipeline-neo/releases/tag/2.1.0) - 2026-02-13

### ✨ New Features

- **Timeline manipulation:** Ripple insert (shifts subsequent clips), auto lane assignment, clip queries (by lane, time range, asset ID), lane range computation.
- **Timeline metadata:** Markers, chapter markers, keywords, ratings, custom metadata on timeline and clips.
- **Timestamps:** `createdAt` and `modifiedAt` on Timeline (auto-updated on mutations).
- **FCPXMLTimecode:** Custom timecode type wrapping Fraction (arithmetic, frame alignment, CMTime conversion, FCPXML string parsing).
- **MIME type detection:** `MIMETypeDetection` protocol with UTType + AVFoundation support (video/audio/image formats).
- **Asset validation:** `AssetValidation` protocol (existence + MIME compatibility with lanes: negative = audio only, non-negative = video/image/audio).
- **Silence detection:** `SilenceDetection` protocol (silence at start/end of audio; threshold, minimum duration).
- **Asset duration measurement:** `AssetDurationMeasurement` protocol (actual duration from AVFoundation for audio/video/images).
- **Parallel file I/O:** `ParallelFileIO` protocol for concurrent read/write operations.

### 🔧 Improvements

- **TimelineFormat:** Presets (hd720p, dci4K, hd1080i, hd720i); computed properties (aspectRatio, isHD, isUHD, isDCI4K, isStandard4K, is1080p, is720p, interlaced).
- **TimelineError:** New cases `assetNotFound`, `invalidFormat`, `invalidAssetReference`.
- **Test suite:** Expanded to 320 tests (TimelineManipulationTests, FCPXMLTimecodeTests, MIMETypeDetectionTests, AssetValidationTests, SilenceDetectionTests, AssetDurationMeasurementTests, ParallelFileIOTests).
- **CI:** Added CodeQL workflow.
- **Documentation:** Manual.md and Tests README updated with new APIs and examples.

### 🐛 Bug Fixes

- None documented in this release.

---

## [2.0.1](https://github.com/TheAcharya/pipeline-neo/releases/tag/2.0.1) - 2026-02-11

### ✨ New Features

- **CLI:** `--log`, `--log-level`, `--quiet`; `--extension-type` for convert (fcpxmld | fcpxml; default fcpxmld; 1.5–1.9 always .fcpxml); `--extract-media` renamed to `--media-copy` under EXTRACTION; `--validate` (semantic + DTD; progress when not quiet). Single binary with embedded DTDs.
- **Progress bar:** TQDM-style progress for `--media-copy` and `--validate`.
- **Logging:** When `--log` is set, all CLI commands write user-visible output to the log file.

### 🔧 Improvements

- **Logging:** Seven levels (trace–critical); optional file + console; quiet mode.
- **Semantic validation:** Refs resolved against all element IDs (e.g. text-style-def in titles), not only top-level resources.
- **Library:** `FCPXMLVersion.supportsBundleFormat` (1.10+ for .fcpxmld; 1.5–1.9 .fcpxml only).
- **Scripts:** `generate_embedded_dtds.sh` / `swift run GenerateEmbeddedDTDs` regenerate EmbeddedDTDs.swift (1.5→1.14); Scripts/README; Xcode Build post-actions remove generator binary after build.
- **Service:** Logs parse, convert, save, DTD validate, media extract/copy.
- **Test suite:** 181 tests.
- **Documentation:** README, Manual, CLI README, Documentation/, Scripts, .cursorrules, AGENT.md updated.

### 🐛 Bug Fixes

- None documented in this release.

---

## [2.0.0](https://github.com/TheAcharya/pipeline-neo/releases/tag/2.0.0) - 2026-02-09

### ✨ New Features

- **Cut detection:** Find edit points on a timeline (hard cut, transition, gap); same-clip vs different-clips.
- **Version conversion:** Convert FCPXML to another version (e.g. 1.14 → 1.10) with automatic cleanup; save as single file or bundle.
- **Document validation:** Validate against a specific FCPXML version (1.5–1.14) or against the document’s declared version.
- **Media extraction and copy:** Find all referenced media and copy to a folder (deduplicated).
- **Experimental CLI (`pipeline-neo`):** Check document version, convert to target version, extract media to folder.

### 🔧 Improvements

- **Architecture:** Full codebase rewrite with protocol-oriented design.
- **Test suite:** Expanded to 177 tests.
- **Documentation:** Manual, README, and project docs updated.

### 🐛 Bug Fixes

- None documented in this release.

---

## [1.1.0](https://github.com/TheAcharya/pipeline-neo/releases/tag/1.1.0) - 2026-02-06

### ✨ New Features

- **FCPXML 1.14:** DTD and version support for 1.14; documentation, tests, and CI cover 1.5 through 1.14.
- **Element-type coverage:** Full DTD element-type coverage via `FCPXMLElementType` (tag names, inferred types, filtering across parser and utility).
- **Single injection point:** Extension APIs use `FCPXMLUtility.defaultForExtensions`; custom pipelines use modular API with dependency injection.

### 🔧 Improvements

- **Dependencies:** Integrated [swift-extensions](https://github.com/orchetect/swift-extensions).
- **Concurrency:** Sendable compliance across protocols and implementations; async/await APIs throughout.
- **Test suite:** Expanded to 66 tests; FCPXML time strings (valid/invalid).
- **Errors:** `FCPXMLError` and public option enums marked `Sendable`; error descriptions verified for all cases.

### 🐛 Bug Fixes

- None documented in this release.

---

## [1.0.2](https://github.com/TheAcharya/pipeline-neo/releases/tag/1.0.2) - 2025-11-30

### ✨ New Features

- None in this release.

### 🔧 Improvements

- **Dependencies:** Migrated from TimecodeKit to SwiftTimecode 3.0.0. Package dependency updated to `https://github.com/orchetect/swift-timecode`. All imports updated; Timecode initializer updated to `Timecode(.realTime(seconds:), at: frameRate)`; frame rate cases updated to `.fps24`, `.fps25`, `.fps29_97`, `.fps30`, `.fps50`, `.fps59_94`, `.fps60`, `.fps23_976`. Documentation and version references updated. Task-based concurrency avoided for Foundation XML and SwiftTimecode types (Sendable limitations).

### 🐛 Bug Fixes

- None documented in this release.

---

## [1.0.1](https://github.com/TheAcharya/pipeline-neo/releases/tag/1.0.1) - 2025-07-11

### ✨ New Features

- **Async/await:** Comprehensive async/await support across all major operations. All protocols, implementations, services, and utilities have async methods.

### 🔧 Improvements

- **Concurrency:** Enhanced concurrency safety with Sendable compliance; async error propagation; thread-safe implementation and resource management.
- **Test suite:** Updated to 66 comprehensive tests with async/await coverage.
- **Documentation:** Async/await usage examples added.
- **Architecture:** Protocol-oriented design with both sync and async APIs; task-based concurrency avoided for Foundation XML and TimecodeKit types; performance optimizations for async operations.

### 🐛 Bug Fixes

- None documented in this release.

---

## [1.0.0](https://github.com/TheAcharya/pipeline-neo/releases/tag/1.0.0) - 2025-07-10

### ✨ New Features

- First public release of **Pipeline Neo**.

### 🔧 Improvements

- N/A

### 🐛 Bug Fixes

- N/A
