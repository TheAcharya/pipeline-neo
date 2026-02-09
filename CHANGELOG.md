# Changelog

### 2.0.0

**🎉 Released:**
- TBA

**🔧 Improvements:**
- Complete codebase rewrite and refactor; protocol-oriented design and consistent source layout
- Expanded test suite to 170 tests
- Cut detection: find edit points on a project spine (hard cut, transition, gap) and whether each cut is same-clip or different-clips; sync and async
- Version conversion: convert a document to another FCPXML version (e.g. 1.14 → 1.10); save as single .fcpxml file or .fcpxmld bundle (bundle requires version 1.10 or higher)
- Media extraction and copy: extract media file references from the document; copy those files to a folder (deduplicated, unique names); sync and async
- Documentation updated across AGENT.md, .cursorrules, Manual, README, and test docs

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