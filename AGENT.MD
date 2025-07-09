# Pipeline Neo - AI Agent Documentation

> **IMPORTANT**: This file must be kept synchronized with `.cursorrules`. Any changes to project requirements, coding standards, or development guidelines must be updated in both files to maintain consistency across AI assistance tools.

## Table of Contents

1. [Project Overview](#project-overview)
2. [Architecture](#architecture)
3. [Core Components](#core-components)
4. [TimecodeKit Integration](#timecodekit-integration)
5. [Development Guidelines](#development-guidelines)
6. [Testing Strategy](#testing-strategy)
7. [Build and Deployment](#build-and-deployment)
8. [Common Tasks](#common-tasks)
9. [Troubleshooting](#troubleshooting)
10. [Contributing](#contributing)

## Project Overview

Pipeline Neo is a modern Swift library for working with Final Cut Pro's FCPXML format. It provides comprehensive tools for parsing, manipulating, and generating FCPXML documents with full TimecodeKit integration for accurate timecode handling.

### Key Features

- FCPXML parsing and generation
- TimecodeKit integration for precise timecode operations
- Support for FCPXML versions 1.5 through 1.13
- Modern Swift 6 compatibility
- Comprehensive error handling
- Extensive test coverage

### Technology Stack

- Swift 6
- TimecodeKit for timecode operations
- CoreMedia for CMTime integration
- XMLDocument for FCPXML parsing
- Swift Package Manager for dependency management

## Architecture

### Directory Structure

```
pipeline-neo/
├── Sources/
│   └── PipelineNeo/
│       ├── Classes/
│       │   ├── FCPXMLElementType.swift
│       │   ├── FCPXMLError.swift
│       │   └── FCPXMLUtility.swift
│       ├── Delegates/
│       │   ├── AttributeParserDelegate.swift
│       │   └── FCPXMLParserDelegate.swift
│       ├── Extensions/
│       │   ├── CMTimeExtension.swift
│       │   ├── XMLDocumentExtension.swift
│       │   └── XMLElementExtension.swift
│       └── FCPXML DTDs/
│           └── [DTD files for versions 1.5-1.13]
├── Tests/
│   └── PipelineNeoTests/
│       ├── PipelineNeoTests.swift
│       ├── FCPXMLDTDTests.swift
│       └── XCTestManifests.swift
├── Package.swift
└── README.md
```

### Design Principles

- Modular architecture with clear separation of concerns
- TimecodeKit as the canonical source for timecode operations
- Comprehensive error handling with custom error types
- Swift 6 modern features and best practices
- Extensive test coverage for all functionality

## Core Components

### FCPXMLElementType

Defines all supported FCPXML element types as an enumeration. Used for filtering and type checking throughout the library.

### FCPXMLError

Comprehensive error handling system with custom error types for different failure scenarios:

- File operations (read/write errors)
- Validation errors
- Time format errors
- Missing elements or attributes
- Unsupported FCPXML versions

### FCPXMLUtility

Utility class providing common operations:

- Element filtering by type
- Time conversion between CMTime and FCPXML formats
- Timecode operations using TimecodeKit
- Frame rate detection and conversion

### Extensions

#### CMTimeExtension

Provides convenience methods for CMTime operations:

- FCPXML string formatting
- Timecode conversion using TimecodeKit
- Counter display formatting
- Frame rounding operations

#### XMLDocumentExtension

Extends XMLDocument with FCPXML-specific functionality:

- Version management and comparison
- DTD validation
- Resource and event management
- FCPXML structure creation

#### XMLElementExtension

Extends XMLElement with FCPXML element operations:

- Element creation methods
- Attribute management
- Timecode format handling
- Element type detection

## TimecodeKit Integration

Pipeline Neo uses TimecodeKit as the foundation for all timecode operations, ensuring accuracy and consistency.

### Key Integration Points

- Timecode conversion using TimecodeKit's Timecode type
- Frame rate detection using TimecodeFrameRate
- Drop frame vs non-drop frame handling
- Precise timecode calculations

### Usage Examples

```swift
// Convert CMTime to timecode using TimecodeKit
let time = CMTime(value: 60, timescale: 30)
let timecode = time.timeAsTimecode(usingFrameDuration: frameDuration, dropFrame: false)

// Create timecode from components
let tc = FCPXMLUtility.cmTimeFrom(
    timecodeHours: 1,
    timecodeMinutes: 30,
    timecodeSeconds: 15,
    timecodeFrames: 10,
    frameDuration: frameDuration
)
```

## Development Guidelines

### Code Style

- Follow Swift 6 best practices
- Use descriptive variable and function names
- Include comprehensive documentation comments
- Maintain consistent indentation and formatting

### File Headers

All Swift files use the standardized header format:

```swift
//
//  Filename.swift
//  Pipeline Neo • https://github.com/TheAcharya/pipeline-neo
//  © 2025 • Licensed under MIT License
//
```

### Error Handling

- Use custom FCPXMLError types for specific error scenarios
- Provide meaningful error messages
- Include recovery suggestions where possible
- Use Swift's Result type for operations that can fail

### Performance Considerations

- Avoid repeated XML parsing operations
- Cache frequently accessed properties
- Use efficient data structures for large documents
- Profile performance-critical operations

## Testing Strategy

### Test Structure

- Unit tests for all public APIs
- Integration tests for FCPXML operations
- Performance tests for critical operations
- Error handling tests for all error scenarios

### Test Categories

#### Core Functionality Tests

- CMTime operations and conversions
- FCPXML parsing and generation
- TimecodeKit integration
- Error handling scenarios

#### DTD Tests

- Version comparison logic
- DTD file availability
- Version extraction and validation

#### Utility Tests

- Element filtering
- Time conversion utilities
- Frame rate operations

### Running Tests

```bash
# Run all tests
swift test

# Run specific test
swift test --filter TestName.testMethod

# Run tests with verbose output
swift test --verbose
```

## Build and Deployment

### Building the Project

```bash
# Build for debugging
swift build

# Build for release
swift build -c release

# Build with specific target
swift build --target PipelineNeo
```

### Package Management

The project uses Swift Package Manager with the following dependencies:

- TimecodeKit: For timecode operations
- CoreMedia: For CMTime integration

### Version Management

- Semantic versioning for releases
- FCPXML version support tracking
- TimecodeKit version compatibility

## Common Tasks

### Adding New FCPXML Element Types

1. Add the new type to FCPXMLElementType enum
2. Update filtering logic in FCPXMLUtility
3. Add corresponding tests
4. Update documentation

### Implementing New Timecode Operations

1. Use TimecodeKit APIs for accuracy
2. Add convenience methods to CMTimeExtension
3. Include comprehensive tests
4. Update FCPXMLUtility if needed

### Adding FCPXML Version Support

1. Add DTD file to FCPXML DTDs directory
2. Update version comparison logic
3. Add tests for new version
4. Update documentation

### Error Handling Improvements

1. Define new error types in FCPXMLError
2. Implement error recovery strategies
3. Add tests for error scenarios
4. Update error documentation

## Troubleshooting

### Common Issues

#### Build Failures

- Ensure Swift 6 compatibility
- Check TimecodeKit dependency
- Verify all imports are correct
- Clean build folder if needed

#### Test Failures

- Check TimecodeKit version compatibility
- Verify test data is correct
- Ensure proper FCPXML structure in tests
- Check for timing-related issues

#### Performance Issues

- Profile with Instruments
- Check for repeated XML parsing
- Optimize data structure usage
- Consider caching strategies

### Debugging Tips

- Use debug logging for complex operations
- Add print statements for version comparisons
- Check XML structure validity
- Verify timecode calculations manually

## Contributing

### Development Workflow

1. Create feature branch from main
2. Implement changes with tests
3. Ensure all tests pass
4. Update documentation
5. Submit pull request

### Code Review Checklist

- All tests passing
- Documentation updated
- Error handling implemented
- Performance considered
- Swift 6 compatibility maintained

### Release Process

1. Update version in Package.swift
2. Update CHANGELOG.md
3. Create release tag
4. Deploy to package registry
5. Update documentation

### Maintenance Tasks

- Regular dependency updates
- Swift version compatibility checks
- Performance monitoring
- Security vulnerability scanning
- Documentation updates

---

This documentation provides comprehensive guidance for working with Pipeline Neo. For specific questions or issues, refer to the test suite or create an issue in the project repository. 