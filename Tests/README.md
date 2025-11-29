# Pipeline Neo - Testing Documentation

This directory contains the comprehensive test suite for Pipeline Neo, ensuring reliability, performance, and correctness across all supported FCPXML operations and timecode conversions.

## Test Structure

```
Tests/
├── README.md                           # This file
└── PipelineNeoTests/
    ├── PipelineNeoTests.swift          # Main test suite
    └── XCTestManifests.swift           # Linux test support
```

## Test Categories

### Core Functionality Tests
- FCPXML Utility Tests - Core utility functions and conversions
- XMLDocument Extension Tests - FCPXML document operations
- XMLElement Extension Tests - FCPXML element creation and manipulation
- CMTime Extension Tests - Time-related utilities and conversions

### SwiftTimecode Integration Tests
- SwiftTimecode Integration - CMTime ↔ SwiftTimecode conversions
- All FCPXML Supported Frame Rates - Comprehensive frame rate testing
- Timecode Operations - Advanced timecode manipulations

### Performance Tests
- FCPXML Parsing Performance - Document parsing efficiency
- Time Conversion Performance - Timecode conversion speed

### Error Handling Tests
- Invalid Input Handling - Graceful error recovery
- Empty Document Handling - Edge case management

### Concurrency Tests
- Concurrent FCPXML Utility Access - Thread safety verification
- Concurrent Document Access - Multi-threaded operations

## Test Coverage

### Supported Frame Rates
Pipeline Neo tests all Final Cut Pro supported frame rates:
- 23.976 fps (23.98)
- 24 fps
- 25 fps
- 29.97 fps
- 29.97 fps drop frame
- 30 fps
- 30 fps drop frame
- 47.952 fps (47.95)
- 48 fps
- 50 fps
- 59.94 fps
- 59.94 fps drop frame
- 60 fps
- 60 fps drop frame
- 100 fps
- 119.88 fps
- 119.88 fps drop frame
- 120 fps
- 120 fps drop frame

### FCPXML Versions
- FCPXML v1.5 through v1.13 support
- DTD validation testing
- Version-specific feature testing

## Running Tests

### Swift Package Manager
```bash
# Run all tests
swift test

# Run tests with verbose output
swift test --verbose

# Run specific test
swift test --filter testTimecodeKitIntegration
```

### Xcode
1. Open the project in Xcode
2. Select the test target
3. Press Cmd+U to run tests
4. View results in the Test Navigator

### Linux Support
Tests include Linux compatibility through `XCTestManifests.swift`, ensuring cross-platform functionality.

## Test Data

### Sample FCPXML Documents
- Empty FCPXML documents for basic functionality testing
- Minimal valid FCPXML structures
- Edge cases and error conditions

### Timecode Test Data
- Various frame rates and time values
- Drop frame and non-drop frame timecode
- Boundary conditions and edge cases

## Performance Benchmarks

### Current Performance Targets
- FCPXML Parsing: < 1ms for basic documents
- Time Conversion: < 1ms for 1000 conversions
- Memory Usage: Efficient memory management for large documents

### Performance Monitoring
- Continuous performance tracking
- Regression detection
- Baseline establishment for future comparisons

## Test Guidelines

### Writing New Tests
1. Descriptive Names - Use clear, descriptive test method names
2. Single Responsibility - Each test should verify one specific aspect
3. Comprehensive Coverage - Test both success and failure scenarios
4. Edge Cases - Include boundary conditions and error cases
5. Performance - Add performance tests for time-critical operations

### Test Organisation
```swift
// MARK: - Test Category Name

func testSpecificFunctionality() throws {
    // Arrange - Set up test data
    let utility = FCPXMLUtility()
    
    // Act - Perform the operation
    let result = utility.someOperation()
    
    // Assert - Verify the result
    XCTAssertNotNil(result)
    XCTAssertEqual(result.expectedValue, actualValue)
}
```

### Async Testing
```swift
func testAsyncOperation() async throws {
    let utility = FCPXMLUtility()
    let result = await utility.asyncOperation()
    XCTAssertNotNil(result)
}
```

### Performance Testing
```swift
func testPerformance() throws {
    measure {
        // Code to measure
        for _ in 0..<1000 {
            // Operation to benchmark
        }
    }
}
```

## Continuous Integration

### GitHub Actions
- Automated testing on every push and pull request
- macOS testing with latest Xcode
- Swift 6.0 compatibility verification
- Performance regression detection

### Test Requirements
- All tests must pass before merging
- Performance tests must meet baseline requirements
- Code coverage should be maintained or improved

## Debugging Tests

### Common Issues
1. Concurrency Warnings - Ensure proper async/await usage
2. Memory Leaks - Use proper cleanup in test teardown
3. Timing Issues - Use appropriate timeouts for async operations

### Debug Techniques
```swift
// Add debug output
print("Debug: \(someValue)")

// Use conditional compilation
#if DEBUG
print("Debug information")
#endif

// Break on specific conditions
if someCondition {
    print("Breakpoint condition met")
}
```

## Contributing to Tests

### Adding New Tests
1. Follow existing naming conventions
2. Add tests to appropriate test categories
3. Include both positive and negative test cases
4. Update this README if adding new test categories

### Test Data Management
- Keep test data minimal and focused
- Use realistic but simple FCPXML examples
- Document any special test data requirements

### Performance Considerations
- Keep individual tests fast (< 100ms)
- Use appropriate test data sizes
- Avoid unnecessary setup/teardown overhead

## Future Testing Plans

### Planned Enhancements
- Integration Tests - End-to-end workflow testing
- Stress Tests - Large document processing
- Memory Tests - Memory usage validation
- API Compatibility Tests - Backward compatibility verification

### Test Infrastructure
- Test Data Generation - Automated test data creation
- Performance Baselines - Automated performance regression detection
- Coverage Reporting - Detailed code coverage analysis

## Resources

### Documentation
- [XCTest Framework Documentation](https://developer.apple.com/documentation/xctest)
- [Swift Testing Best Practices](https://developer.apple.com/documentation/xcode/testing-your-apps-in-xcode)
- [Pipeline Neo API Documentation](../README.md)

### External References
- [Final Cut Pro XML Documentation](https://fcp.cafe/developers/fcpxml/)
- [SwiftTimecode Documentation](https://github.com/orchetect/swift-timecode)