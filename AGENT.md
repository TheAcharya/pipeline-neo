# Pipeline Neo - AI Agent Development Guide

A comprehensive guide for AI agents working on the Pipeline Neo project - a modern Swift 6 framework for Final Cut Pro FCPXML processing with TimecodeKit integration.

## Table of Contents

- [Project Overview](#project-overview)
- [Architecture](#architecture)
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

## Project Overview

Pipeline Neo is a modernised fork of the original Pipeline library, targeting Swift 6.0 and macOS 12+. The project provides comprehensive FCPXML parsing, creation, and manipulation capabilities with advanced timecode operations through TimecodeKit integration.

### Core Objectives
- Modern Swift 6 concurrency support with async/await patterns
- Full TimecodeKit integration for professional timecode operations
- Comprehensive test coverage for all functionality
- Modular architecture for future expansion
- Professional documentation and examples

### Target Platforms
- macOS 12.0+
- Xcode 16.0+
- Swift 6.0+

## Architecture

The project follows a modular, protocol-oriented design with clear separation of concerns:

### Core Components
- **FCPXMLUtility**: Main utility class for FCPXML operations
- **XMLDocument Extensions**: FCPXML-specific document handling
- **XMLElement Extensions**: FCPXML element creation and manipulation
- **CMTime Extensions**: Time-related utilities and conversions
- **Delegates**: XML parsing and attribute handling
- **DTD Resources**: Final Cut Pro XML schema definitions

### Design Principles
- Protocol-oriented programming
- Swift 6 concurrency compliance
- Type-safe operations
- Comprehensive error handling
- Modular and extensible architecture

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

### Test Organisation
- One test file per main component
- Descriptive test method names
- Comprehensive test data
- Proper setup and teardown

### Test Data
- Use realistic FCPXML samples
- Include edge cases and error conditions
- Test all supported frame rates
- Validate against actual Final Cut Pro output

## Dependencies

### Primary Dependencies
- **TimecodeKit**: Advanced timecode operations and conversions
- **Foundation**: Core XML and data handling
- **CoreMedia**: CMTime operations and conversions

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
├── PipelineNeoTests.swift
└── XCTestManifests.swift
```

## Key Components

### FCPXMLUtility
Main utility class providing FCPXML operations:
- Time conversions between CMTime and TimecodeKit
- FCPXML time string parsing and generation
- Line break conversion for XML attributes
- Element filtering and manipulation

### XMLDocument Extensions
Extensions for FCPXML-specific document operations:
- FCPXML initialisation and parsing
- Event and resource management
- Document validation and output
- Version-specific handling

### XMLElement Extensions
Extensions for FCPXML element creation:
- Event, project, and clip creation
- Resource and format handling
- Compound clip and multicam support
- Audio and video element management

### CMTime Extensions
Time-related utilities and conversions:
- FCPXML time string formatting
- Timecode conversion utilities
- Frame duration calculations
- Time validation and normalisation

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
- **FCPXMLError**: Main error type for FCPXML operations
- **TimecodeError**: Timecode conversion errors
- **ValidationError**: Document validation errors
- **ParsingError**: XML parsing errors

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

## Additional Resources

### External References
- [Final Cut Pro XML Documentation](https://fcp.cafe/developers/fcpxml/)
- [TimecodeKit Documentation](https://github.com/orchetect/TimecodeKit)
- [Swift Concurrency Documentation](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/concurrency/)

### Internal References
- Package.swift: Package configuration
- README.md: User documentation
- CHANGELOG.md: Version history
- Tests/: Test suite and examples

### Development Tools
- Xcode 16.0+ for development
- Swift Package Manager for dependency management
- GitHub Actions for CI/CD
- SwiftLint for code style enforcement (if configured) 