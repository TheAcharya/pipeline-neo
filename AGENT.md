# Pipeline Neo - AI Agent Development Guide

A comprehensive guide for AI agents and contributors working on Pipeline Neo, a fully modular Swift 6 framework for Final Cut Pro FCPXML processing with TimecodeKit integration.

## Table of Contents

- [Project Overview](#project-overview)
- [Architecture](#architecture)
- [Modularity & Extensibility](#modularity--extensibility)
- [Security & Safety](#security--safety)
- [Development Guidelines](#development-guidelines)
- [Code Style](#code-style)
- [Testing Strategy](#testing-strategy)
- [Dependencies](#dependencies)
- [File Structure](#file-structure)
- [Key Components](#key-components)
- [Common Patterns](#common-patterns)
- [Error Handling](#error-handling)
- [Performance Considerations](#performance-considerations)
- [Documentation Standards](#documentation-standards)
- [Git Workflow](#git-workflow)
- [Release Process](#release-process)
- [Documentation Sync](#documentation-sync)

## Project Overview

Pipeline Neo is a modern, protocol-oriented Swift 6 framework for FCPXML parsing, creation, and manipulation, with advanced timecode operations via TimecodeKit. The codebase is 100% modular, with all major operations defined as protocols and implemented via dependency injection for maximum flexibility and testability.

### Core Objectives
- Modern Swift 6 concurrency support with async/await patterns
- Full TimecodeKit integration for professional timecode operations
- Comprehensive test coverage for all functionality (40+ tests)
- Modular architecture for future expansion
- Professional documentation and examples
- Support for FCPXML versions 1.5 through 1.13

### Target Platforms
- macOS 12.0+
- Xcode 16.0+
- Swift 6.0+

### Current Status
- All 40 tests passing
- Full FCPXML version support (1.5-1.13)
- Final Cut Pro frame rate support (23.976, 24, 25, 29.97, 30, 50, 59.94, 60)
- Thread-safe and concurrency-compliant
- No known security vulnerabilities
- Comprehensive modular architecture

## Architecture

- Protocols: All core operations (parsing, timecode conversion, XML manipulation, error handling) are defined as protocols (e.g., FCPXMLParsing, TimecodeConversion, XMLDocumentOperations, ErrorHandling).
- Implementations: Default implementations are provided, but you can inject your own for custom behaviour, testing, or extension.
- Extensions: Modular extensions for CMTime, XMLElement, and XMLDocument allow dependency-injected operations.
- Service Layer: FCPXMLService orchestrates all modular components for high-level workflows.
- Utilities: ModularUtilities provides pipeline creation, validation, and error-handling helpers.

## Modularity & Extensibility

- All major functionality is protocol-based and dependency-injected.
- You can swap out or extend any component (e.g., custom XML parser, timecode converter, error handler) without changing the rest of the system.
- This design enables easy testing, mocking, and future expansion.
- The codebase is structured for maximum clarity, maintainability, and separation of concerns.

## Security & Safety

- Thread-safe and concurrency-compliant: All code is Sendable or @unchecked Sendable as appropriate, and passes thread sanitizer checks.
- No known vulnerabilities: All dependencies (including TimecodeKit 1.6.13) are up to date and have no published security advisories as of July 2025.
- No unsafe code patterns: No use of unsafe pointers, dynamic code execution, or C APIs. All concurrency is structured and type-safe.
- Static analysis: The codebase passes thread sanitizer and static analysis checks, with no concurrency or memory safety issues detected.

## Development Guidelines

### Swift Version
- Always use Swift 6.0 features and syntax
- Leverage async/await for asynchronous operations
- Use structured concurrency with Task and TaskGroup
- Implement proper Sendable compliance

### Concurrency Requirements
- All public APIs should be async where appropriate
- Use @unchecked Sendable for classes that cannot be made final
- Avoid capturing non-Sendable types in concurrent contexts
- Implement proper actor isolation where needed

### Error Handling
- Use Swift's Result type for operations that can fail
- Provide meaningful error messages
- Implement proper error propagation
- Use do-catch blocks for synchronous operations

## Code Style

### Naming Conventions
- Use descriptive, clear names for all identifiers
- Follow Swift API Design Guidelines
- Use camelCase for variables and functions
- Use PascalCase for types and protocols

### Documentation
- Include comprehensive header comments for all public APIs
- Use Swift documentation comments (///)
- Provide usage examples in documentation
- Document all parameters, return values, and exceptions

### File Organisation
- Group related functionality in extensions
- Keep files focused on single responsibilities
- Use clear file naming conventions
- Organise imports logically

## Testing Strategy

### Test Coverage Requirements
- Unit tests for all public APIs
- Integration tests for complex workflows
- Performance tests for time-critical operations
- Concurrency tests for async operations
- Current: 40 comprehensive tests covering all functionality

### Test Organisation
- One test file per main component
- Descriptive test method names
- Comprehensive test data
- Proper setup and teardown

### Test Data
- Use realistic FCPXML samples
- Include edge cases and error conditions
- Test all supported frame rates (Final Cut Pro compatible)
- Validate against actual Final Cut Pro output

### Supported Frame Rates
Only test with Final Cut Pro supported frame rates:
- 23.976 fps
- 24 fps
- 25 fps
- 29.97 fps
- 30 fps
- 50 fps
- 59.94 fps
- 60 fps

## Dependencies

### Primary Dependencies
- TimecodeKit: Advanced timecode operations and conversions
- Foundation: Core XML and data handling
- CoreMedia: CMTime operations and conversions

### Version Requirements
- TimecodeKit: 1.6.0 to 2.0.0
- Swift: 6.0+
- Xcode: 16.0+

## File Structure

```
Sources/PipelineNeo/
├── Classes/
│   ├── FCPXMLElementType.swift
│   └── FCPXMLUtility.swift
├── Delegates/
│   ├── AttributeParserDelegate.swift
│   └── FCPXMLParserDelegate.swift
├── Extensions/
│   ├── CMTimeExtension.swift
│   ├── XMLDocumentExtension.swift
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
    └── README.md

Tests/PipelineNeoTests/
├── PipelineNeoTests.swift (40 comprehensive tests)
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
- TimecodeConverter: Timecode operations with TimecodeKit
- XMLDocumentManager: Document creation and manipulation
- ErrorHandler: Comprehensive error handling

### Modular Extensions
- CMTime Extensions: Time-related utilities and conversions
- XMLElement Extensions: Element creation and manipulation
- XMLDocument Extensions: Document-level operations

### ModularUtilities
Utility functions for:
- Pipeline creation and configuration
- Document validation
- Error handling helpers
- Performance monitoring

## Common Patterns

### Async Operations
```swift
// Standard async pattern for time conversions
public func timecode(from time: CMTime, frameRate: TimecodeFrameRate) async -> Timecode? {
    // Implementation
}

// Task-based concurrent operations
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
// Result-based error handling
public func parseFCPXML(from url: URL) -> Result<XMLDocument, FCPXMLError> {
    // Implementation with proper error types
}

// Async error handling
do {
    let document = try await loadFCPXML(from: url)
    return document
} catch {
    throw FCPXMLError.parsingFailed(error)
}
```

### Type Safety
```swift
// Strongly typed enums for FCPXML elements
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
- FCPXMLError: Main error type for FCPXML operations
- TimecodeError: Timecode conversion errors
- ValidationError: Document validation errors
- ParsingError: XML parsing errors

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
- Modularity and extensibility principles
- FCPXML version support (1.5-1.13)
- Final Cut Pro frame rate support
- Current test coverage status

When updating either file, make sure to:
1. Update both files with the same information
2. Maintain consistency in terminology and examples
3. Ensure both files reflect the current state of the codebase
4. Keep the modular architecture and security status up to date

This ensures that AI agents working with the project have consistent guidance whether they're using AGENT.md or the Cursor IDE rules.

## Additional Resources

### External References
- [Final Cut Pro XML Documentation](https://fcp.cafe/developers/fcpxml/)
- [TimecodeKit Documentation](https://github.com/orchetect/TimecodeKit)
- [Swift Concurrency Documentation](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/concurrency/)

### Internal References
- Package.swift: Package configuration
- README.md: User documentation
- CHANGELOG.md: Version history
- Tests/: Test suite and examples (40 tests)

### Development Tools
- Xcode 16.0+ for development
- Swift Package Manager for dependency management
- GitHub Actions for CI/CD
- SwiftLint for code style enforcement (if configured) 