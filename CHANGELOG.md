# Changelog

### 2.1.1

**🎉 Released:**
- TBA

**🔧 Improvements:**
- CutDetector: fixed edit type classification for non-adjacent clips (prioritizes transitions over gaps when multiple elements exist between clips)
- XMLElementExtension: fixed synchronized clip matching to prevent duplicate entries when multiple nested children match the same resource
- XMLElementExtension: fixed compound clip traversal to properly check secondary storylines (spine elements) for matching resources
- XMLElementExtension: improved `childElementsWithinRangeOf` to explicitly handle elements with missing timing attributes (`fcpxOffset`/`fcpxDuration`)
- MediaExtractor: enhanced URL resolution documentation for `nil` URLs and non-file URLs (automatically skipped during copy operations)
- FCPXMLVersionConverter: added explicit error handling for edge case where `rootElement()` returns `nil` during version conversion (debug assertion in development builds)
- FCPXMLUtility: added missing validation methods (`validateDocumentAgainstDTD`, `validateDocumentAgainstDeclaredVersion`, `performValidation`) for API parity with `FCPXMLService` (sync and async)
- FCPXMLUtility: added `filterElements(_:ofTypes:)` alias method for API consistency with `FCPXMLService` while maintaining backward compatibility
- ModularUtilities: optimized validator instance creation by using a shared static validator instance (eliminates repeated instance creation overhead)
- FCPXMLUtility: refactored deprecated project time conversion methods (`projectTimecode`, `projectCounterTime`) to properly delegate to sequence methods, eliminating code duplication
- FCPXMLService/FCPXMLUtility: enhanced async validation method documentation explaining CPU-bound validation behavior and non-Sendable type constraints
- ProgressBar: enhanced thread safety documentation with comprehensive warnings and usage guidelines (clarifies `@unchecked Sendable` does not imply thread safety)
- ProgressReporter: enhanced protocol documentation to clarify thread safety expectations for implementations
- Test suite: 340 tests (added CutDetectionTests, TimelineManipulationTests for synchronized clips and compound clips, MediaExtractionTests for URL resolution, VersionConversionTests for root element handling)
- Documentation: updated AGENT.md, .cursorrules, and Tests/README.md to reflect current test count

---

### 2.1.0

**🎉 Released:**
- 13th February 2026

**🔧 Improvements:**
- Timeline manipulation: ripple insert (shifts subsequent clips), auto lane assignment, clip queries (by lane, time range, asset ID), lane range computation
- Timeline metadata: markers, chapter markers, keywords, ratings, custom metadata on timeline and clips
- Timestamps: `createdAt` and `modifiedAt` on Timeline (auto-updated on mutations)
- FCPXMLTimecode: custom timecode type wrapping Fraction (arithmetic, frame alignment, CMTime conversion, FCPXML string parsing)
- MIME type detection: `MIMETypeDetection` protocol with UTType + AVFoundation support (video/audio/image formats)
- Asset validation: `AssetValidation` protocol validates existence + MIME compatibility with lanes (negative = audio only, non-negative = video/image/audio)
- Silence detection: `SilenceDetection` protocol detects silence at start/end of audio files (threshold, minimum duration)
- Asset duration measurement: `AssetDurationMeasurement` protocol measures actual duration from AVFoundation (audio/video/images)
- Parallel file I/O: `ParallelFileIO` protocol for concurrent read/write operations (performance optimization)
- TimelineFormat enhancements: presets (hd720p, dci4K, hd1080i, hd720i), computed properties (aspectRatio, isHD, isUHD, isDCI4K, isStandard4K, is1080p, is720p, interlaced)
- TimelineError: expanded with `assetNotFound`, `invalidFormat`, `invalidAssetReference` cases
- Test suite: 320 tests (added TimelineManipulationTests, FCPXMLTimecodeTests, MIMETypeDetectionTests, AssetValidationTests, SilenceDetectionTests, AssetDurationMeasurementTests, ParallelFileIOTests)
- Added CodeQL workflow
- Documentation: comprehensive Manual.md update with all APIs and examples, Tests README updated

---

### 2.0.1

**🎉 Released:**
- 11th February 2026

