# Changelog

### 1.1.0

**Released:**
- 6th February 2026

**🔧 Improvements:**
- Integrated **SwiftExtensions** (orchetect/swift-extensions 2.0.0+): XML access now uses `firstChildElement(named:)`, `stringValue(forAttributeNamed:)`, `childElements`, and safe collection subscript `[safe:]` across `XMLDocumentExtension`, `XMLElementExtension`, `FCPXMLParser`, `XMLDocumentManager`, and `TimecodeConverter`; removed redundant custom `parentElement` in favour of SwiftExtensions’ `XMLNode.parentElement`; replaced `elements(forName: "…")[0]` and `attribute(forName:)?.stringValue` patterns for clearer, safer code
- Added DTD and version support for 1.14; documentation, tests, and CI now cover 1.5 through 1.14
- Full DTD element-type coverage via `FCPXMLElementType`: tag names, inferred types (e.g. media by first child), and filtering by type across the parser and utility
- Single injection point for extension APIs via `FCPXMLUtility.defaultForExtensions`; extensions no longer instantiate concrete types internally; custom pipelines use the modular API with dependency injection
- Sendable compliance across protocols and implementations; async/await APIs throughout; new CI job runs build and tests with `-strict-concurrency=complete`; added concurrency test using `TaskGroup` with Sendable service
- Expanded to 66 tests: FCPXML time strings (valid/invalid), all supported frame rates, document versions, element filtering (core and extended types, multicam/compound), XMLDocument/XMLElement extension APIs (events, resources, validation, duration, event clips), `FCPXMLError` and `ModularUtilities` coverage, performance and edge cases; TOC and section header comments added to the test file
- `FCPXMLError` and public option enums marked `Sendable`; error descriptions verified for all cases
- AGENT.md and .cursorrules aligned with codebase (file structure including Errors and +Modular extensions, test count, concurrency notes); code blocks in README, AGENT, .cursorrules, and Tests/README commented for clarity

---

### 1.0.2

**Released:**
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

**Released:**
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