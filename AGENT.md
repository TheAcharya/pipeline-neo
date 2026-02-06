# Pipeline Neo - AI Agent Development Guide

Pipeline Neo now provides comprehensive async/await support for all major operations. All protocols, implementations, services, and utilities have async methods. Task-based concurrency is avoided for Foundation XML types and SwiftTimecode types due to Sendable limitations, but async APIs are provided and concurrency-safe for Swift 6. The README and tests now demonstrate async/await usage, and all 66 tests/builds pass with the new architecture.

> **Note:** Foundation XML types (XMLDocument, XMLElement) and SwiftTimecode types are not Sendable. The codebase avoids Task-based concurrency for these types, but provides async/await APIs that are concurrency-safe for Swift 6. If/when these dependencies become Sendable-compliant, further parallelisation and structured concurrency can be introduced.

---

A comprehensive guide for AI agents and contributors working on Pipeline Neo, a fully modular Swift 6 framework for Final Cut Pro FCPXML processing with SwiftTimecode integration.

## Table of Contents

- [Project Overview](#project-overview)
  - [Core Objectives](#core-objectives)
  - [Target Platforms](#target-platforms)
  - [Current Status](#current-status)
- [Architecture](#architecture)
- [Modularity & Extensibility](#modularity--extensibility)
- [Security & Safety](#security--safety)
- [Development Guidelines](#development-guidelines)
  - [Swift Version](#swift-version)
  - [Concurrency Requirements](#concurrency-requirements)
  - [Error Handling](#error-handling)
- [Code Style](#code-style)
  - [Naming Conventions](#naming-conventions)
  - [Documentation](#documentation)
  - [File Organisation](#file-organisation)
- [Testing Strategy](#testing-strategy)
- [Note on Sendable Limitations](#note-on-sendable-limitations)
- [Dependencies](#dependencies)
  - [Primary Dependencies](#primary-dependencies)
  - [Version Requirements](#version-requirements)
- [File Structure](#file-structure)
- [Key Components](#key-components)
  - [FCPXMLService](#fcpxmlservice)
  - [Modular Components](#modular-components)
  - [Modular Extensions](#modular-extensions)
  - [ModularUtilities](#modularutilities)
- [Common Patterns](#common-patterns)
  - [Async Operations](#async-operations)
  - [Error Handling](#error-handling)
  - [Type Safety](#type-safety)
- [Error Handling](#error-handling)
  - [Error Types](#error-types)
  - [Error Propagation](#error-propagation)
  - [Error Recovery](#error-recovery)
- [Performance Considerations](#performance-considerations)
  - [Memory Management](#memory-management)
  - [Concurrency Performance](#concurrency-performance)
  - [XML Processing](#xml-processing)
- [Documentation Standards](#documentation-standards)
  - [Code Documentation](#code-documentation)
  - [README Documentation](#readme-documentation)
  - [Inline Comments](#inline-comments)
- [Git Workflow](#git-workflow)
  - [Branch Strategy](#branch-strategy)
  - [Commit Messages](#commit-messages)
  - [Pull Request Process](#pull-request-process)
- [Release Process](#release-process)
  - [Version Management](#version-management)
  - [Release Checklist](#release-checklist)
  - [Distribution](#distribution)
- [Documentation Sync](#documentation-sync)
- [Additional Resources](#additional-resources)
  - [External References](#external-references)
  - [Internal References](#internal-references)
  - [Development Tools](#development-tools)

## Project Overview

Pipeline Neo is a modern, protocol-oriented Swift 6 framework for FCPXML parsing, creation, and manipulation, with advanced timecode operations via SwiftTimecode. The codebase is 100% modular, with all major operations defined as protocols and implemented via dependency injection for maximum flexibility and testability.

### Core Objectives
- Modern Swift 6 concurrency support with async/await patterns
- Full SwiftTimecode integration for professional timecode operations
- Comprehensive test coverage for all functionality (66 tests)
- Modular architecture for future expansion
- Professional documentation and examples
- Support for FCPXML versions 1.5 through 1.14 (DTD validation and parsing for all; typed element-type coverage for all DTD elements via FCPXMLElementType)

### Target Platforms
- macOS 12.0+
- Xcode 16.0+
- Swift 6.0+

### Current Status
- All 66 tests passing
- FCPXML 1.5–1.14: DTDs included for validation; full parsing; typed element-type coverage for all DTD elements (FCPXMLElementType)
- Final Cut Pro frame rate support (23.976, 24, 25, 29.97, 30, 50, 59.94, 60)
- Thread-safe and concurrency-compliant with comprehensive async/await support
- No known security vulnerabilities
- Comprehensive modular architecture with protocol-oriented design

## Architecture

- Protocols: All core operations (parsing, timecode conversion, XML manipulation, error handling) are defined as protocols (e.g., FCPXMLParsing, TimecodeConversion, XMLDocumentOperations, ErrorHandling), with both synchronous and async/await methods for modern concurrency.
- Implementations: Default implementations are provided, supporting both sync and async/await APIs. Async methods are concurrency-safe and avoid Task-based concurrency for Foundation XML types and SwiftTimecode types due to Sendable limitations.
- Extensions: Modular extensions for CMTime, XMLElement, and XMLDocument allow dependency-injected operations with async/await support.
- Service Layer: FCPXMLService orchestrates all modular components for high-level workflows, with both sync and async/await APIs.
- Utilities: ModularUtilities provides pipeline creation, validation, and error-handling helpers, with comprehensive async/await support.

## Modularity & Extensibility

- All major functionality is protocol-based and dependency-injected, with both sync and async/await APIs.
- Async/await support is comprehensive across protocols, implementations, services, and utilities.
- Task-based concurrency (e.g., Task.detached, withTaskGroup) is avoided for Foundation XML types and SwiftTimecode types due to Sendable limitations, but async APIs are provided and concurrency-safe for Swift 6.
- The codebase is structured for maximum clarity, maintainability, and separation of concerns.

## Security & Safety

- Thread-safe and concurrency-compliant: All code is Sendable or @unchecked Sendable as appropriate, and passes thread sanitizer checks.
- No known vulnerabilities: All dependencies (including SwiftTimecode 3.0.0) are up to date and have no published security advisories as of July 2025.
- No unsafe code patterns: No use of unsafe pointers, dynamic code execution, or C APIs. All concurrency is structured and type-safe.
- Static analysis: The codebase passes thread sanitizer and static analysis checks, with no concurrency or memory safety issues detected.
- Swift 6 strict concurrency: The codebase follows Swift 6 standards and builds with `-strict-concurrency=complete`. CI runs a dedicated job (macOS-swift6-strict-concurrency) that builds and tests with this flag. Public protocols and concrete types are Sendable where possible; @unchecked Sendable is used only for NSObject-based delegates and for types that hold non-Sendable dependencies with documented safe usage.

## Development Guidelines

### Swift Version
- Always use Swift 6.0 features and syntax
- Leverage async/await for asynchronous operations (all major operations now have async/await APIs)
- Use structured concurrency with Task and TaskGroup where types are Sendable; otherwise, provide async APIs that are concurrency-safe for current Swift 6
- Implement proper Sendable compliance where possible; for Foundation XML types and SwiftTimecode types, avoid Task-based concurrency

### Concurrency Requirements
- All public APIs should be async where appropriate (now implemented across the codebase)
- Use @unchecked Sendable for classes that cannot be made final
- Avoid capturing non-Sendable types in concurrent contexts
- Implement proper actor isolation where needed
- Note: Foundation XML types (XMLDocument, XMLElement) and SwiftTimecode types are not Sendable; async/await APIs are provided, but Task-based concurrency is avoided for these types

### Error Handling
- Use Swift's Result type for operations that can fail
- Provide meaningful error messages
- Implement proper error propagation
- Use do-catch blocks for synchronous operations
- Async error handling is supported in all async/await APIs

## Code Style

### Naming Conventions
- Use descriptive, clear names for all identifiers
- Follow Swift API Design Guidelines
- Use camelCase for variables and functions
- Use PascalCase for types and protocols

### Documentation
- Include comprehensive header comments for all public APIs
- Use Swift documentation comments (///)
- Provide usage examples in documentation, including async/await usage
- Document all parameters, return values, and exceptions

### File Organisation
- Group related functionality in extensions
- Keep files focused on single responsibilities
- Use clear file naming conventions
- Organise imports logically

## Testing Strategy

- All tests and builds pass with the new async/await architecture
- The README and tests now demonstrate async/await usage

## Note on Sendable Limitations

Foundation XML types (XMLDocument, XMLElement) and SwiftTimecode types are not Sendable. The codebase avoids Task-based concurrency for these types, but provides async/await APIs that are concurrency-safe for Swift 6. If/when these dependencies become Sendable-compliant, further parallelisation and structured concurrency can be introduced.

## Dependencies

### Primary Dependencies
- SwiftTimecode: Advanced timecode operations and conversions
- SwiftExtensions: [orchetect/swift-extensions](https://github.com/orchetect/swift-extensions) — extensions on String, Collection, Optional, XMLElement, XMLNode, and other standard library types; use where it improves clarity or safety (e.g. safe subscript, string helpers)
- Foundation: Core XML and data handling
- CoreMedia: CMTime operations and conversions

### Version Requirements
- SwiftTimecode: 3.0.0+
- SwiftExtensions: 2.0.0+
- Swift: 6.0+
- Xcode: 16.0+

## File Structure

```
Pipeline Neo source and test directory layout:
Sources/PipelineNeo/
├── Classes/
│   ├── FCPXMLElementType.swift
│   └── FCPXMLUtility.swift
├── Delegates/
│   ├── AttributeParserDelegate.swift
│   └── FCPXMLParserDelegate.swift
├── Errors/
│   └── FCPXMLError.swift
├── Extensions/
│   ├── CMTime+Modular.swift
│   ├── CMTimeExtension.swift
│   ├── XMLDocument+Modular.swift
│   ├── XMLDocumentExtension.swift
│   ├── XMLElement+Modular.swift
│   └── XMLElementExtension.swift
├── Implementations/
│   ├── FCPXMLParser.swift
│   ├── TimecodeConverter.swift
│   ├── XMLDocumentManager.swift
│   └── ErrorHandler.swift
├── Protocols/
│   ├── FCPXMLParsing.swift
│   ├── TimecodeConversion.swift
│   ├── XMLDocumentOperations.swift
│   └── ErrorHandling.swift
├── Services/
│   └── FCPXMLService.swift
├── Utilities/
│   └── ModularUtilities.swift
└── FCPXML DTDs/
    ├── Final_Cut_Pro_XML_DTD_version_1.5.dtd
    ├── Final_Cut_Pro_XML_DTD_version_1.6.dtd
    ├── Final_Cut_Pro_XML_DTD_version_1.7.dtd
    ├── Final_Cut_Pro_XML_DTD_version_1.8.dtd
    ├── Final_Cut_Pro_XML_DTD_version_1.9.dtd
    ├── Final_Cut_Pro_XML_DTD_version_1.10.dtd
    ├── Final_Cut_Pro_XML_DTD_version_1.11.dtd
    ├── Final_Cut_Pro_XML_DTD_version_1.12.dtd
    ├── Final_Cut_Pro_XML_DTD_version_1.13.dtd
    ├── Final_Cut_Pro_XML_DTD_version_1.14.dtd
    └── README.md

Tests/PipelineNeoTests/
├── PipelineNeoTests.swift (66 comprehensive tests with async/await coverage)
└── XCTestManifests.swift
```

## Key Components

### FCPXMLService
Main service class orchestrating all modular components:
- Dependency-injected architecture
- High-level FCPXML operations
- Error handling and validation
- Performance-optimized workflows

### Modular Components
- FCPXMLParser: XML parsing and validation
- TimecodeConverter: Timecode operations with SwiftTimecode
- XMLDocumentManager: Document creation and manipulation
- ErrorHandler: Comprehensive error handling

### Modular Extensions
- CMTime Extensions (CMTimeExtension, CMTime+Modular): Time-related utilities and conversions
- XMLElement Extensions (XMLElementExtension, XMLElement+Modular): Element creation and manipulation
- XMLDocument Extensions (XMLDocumentExtension, XMLDocument+Modular): Document-level operations
- Extension APIs that cannot take parameters (e.g. `element.fcpxDuration`, `document.fcpxAssetResources`) use `FCPXMLUtility.defaultForExtensions` (single injection point; no hidden concrete types). For custom pipelines, use the modular API with `using:` parameter.

### ModularUtilities
Utility functions for:
- Pipeline creation and configuration (createPipeline, createCustomPipeline)
- Document validation (validateDocument sync/async)
- Error handling helpers (processFCPXML, processMultipleFCPXML)
- convertTimecodes (async)

## Common Patterns

### Async Operations
```swift
// Standard async pattern for time conversions (implementation returns Timecode or nil).
public func timecode(from time: CMTime, frameRate: TimecodeFrameRate) async -> Timecode? {
    // Implementation
}

// Task-based concurrent operations: only when element types are Sendable.
await withTaskGroup(of: Void.self) { group in
    for element in elements {
        group.addTask {
            // Process element
        }
    }
}
```

### Error Handling
```swift
// Result-based error handling for sync APIs.
public func parseFCPXML(from url: URL) -> Result<XMLDocument, FCPXMLError> {
    // Implementation with proper error types
}

// Async error handling: propagate FCPXMLError from underlying errors.
do {
    let document = try await loadFCPXML(from: url)
    return document
} catch {
    throw FCPXMLError.parsingFailed(error)
}
```

### Type Safety
```swift
// Strongly typed enums for FCPXML elements; use for element-type APIs.
public enum FCPXMLElementType: String, CaseIterable {
    case clip = "clip"
    case audio = "audio"
    case video = "video"
    // Additional cases
}

// Type-safe timecode operations
public func convertTimecode(_ timecode: Timecode, to frameRate: TimecodeFrameRate) -> Timecode? {
    // Implementation
}
```

## Error Handling

### Error Types
- FCPXMLError (Sendable): Main error type with cases — invalidFormat, parsingFailed(Error), unsupportedVersion, validationFailed(String), timecodeConversionFailed(String), documentOperationFailed(String). See Errors/FCPXMLError.swift.

### Error Propagation
- Use Swift's error handling system
- Provide meaningful error messages
- Include context information
- Implement proper error recovery

### Error Recovery
- Graceful degradation where possible
- Fallback values for non-critical operations
- Proper cleanup on error conditions
- User-friendly error messages

## Performance Considerations

### Memory Management
- Use value types where appropriate
- Implement proper resource cleanup
- Avoid retain cycles in closures
- Use weak references for delegates

### Concurrency Performance
- Use appropriate concurrency levels
- Implement proper task cancellation
- Avoid blocking operations on main thread
- Use structured concurrency for complex operations

### XML Processing
- Stream large documents when possible
- Use efficient XML parsing techniques
- Implement proper memory management for large files
- Cache frequently accessed data

## Documentation Standards

### Code Documentation
- Comprehensive header comments for all public APIs
- Parameter and return value documentation
- Usage examples in comments
- Exception documentation

### README Documentation
- Clear project overview
- Installation instructions
- Usage examples
- API reference links

### Inline Comments
- Explain complex algorithms
- Document business logic
- Clarify non-obvious code
- Reference external specifications

## Git Workflow

### Branch Strategy
- main: Production-ready code
- dev: Development branch
- feature/*: Feature development
- bugfix/*: Bug fixes

### Commit Messages
- Use clear, descriptive commit messages
- Reference issue numbers when applicable
- Separate subject from body with blank line
- Use imperative mood in commit messages

### Pull Request Process
- Create descriptive PR titles
- Include comprehensive descriptions
- Reference related issues
- Ensure all tests pass

## Release Process

### Version Management
- Follow semantic versioning (MAJOR.MINOR.PATCH)
- Update version numbers in Package.swift
- Tag releases in Git
- Update CHANGELOG.md

### Release Checklist
- All tests passing
- Documentation updated
- Version numbers updated
- CHANGELOG updated
- Release notes prepared

### Distribution
- Tag release in Git
- Create GitHub release
- Update documentation
- Announce release

## Documentation Sync

IMPORTANT: Always ensure this AGENT.md file is kept in sync with the `.cursorrules` file. Both files should contain consistent information about:

- Project overview and architecture
- Code style and formatting guidelines
- Development patterns and conventions
- Security and safety requirements
- Modularity and extensibility principles (including FCPXMLUtility.defaultForExtensions and single injection point)
- FCPXML version support (1.5–1.14) and typed element-type coverage (FCPXMLElementType)
- Final Cut Pro frame rate support
- Current test coverage status (66 tests)
- Swift 6 concurrency (Sendable, async/await, CI strict-concurrency job)
- Source layout: Classes, Delegates, Errors, Extensions (including +Modular), Implementations, Protocols, Services, Utilities, FCPXML DTDs

When updating either file, make sure to:
1. Update both files with the same information
2. Maintain consistency in terminology and examples
3. Ensure both files reflect the current state of the codebase
4. Keep the modular architecture, security status, and file structure up to date

This ensures that AI agents working with the project have consistent guidance whether they're using AGENT.md or the Cursor IDE rules.

## Additional Resources

### External References
- [Final Cut Pro XML Documentation](https://fcp.cafe/developers/fcpxml/)
- [SwiftTimecode Documentation](https://github.com/orchetect/swift-timecode)
- [Swift Concurrency Documentation](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/concurrency/)

### Internal References
- Package.swift: Package configuration (Swift 6, strict concurrency noted in comments)
- README.md: User documentation with async/await examples and modularity details
- .cursorrules: Cursor IDE rules; keep in sync with this AGENT.md (same overview, concurrency, modularity, test count, file structure)
- CHANGELOG.md: Version history
- Tests/: Test suite and examples (66 tests with async/await coverage)

### Development Tools
- Xcode 16.0+ for development
- Swift Package Manager for dependency management
- GitHub Actions for CI/CD (includes macOS, macOS Swift 6, and macOS Swift 6 strict-concurrency jobs)
- SwiftLint for code style enforcement (if configured) 