**🔧 Improvements:**
- Logging: seven levels (trace–critical), optional file + console, quiet mode; `--log` records user-visible output for all CLI commands
- CLI: `--log`, `--log-level`, `--quiet`; `--extension-type` for convert (fcpxmld | fcpxml; default fcpxmld; 1.5–1.9 always .fcpxml); `--extract-media` → `--media-copy` under EXTRACTION; `--validate` (semantic + DTD; progress when not quiet); single binary with embedded DTDs, no bundle
- Progress bar (TQDM-style) for `--media-copy` and `--validate`
- Semantic validation: refs resolved against all element IDs (e.g. text-style-def in titles), not only top-level resources
- Library: `FCPXMLVersion.supportsBundleFormat` (1.10+ for .fcpxmld; 1.5–1.9 .fcpxml only)
- Scripts: `generate_embedded_dtds.sh` / `swift run GenerateEmbeddedDTDs` regenerate EmbeddedDTDs.swift (version order 1.5→1.14); Scripts/README; Xcode Build post-actions remove generator binary after build
- Service logs parse, convert, save, DTD validate, media extract/copy
- Test suite: 181 tests
- Documentation updated (README, Manual, CLI README, Documentation/, Scripts, .cursorrules, AGENT.md)

---

### 2.0.0

**🎉 Released:**
- 9th February 2026

**🔧 Improvements:**
- Full codebase rewrite with a cleaner, protocol-oriented design
- Test suite expanded to 177 tests
- Cut detection: find edit points on a timeline (hard cut, transition, gap) and whether cuts are same-clip or different-clips
- Version conversion: convert FCPXML to another version (e.g. 1.14 → 1.10), with automatic cleanup so the result validates; save as a single file or bundle
- Document validation: check a file against a specific FCPXML version (1.5–1.14) or against its declared version
- Media extraction and copy: find all media referenced in a project and copy them to a folder (deduplicated)
- Experimental CLI (`pipeline-neo`): check document version, convert to a target version, or extract media to a folder
- Documentation updated (Manual, README, and project docs)

---

### 1.1.0

**🎉 Released:**
- 6th February 2026

**🔧 Improvements:**
- Integrated [swift-extensions](https://github.com/orchetect/swift-extensions)
- Added DTD and version support for 1.14; documentation, tests, and CI now cover 1.5 through 1.14
- Full DTD element-type coverage via `FCPXMLElementType`: tag names, inferred types (e.g. media by first child), and filtering by type across the parser and utility
- Single injection point for extension APIs via `FCPXMLUtility.defaultForExtensions`; extensions no longer instantiate concrete types internally; custom pipelines use the modular API with dependency injection
- Sendable compliance across protocols and implementations; async/await APIs throughout
- Expanded to 66 tests: FCPXML time strings (valid/invalid)
- `FCPXMLError` and public option enums marked `Sendable`; error descriptions verified for all cases

---

### 1.0.2

**🎉 Released:**
- 30th November 2025

**🔧 Improvements:**
- Migrated from TimecodeKit to SwiftTimecode 3.0.0
- Updated package dependency to new repository: `https://github.com/orchetect/swift-timecode`
- Updated all import statements from `import TimecodeKit` to `import SwiftTimecode`
- Updated Timecode initializer API to new SwiftTimecode 3.0 syntax: `Timecode(.realTime(seconds: seconds), at: frameRate)`
- Updated frame rate enum cases to new naming convention: `.fps24`, `.fps25`, `.fps29_97`, `.fps30`, `.fps50`, `.fps59_94`, `.fps60`, `.fps23_976` (replacing `._24`, `._25`, etc.)
- Updated all documentation references from TimecodeKit to SwiftTimecode
- Updated version references from 1.6.13 to 3.0.0
- All 66 tests passing with SwiftTimecode 3.0.0
- Task-based concurrency avoided for Foundation XML types and SwiftTimecode types due to Sendable limitations

---

### 1.0.1

**🎉 Released:**
- 11th July 2025

**🔧 Improvements:**
- Comprehensive async/await support across all major operations
- All protocols, implementations, services, and utilities now have async methods
- Enhanced concurrency safety with proper Sendable compliance
- Updated test suite to 66 comprehensive tests with async/await coverage
- Improved error handling with async error propagation
- Enhanced documentation with async/await usage examples
- All tests passing with new async/await architecture
- Protocol-oriented design with both sync and async/await APIs
- Task-based concurrency avoided for Foundation XML types and TimecodeKit types due to Sendable limitations
- Async APIs provided and concurrency-safe for Swift 6
- Comprehensive modular architecture maintained with enhanced extensibility
- Performance optimizations for async operations
- Thread-safe implementation with proper resource management

---

### 1.0.0

**🎉 Released:**
- 10th July 2025

This is the first public release of **Pipeline Neo**!