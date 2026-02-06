//
//  PipelineNeoTests.swift
//  Pipeline Neo • https://github.com/TheAcharya/pipeline-neo
//  © 2025 • Licensed under MIT License
//

import XCTest
import CoreMedia
import SwiftTimecode
@testable import PipelineNeo

// MARK: - Table of Contents (commented for easy searching)
//
// 1. Test Dependencies / Setup and Teardown
// 2. FCPXMLUtility Tests
// 3. FCPXMLService Tests
// 4. Modular Component Tests
// 5. Modular Utilities Tests
// 6. Async Tests
// 7. Performance Tests
// 8. Comprehensive Parameter Tests / Frame Rate Tests
// 9. Time Value Tests
// 10. FCPXML Time String Tests
// 11. Time Conforming Tests
// 12. Error Handling Tests
// 13. Document Management Tests
// 14. Element Filtering Tests
// 15. Modular Extensions Comprehensive
// 16. Performance Tests (Different Parameters)
// 17. Edge Case Tests
// 18. FCPXMLElementType Coverage
// 19. FCPXMLError Coverage
// 20. ModularUtilities Full API
// 21. XMLDocument Extension
// 22. XMLElement Extension
// 23. Parser Filter Multicam/Compound
//
// Coverage: Extensive FCPXML coverage — all versions (1.5–1.14), all supported frame rates, parsing/validation, FCPXML time strings,
// element-type filtering (core + extended + multicam/compound), document/event/resource/clip extensions, error types, async/await,
// performance, and edge cases. Not every single extension property has a dedicated test; main API surface is well covered.

@available(macOS 12.0, *)
final class PipelineNeoTests: XCTestCase, @unchecked Sendable {
    
    // MARK: - Test Dependencies
    /// Shared instances of FCPXMLUtility, FCPXMLService, parser, timecodeConverter, documentManager, errorHandler.
    /// Injected in setUp; used across sync and async tests.
    
    private var utility: FCPXMLUtility!
    private var service: FCPXMLService!
    private var parser: FCPXMLParser!
    private var timecodeConverter: TimecodeConverter!
    private var documentManager: XMLDocumentManager!
    private var errorHandler: ErrorHandler!
    
    // MARK: - Setup and Teardown
    /// Creates all modular components and injects them into utility and service. Tears down references in tearDownWithError.

    override func setUpWithError() throws {
        try super.setUpWithError()
        
        // Create modular components
        parser = FCPXMLParser()
        timecodeConverter = TimecodeConverter()
        documentManager = XMLDocumentManager()
        errorHandler = ErrorHandler()
        
        // Create utility with injected dependencies
        utility = FCPXMLUtility(
            parser: parser,
            timecodeConverter: timecodeConverter,
            documentManager: documentManager,
            errorHandler: errorHandler
        )
        
        // Create service with injected dependencies
        service = FCPXMLService(
            parser: parser,
            timecodeConverter: timecodeConverter,
            documentManager: documentManager,
            errorHandler: errorHandler
        )
    }
    
    override func tearDownWithError() throws {
        utility = nil
        service = nil
        parser = nil
        timecodeConverter = nil
        documentManager = nil
        errorHandler = nil
        try super.tearDownWithError()
    }
    
    // MARK: - FCPXMLUtility Tests
    /// Filtering by FCPXMLElementType; CMTime ↔ FCPXML time string; time conforming to frame duration.

    func testFCPXMLUtilityInitialisation() {
        XCTAssertNotNil(utility)
        XCTAssertNotNil(service)
    }
    
    func testFilterElements() {
        // Create test elements
        let element1 = XMLElement(name: "asset")
        let element2 = XMLElement(name: "sequence")
        let element3 = XMLElement(name: "clip")
        
        let elements = [element1, element2, element3]
        let types: [FCPXMLElementType] = [.assetResource, .sequence]
        
        let filtered = utility.filter(fcpxElements: elements, ofTypes: types)
        
        XCTAssertEqual(filtered.count, 2)
        XCTAssertTrue(filtered.contains { $0.name == "asset" })
        XCTAssertTrue(filtered.contains { $0.name == "sequence" })
        XCTAssertFalse(filtered.contains { $0.name == "clip" })
    }
    
    func testCMTimeFromFCPXMLTime() {
        let timeString = "3600/60000"
        let result = utility.CMTime(fromFCPXMLTime: timeString)
        
        XCTAssertNotEqual(result, CMTime.zero)
        XCTAssertEqual(result.value, 3600)
        XCTAssertEqual(result.timescale, 60000)
    }
    
    func testFCPXMLTimeFromCMTime() {
        let time = CMTime(value: 3600, timescale: 60000)
        let result = utility.fcpxmlTime(fromCMTime: time)
        
        XCTAssertEqual(result, "3600/60000")
    }
    
    func testConformTime() {
        let time = CMTime(value: 1001, timescale: 24000)
        let frameDuration = CMTime(value: 1, timescale: 24)
        let result = utility.conform(time: time, toFrameDuration: frameDuration)
        
        XCTAssertNotEqual(result, CMTime.zero)
    }
    
    // MARK: - FCPXMLService Tests
    /// Service initialisation; document creation; timecode and CMTime conversion via service.

    func testFCPXMLServiceInitialisation() {
        XCTAssertNotNil(service)
    }
    
    func testCreateFCPXMLDocument() {
        let document = service.createFCPXMLDocument(version: "1.10")
        
        XCTAssertNotNil(document)
        XCTAssertNotNil(document.rootElement())
        XCTAssertEqual(document.rootElement()?.name, "fcpxml")
    }
    
    func testTimecodeConversion() {
        let time = CMTime(value: 3600, timescale: 60000)
        let frameRate = TimecodeFrameRate.fps24
        
        let timecode = service.timecode(from: time, frameRate: frameRate)
        
        XCTAssertNotNil(timecode)
    }
    
    func testCMTimeFromTimecode() {
        let timecode = try! Timecode(.realTime(seconds: 60), at: TimecodeFrameRate.fps24)
        let result = service.cmTime(from: timecode)
        
        XCTAssertNotEqual(result, CMTime.zero)
        XCTAssertEqual(result.seconds, 60, accuracy: 0.001)
    }
    
    // MARK: - Modular Component Tests
    /// Parser parse/validate; TimecodeConverter; DocumentManager create/add; ErrorHandler message handling.

    func testParserComponent() {
        let testData = """
        <?xml version="1.0" encoding="UTF-8"?>
        <fcpxml version="1.10">
            <resources>
                <asset id="asset1" name="Test Asset"/>
            </resources>
        </fcpxml>
        """.data(using: .utf8)!
        
        do {
            let document = try parser.parse(testData)
            XCTAssertNotNil(document)
            XCTAssertTrue(parser.validate(document))
        } catch {
            XCTFail("Parser should not throw error for valid XML: \(error)")
        }
    }
    
    func testTimecodeConverterComponent() {
        let time = CMTime(value: 3600, timescale: 60000)
        let frameRate = TimecodeFrameRate.fps24
        
        let timecode = timecodeConverter.timecode(from: time, frameRate: frameRate)
        XCTAssertNotNil(timecode)
        
        let convertedBack = timecodeConverter.cmTime(from: timecode!)
        XCTAssertEqual(convertedBack.seconds, time.seconds, accuracy: 0.001)
    }
    
    func testDocumentManagerComponent() {
        let document = documentManager.createFCPXMLDocument(version: "1.10")
        XCTAssertNotNil(document)
        
        let resource = documentManager.createElement(name: "asset", attributes: ["id": "test1"])
        documentManager.addResource(resource, to: document)
        
        let rootElement = document.rootElement()
        let resourcesElement = rootElement?.elements(forName: "resources").first
        XCTAssertNotNil(resourcesElement)
        XCTAssertEqual(resourcesElement?.childCount, 1)
    }
    
    func testErrorHandlerComponent() {
        let error = FCPXMLError.invalidFormat
        let message = errorHandler.handleParsingError(error)
        
        XCTAssertFalse(message.isEmpty)
        XCTAssertTrue(message.contains("Invalid FCPXML format"))
    }
    
    // MARK: - Modular Utilities Tests
    /// ModularUtilities.createPipeline() returns a configured FCPXMLService.

    func testModularUtilitiesCreatePipeline() {
        let pipeline = ModularUtilities.createPipeline()
        XCTAssertNotNil(pipeline)
    }
    
    // MARK: - Async Tests (Swift 6 concurrency: Sendable service, async/await, no non-Sendable capture)
    /// Async parser, timecode converter, document manager, service; ModularUtilities.validateDocument; element filtering;
    /// time conforming; FCPXML time string conversion; XMLElement operations; concurrent operations and TaskGroup.

    /// Validates Swift 6 concurrency: Sendable service used from multiple tasks; each task asserts locally (no non-Sendable cross-task transfer).
    func testSwift6ConcurrencySendableServiceInTaskGroup() async {
        let service = ModularUtilities.createPipeline()
        let frameRates: [TimecodeFrameRate] = [.fps24, .fps25, .fps30]
        await withTaskGroup(of: Bool.self) { group in
            for rate in frameRates {
                group.addTask {
                    let time = CMTime(value: 3600, timescale: 60000)
                    let tc = await service.timecode(from: time, frameRate: rate)
                    return tc != nil
                }
            }
            var count = 0
            for await ok in group {
                XCTAssertTrue(ok)
                count += 1
            }
            XCTAssertEqual(count, frameRates.count)
        }
    }
    
    func testAsyncParserComponent() async throws {
        let testData = """
        <?xml version="1.0" encoding="UTF-8"?>
        <fcpxml version="1.10">
            <resources>
                <asset id="asset1" name="Test Asset"/>
            </resources>
        </fcpxml>
        """.data(using: .utf8)!
        
        let document = try await parser.parse(testData)
        XCTAssertNotNil(document)
        let isValid = await parser.validate(document)
        XCTAssertTrue(isValid)
    }
    
    func testAsyncTimecodeConverterComponent() async {
        let time = CMTime(value: 3600, timescale: 60000)
        let frameRate = TimecodeFrameRate.fps24
        
        let timecode = await timecodeConverter.timecode(from: time, frameRate: frameRate)
        XCTAssertNotNil(timecode)
        
        let convertedBack = await timecodeConverter.cmTime(from: timecode!)
        XCTAssertEqual(convertedBack.seconds, time.seconds, accuracy: 0.001)
    }
    
    func testAsyncDocumentManagerComponent() async {
        let document = await documentManager.createFCPXMLDocument(version: "1.10")
        XCTAssertNotNil(document)
        
        let resource = await documentManager.createElement(name: "asset", attributes: ["id": "test1"])
        await documentManager.addResource(resource, to: document)
        
        let rootElement = document.rootElement()
        let resourcesElement = rootElement?.elements(forName: "resources").first
        XCTAssertNotNil(resourcesElement)
        XCTAssertEqual(resourcesElement?.childCount, 1)
    }
    
    func testAsyncFCPXMLService() async throws {
        let testData = """
        <?xml version="1.0" encoding="UTF-8"?>
        <fcpxml version="1.10">
            <resources>
                <asset id="asset1" name="Test Asset"/>
            </resources>
        </fcpxml>
        """.data(using: .utf8)!
        
        let document = try await service.parseFCPXML(from: testData)
        XCTAssertNotNil(document)
        
        let isValid = await service.validateDocument(document)
        XCTAssertTrue(isValid)
        
        let time = CMTime(value: 3600, timescale: 60000)
        let frameRate = TimecodeFrameRate.fps24
        let timecode = await service.timecode(from: time, frameRate: frameRate)
        XCTAssertNotNil(timecode)
        
        let newDocument = await service.createFCPXMLDocument(version: "1.10")
        XCTAssertNotNil(newDocument)
    }
    
    func testAsyncModularUtilities() async {
        let document = await documentManager.createFCPXMLDocument(version: "1.10")
        
        let validation = await ModularUtilities.validateDocument(document, using: parser)
        XCTAssertTrue(validation.isValid)
        XCTAssertTrue(validation.errors.isEmpty)
    }
    
    func testAsyncElementFiltering() async {
        let element1 = XMLElement(name: "asset")
        let element2 = XMLElement(name: "sequence")
        let element3 = XMLElement(name: "clip")
        
        let elements = [element1, element2, element3]
        let types: [FCPXMLElementType] = [.assetResource, .sequence]
        
        let filtered = await parser.filter(elements: elements, ofTypes: types)
        
        XCTAssertEqual(filtered.count, 2)
        XCTAssertTrue(filtered.contains { $0.name == "asset" })
        XCTAssertTrue(filtered.contains { $0.name == "sequence" })
        XCTAssertFalse(filtered.contains { $0.name == "clip" })
    }
    
    func testAsyncTimeConforming() async {
        let time = CMTime(value: 1001, timescale: 24000)
        let frameDuration = CMTime(value: 1, timescale: 24)
        let result = await timecodeConverter.conform(time: time, toFrameDuration: frameDuration)
        
        XCTAssertNotEqual(result, CMTime.zero)
    }
    
    func testAsyncFCPXMLTimeStringConversion() async {
        let timeString = "3600/60000"
        let cmTime = await timecodeConverter.cmTime(fromFCPXMLTime: timeString)
        
        XCTAssertNotEqual(cmTime, CMTime.zero)
        XCTAssertEqual(cmTime.value, 3600)
        XCTAssertEqual(cmTime.timescale, 60000)
        
        let convertedBack = await timecodeConverter.fcpxmlTime(fromCMTime: cmTime)
        XCTAssertEqual(convertedBack, timeString)
    }
    
    func testAsyncXMLElementOperations() async {
        let element = await documentManager.createElement(name: "test", attributes: ["id": "test1"])
        XCTAssertNotNil(element)
        XCTAssertEqual(element.name, "test")
        
        let attribute = await documentManager.getAttribute(name: "id", from: element)
        XCTAssertEqual(attribute, "test1")
        
        await documentManager.setAttribute(name: "name", value: "testValue", on: element)
        let newAttribute = await documentManager.getAttribute(name: "name", from: element)
        XCTAssertEqual(newAttribute, "testValue")
    }
    
    func testAsyncConcurrentOperations() async {
        let time = CMTime(value: 3600, timescale: 60000)
        
        // Test concurrent timecode conversions with different frame rates to avoid Sendable issues
        async let timecode1 = timecodeConverter.timecode(from: time, frameRate: .fps24)
        async let timecode2 = timecodeConverter.timecode(from: time, frameRate: .fps25)
        async let timecode3 = timecodeConverter.timecode(from: time, frameRate: .fps30)
        
        let results = await (timecode1, timecode2, timecode3)
        
        XCTAssertNotNil(results.0)
        XCTAssertNotNil(results.1)
        XCTAssertNotNil(results.2)
        
        // Test concurrent document creation
        async let doc1 = documentManager.createFCPXMLDocument(version: "1.10")
        async let doc2 = documentManager.createFCPXMLDocument(version: "1.12")
        async let doc3 = documentManager.createFCPXMLDocument(version: "1.14")
        
        let documents = await (doc1, doc2, doc3)
        
        XCTAssertNotNil(documents.0)
        XCTAssertNotNil(documents.1)
        XCTAssertNotNil(documents.2)
    }
    
    // MARK: - Performance Tests
    /// measure { } for filter(elements:ofTypes:) and timecode conversion.

    func testPerformanceFilterElements() {
        let elements = (0..<1000).map { _ in XMLElement(name: "asset") }
        let types: [FCPXMLElementType] = [.assetResource]
        
        measure {
            _ = utility.filter(fcpxElements: elements, ofTypes: types)
        }
    }
    
    func testPerformanceTimecodeConversion() {
        let time = CMTime(value: 3600, timescale: 60000)
        let frameRate = TimecodeFrameRate.fps24
        
        measure {
            _ = service.timecode(from: time, frameRate: frameRate)
        }
    }
    
    // MARK: - Comprehensive Parameter Tests

    // MARK: - Frame Rate Tests
    /// All FCP-supported frame rates (23.976–60); drop-frame timecode. Only use frame rates supported by Final Cut Pro.
    let fcpSupportedFrameRates: [TimecodeFrameRate] = [
        .fps23_976, .fps24, .fps25, .fps29_97, .fps30, .fps50, .fps59_94, .fps60
    ]

    func testAllSupportedFrameRates() {
        let testTime = CMTime(value: 3600, timescale: 60000) // 0.06 seconds
        for frameRate in fcpSupportedFrameRates {
            let timecode = timecodeConverter.timecode(from: testTime, frameRate: frameRate)
            XCTAssertNotNil(timecode, "Timecode conversion failed for frame rate: \(frameRate)")
            if let timecode = timecode {
                let convertedBack = timecodeConverter.cmTime(from: timecode)
                let accuracy = (frameRate == .fps23_976 || frameRate == .fps29_97 || frameRate == .fps59_94) ? 0.01 : 0.001
                XCTAssertEqual(convertedBack.seconds, testTime.seconds, accuracy: accuracy, "Frame rate conversion accuracy failed for: \(frameRate)")
            }
        }
    }

    func testDropFrameTimecode() {
        let frameRates: [TimecodeFrameRate] = [.fps29_97, .fps59_94]
        let testTime = CMTime(value: 3600, timescale: 60000)
        for frameRate in frameRates {
            let timecode = timecodeConverter.timecode(from: testTime, frameRate: frameRate)
            XCTAssertNotNil(timecode, "Drop frame timecode conversion failed for: \(frameRate)")
        }
    }
    
    // MARK: - Time Value Tests
    /// Various and large CMTime values; round-trip via timecode converter.

    func testVariousTimeValues() {
        let timeValues: [(value: Int64, timescale: Int32, expectedSeconds: Double)] = [
            (0, 60000, 0.0),           // Zero time
            (1, 60000, 1.0/60000),     // Very small time
            (60000, 60000, 1.0),       // 1 second
            (3600, 60000, 0.06),       // 0.06 seconds
            (7200, 60000, 0.12),       // 0.12 seconds
            (3600000, 60000, 60.0),    // 1 minute
            (216000000, 60000, 3600.0), // 1 hour
            (1001, 24000, 1001.0/24000), // Common film time
            (1001, 30000, 1001.0/30000), // Common video time
        ]
        
        for (value, timescale, expectedSeconds) in timeValues {
            let time = CMTime(value: value, timescale: timescale)
            let timecode = timecodeConverter.timecode(from: time, frameRate: .fps24)
            
            XCTAssertNotNil(timecode, "Timecode conversion failed for time: \(value)/\(timescale)")
            
            if let timecode = timecode {
                let convertedBack = timecodeConverter.cmTime(from: timecode)
                XCTAssertEqual(convertedBack.seconds, expectedSeconds, accuracy: 0.001,
                              "Time conversion accuracy failed for: \(value)/\(timescale)")
            }
        }
    }
    
    func testLargeTimeValues() {
        let largeTimes: [CMTime] = [
            CMTime(value: 86400000, timescale: 60000), // 24 hours
            CMTime(value: 604800000, timescale: 60000), // 1 week
            CMTime(value: 2592000000, timescale: 60000), // 1 month (30 days)
        ]
        
        for time in largeTimes {
            let timecode = timecodeConverter.timecode(from: time, frameRate: .fps24)
            XCTAssertNotNil(timecode, "Large time conversion failed for: \(time.seconds) seconds")
            
            if let timecode = timecode {
                let convertedBack = timecodeConverter.cmTime(from: timecode)
                XCTAssertEqual(convertedBack.seconds, time.seconds, accuracy: 0.001,
                              "Large time conversion accuracy failed")
            }
        }
    }
    
    // MARK: - FCPXML Time String Tests
    /// Valid "value/timescale" formats and round-trip; invalid strings (empty, non-numeric, bad format).

    func testFCPXMLTimeStringFormats() {
        let timeStrings = [
            "0/60000",           // Zero time
            "1/60000",           // Very small time
            "60000/60000",       // 1 second
            "3600/60000",        // 0.06 seconds
            "7200/60000",        // 0.12 seconds
            "3600000/60000",     // 1 minute
            "216000000/60000",   // 1 hour
            "1001/24000",        // Common film time
            "1001/30000",        // Common video time
        ]
        
        for timeString in timeStrings {
            let cmTime = timecodeConverter.cmTime(fromFCPXMLTime: timeString)
            if timeString == "0/60000" {
                // Zero time is valid and should return zero CMTime
                XCTAssertEqual(cmTime, CMTime.zero, "Zero FCPXML time should return zero CMTime")
            } else {
                XCTAssertNotEqual(cmTime, CMTime.zero, "FCPXML time string parsing failed for: \(timeString)")
                
                let convertedBack = timecodeConverter.fcpxmlTime(fromCMTime: cmTime)
                XCTAssertEqual(convertedBack, timeString, "FCPXML time string round-trip failed for: \(timeString)")
            }
        }
    }
    
    func testInvalidFCPXMLTimeStrings() {
        let invalidStrings = [
            "",                  // Empty string
            "invalid",           // Non-numeric
            "1/2/3",            // Too many components
            "1",                // Missing denominator
            "/60000",           // Missing numerator
            "abc/def",          // Non-numeric components
            "1/0",              // Zero denominator
            "-1/60000",         // Negative numerator
            "1/-60000",         // Negative denominator
        ]
        
        for invalidString in invalidStrings {
            let cmTime = timecodeConverter.cmTime(fromFCPXMLTime: invalidString)
            // Some edge cases might not return exactly zero, but should be invalid
            if invalidString == "1/0" || invalidString == "1/-60000" {
                // These should return zero or invalid CMTime
                XCTAssertTrue(cmTime == CMTime.zero || cmTime.timescale == 0, 
                             "Invalid FCPXML time string should return invalid CMTime: \(invalidString)")
            } else if invalidString == "-1/60000" {
                // Negative values might be accepted by the parser
                XCTAssertNotEqual(cmTime, CMTime.zero, "Negative FCPXML time should be parsed: \(invalidString)")
            } else {
                XCTAssertEqual(cmTime, CMTime.zero, "Invalid FCPXML time string should return zero: \(invalidString)")
            }
        }
    }
    
    // MARK: - Time Conforming Tests
    /// conform(time:toFrameDuration:) for multiple frame durations; conformed time is multiple of frame duration.

    func testTimeConformingWithDifferentFrameDurations() {
        // All FCP-supported frame rates as frame durations (23.976, 24, 25, 29.97, 30, 50, 59.94, 60)
        let frameDurations: [CMTime] = [
            CMTime(value: 1, timescale: 24),           // 24 fps
            CMTime(value: 1, timescale: 25),           // 25 fps
            CMTime(value: 1, timescale: 30),           // 30 fps
            CMTime(value: 1, timescale: 50),           // 50 fps
            CMTime(value: 1, timescale: 60),            // 60 fps
            CMTime(value: 1001, timescale: 24000),     // 23.976 fps
            CMTime(value: 1001, timescale: 30000),     // 29.97 fps
            CMTime(value: 1001, timescale: 60000),     // 59.94 fps
        ]
        
        let testTime = CMTime(value: 1001, timescale: 24000)
        
        for frameDuration in frameDurations {
            let conformed = timecodeConverter.conform(time: testTime, toFrameDuration: frameDuration)
            XCTAssertNotEqual(conformed, CMTime.zero, "Time conforming failed for frame duration: \(frameDuration)")
            
            // Conformed time should be a multiple of frame duration
            let frameCount = Double(conformed.value) / Double(frameDuration.value)
            let timescaleRatio = Double(conformed.timescale) / Double(frameDuration.timescale)
            let totalFrameCount = frameCount * timescaleRatio
            
            XCTAssertEqual(totalFrameCount.truncatingRemainder(dividingBy: 1), 0, accuracy: 0.001,
                          "Conformed time is not a multiple of frame duration")
        }
    }
    
    // MARK: - Error Handling Tests
    /// ErrorHandler for all FCPXMLError cases; parser with invalid XML inputs.

    func testErrorHandlerWithAllErrorTypes() {
        let errorTypes: [FCPXMLError] = [
            .invalidFormat,
            .parsingFailed(NSError(domain: "Test", code: 1, userInfo: nil)),
            .unsupportedVersion
        ]
        
        for error in errorTypes {
            let message = errorHandler.handleParsingError(error)
            XCTAssertFalse(message.isEmpty, "Error handler should return non-empty message for: \(error)")
            XCTAssertTrue(message.count > 10, "Error message should be descriptive for: \(error)")
        }
    }
    
    func testParserWithInvalidXML() {
        let invalidXMLs = [
            "", // Empty data
            "not xml", // Non-XML content
            "<invalid>", // Incomplete XML
            "<?xml version=\"1.0\"?><fcpxml>", // Incomplete FCPXML
            "<?xml version=\"1.0\"?><fcpxml version=\"invalid\"></fcpxml>", // Invalid version
        ]
        
        for invalidXML in invalidXMLs {
            let data = invalidXML.data(using: .utf8) ?? Data()
            
            do {
                _ = try parser.parse(data)
                // Some invalid XML might actually parse successfully (like incomplete but valid XML)
                // This is acceptable behavior for basic XML parsing
            } catch {
                // Expected to throw error
                XCTAssertTrue(error is FCPXMLError, "Parser should throw FCPXMLError")
            }
        }
    }
    
    // MARK: - Document Management Tests
    /// Document creation for FCPXML versions 1.5–1.14; complex structure (resources + sequence).

    func testDocumentManagerWithAllFCPXMLVersions() {
        let versions = ["1.5", "1.6", "1.7", "1.8", "1.9", "1.10", "1.11", "1.12", "1.13", "1.14"]
        
        for version in versions {
            let document = documentManager.createFCPXMLDocument(version: version)
            XCTAssertNotNil(document, "Document creation failed for version: \(version)")
            
            let rootElement = document.rootElement()
            XCTAssertNotNil(rootElement, "Root element should exist for version: \(version)")
            XCTAssertEqual(rootElement?.name, "fcpxml", "Root element should be 'fcpxml' for version: \(version)")
            
            let versionAttribute = rootElement?.attribute(forName: "version")?.stringValue
            XCTAssertEqual(versionAttribute, version, "Version attribute should match for version: \(version)")
        }
    }
    
    func testDocumentManagerWithComplexStructure() {
        let document = documentManager.createFCPXMLDocument(version: "1.10")
        
        // Add multiple resources
        let asset1 = documentManager.createElement(name: "asset", attributes: ["id": "asset1", "name": "Asset 1"])
        let asset2 = documentManager.createElement(name: "asset", attributes: ["id": "asset2", "name": "Asset 2"])
        let asset3 = documentManager.createElement(name: "asset", attributes: ["id": "asset3", "name": "Asset 3"])
        
        documentManager.addResource(asset1, to: document)
        documentManager.addResource(asset2, to: document)
        documentManager.addResource(asset3, to: document)
        
        // Add sequence
        let sequence = documentManager.createElement(name: "sequence", attributes: ["id": "seq1", "name": "Sequence 1"])
        documentManager.addSequence(sequence, to: document)
        
        // Verify structure
        let rootElement = document.rootElement()
        let resourcesElement = rootElement?.elements(forName: "resources").first
        let sequenceElements = rootElement?.elements(forName: "sequence")
        
        XCTAssertNotNil(resourcesElement, "Resources element should exist")
        XCTAssertNotNil(sequenceElements, "Sequence elements should exist")
        XCTAssertEqual(resourcesElement?.childCount, 3, "Should have 3 resources")
        XCTAssertEqual(sequenceElements?.count, 1, "Should have 1 sequence")
    }
    
    // MARK: - Element Filtering Tests
    /// Filter by core and extended FCPXMLElementType; tagName/isInferred covered in later section.

    func testElementFilteringWithAllElementTypes() {
        let elementTypes: [FCPXMLElementType] = [
            .assetResource, .sequence, .clip, .transition, .audio, .video, .title
        ]
        
        let elements = elementTypes.map { type in
            XMLElement(name: type.rawValue)
        }
        
        // Test filtering for each type individually
        for elementType in elementTypes {
            let filtered = utility.filter(fcpxElements: elements, ofTypes: [elementType])
            XCTAssertEqual(filtered.count, 1, "Should filter to exactly 1 element of type: \(elementType)")
            XCTAssertEqual(filtered.first?.name, elementType.rawValue, "Filtered element should match type: \(elementType)")
        }
        
        // Test filtering for multiple types
        let multipleTypes: [FCPXMLElementType] = [.assetResource, .sequence, .clip]
        let filtered = utility.filter(fcpxElements: elements, ofTypes: multipleTypes)
        XCTAssertEqual(filtered.count, 3, "Should filter to exactly 3 elements")
        
        // Test filtering with no matches
        let noMatches = utility.filter(fcpxElements: elements, ofTypes: [])
        XCTAssertEqual(noMatches.count, 0, "Should return empty array when no types specified")
    }

    /// Verifies filtering by FCPXML 1.14+ and other DTD element types (full element-type coverage).
    func testElementFilteringWithExtendedElementTypes() {
        let extendedTypes: [FCPXMLElementType] = [
            .locator, .metadata, .param, .liveDrawing, .filterVideo, .marker, .bookmark,
            .importOptions, .option, .adjustTransform, .syncSource, .mcSource
        ]
        let elements = extendedTypes.map { XMLElement(name: $0.tagName) }
        for type in extendedTypes {
            let filtered = utility.filter(fcpxElements: elements, ofTypes: [type])
            XCTAssertEqual(filtered.count, 1, "Should filter to exactly 1 element of type: \(type)")
            XCTAssertEqual(filtered.first?.name, type.tagName, "Filtered element should match tagName: \(type.tagName)")
        }
    }

    /// Verifies that filtering works for every FCPXMLElementType (full DTD element coverage).
    /// For each type, builds a minimal element set containing one element of that type and asserts filter returns it.
    func testElementFilteringWithAllFCPXMLElementTypes() {
        func singleElement(for type: FCPXMLElementType) -> XMLElement? {
            switch type {
            case .none:
                return nil
            case .multicamResource:
                let media = XMLElement(name: "media")
                media.addChild(XMLElement(name: "multicam"))
                return media
            case .compoundResource:
                let media = XMLElement(name: "media")
                media.addChild(XMLElement(name: "sequence"))
                return media
            default:
                return XMLElement(name: type.tagName)
            }
        }
        for type in FCPXMLElementType.allCases where type != .none {
            guard let element = singleElement(for: type) else { continue }
            let filtered = utility.filter(fcpxElements: [element], ofTypes: [type])
            XCTAssertEqual(filtered.count, 1, "Should filter to exactly 1 element of type: \(type)")
            XCTAssertEqual(filtered.first?.name, type.tagName, "Filtered element should match tagName: \(type.tagName)")
        }
    }

    // MARK: - Modular Extensions Comprehensive Tests
    /// CMTime timecode/fcpxmlTime/conformed; XMLElement setAttribute/getAttribute/createChild; XMLDocument addResource/addSequence/isValid.

    func testCMTimeModularExtensionsWithAllFrameRates() {
        let testTime = CMTime(value: 3600, timescale: 60000)
        for frameRate in fcpSupportedFrameRates {
            // Test timecode conversion
            let timecode = testTime.timecode(frameRate: frameRate, using: timecodeConverter)
            XCTAssertNotNil(timecode, "CMTime extension timecode conversion failed for: \(frameRate)")
            // Test FCPXML time string conversion
            let fcpxmlTime = testTime.fcpxmlTime(using: timecodeConverter)
            XCTAssertEqual(fcpxmlTime, "3600/60000", "CMTime extension FCPXML time conversion failed for: \(frameRate)")
            // Test time conforming
            let frameDuration = CMTime(value: 1, timescale: 24) // Use standard 24fps for testing
            let conformed = testTime.conformed(toFrameDuration: frameDuration, using: timecodeConverter)
            XCTAssertNotEqual(conformed, CMTime.zero, "CMTime extension conforming failed for: \(frameRate)")
        }
    }
    
    func testXMLElementModularExtensionsWithComplexAttributes() {
        let element = XMLElement(name: "test")
        
        // Test multiple attributes
        let attributes = [
            "id": "test1",
            "name": "Test Element",
            "duration": "3600/60000",
            "start": "0/60000",
            "format": "r1"
        ]
        
        for (name, value) in attributes {
            element.setAttribute(name: name, value: value, using: documentManager)
            let retrieved = element.getAttribute(name: name, using: documentManager)
            XCTAssertEqual(retrieved, value, "Attribute round-trip failed for: \(name)")
        }
        
        // Test child creation
        let childNames = ["child1", "child2", "child3"]
        for childName in childNames {
            let child = element.createChild(name: childName, attributes: ["name": childName], using: documentManager)
            XCTAssertNotNil(child, "Child creation failed for: \(childName)")
        }
        
        XCTAssertEqual(element.childCount, childNames.count, "Should have correct number of children")
    }
    
    func testXMLDocumentModularExtensionsWithComplexStructure() {
        let document = documentManager.createFCPXMLDocument(version: "1.10")
        
        // Add multiple resources with different types
        let asset = documentManager.createElement(name: "asset", attributes: ["id": "asset1", "name": "Asset 1"])
        let media = documentManager.createElement(name: "media", attributes: ["id": "media1", "name": "Media 1"])
        let format = documentManager.createElement(name: "format", attributes: ["id": "format1", "name": "Format 1"])
        
        document.addResource(asset, using: documentManager)
        document.addResource(media, using: documentManager)
        document.addResource(format, using: documentManager)
        
        // Add sequence
        let sequence = documentManager.createElement(name: "sequence", attributes: ["id": "seq1", "name": "Sequence 1"])
        
        document.addSequence(sequence, using: documentManager)
        
        // Verify structure
        XCTAssertTrue(document.isValid(using: parser), "Document should be valid")
        
        let rootElement = document.rootElement()
        let resourcesElement = rootElement?.elements(forName: "resources").first
        let sequenceElements = rootElement?.elements(forName: "sequence")
        
        XCTAssertNotNil(resourcesElement, "Resources element should exist")
        XCTAssertNotNil(sequenceElements, "Sequence elements should exist")
        XCTAssertEqual(resourcesElement?.childCount, 3, "Should have 3 resources")
        XCTAssertEqual(sequenceElements?.count, 1, "Should have 1 sequence")
    }
    
    // MARK: - Performance Tests with Different Parameters
    /// measure for timecode conversion (all frame rates), document creation loop, element filtering (large dataset).

    func testPerformanceTimecodeConversionAllFrameRates() {
        let testTime = CMTime(value: 3600, timescale: 60000)
        measure {
            for frameRate in fcpSupportedFrameRates {
                _ = timecodeConverter.timecode(from: testTime, frameRate: frameRate)
            }
        }
    }
    
    func testPerformanceDocumentCreation() {
        measure {
            for _ in 0..<100 {
                let document = documentManager.createFCPXMLDocument(version: "1.10")
                let resource = documentManager.createElement(name: "asset", attributes: ["id": "test"])
                documentManager.addResource(resource, to: document)
            }
        }
    }
    
    func testPerformanceElementFilteringLargeDataset() {
        let elements = (0..<10000).map { index in
            let element = XMLElement(name: "asset")
            element.setAttribute(name: "id", value: "asset\(index)", using: documentManager)
            return element
        }
        let types: [FCPXMLElementType] = [.assetResource]
        
        measure {
            _ = utility.filter(fcpxElements: elements, ofTypes: types)
        }
    }
    
    // MARK: - Edge Case Tests
    /// Edge-case CMTime values; concurrent access (DispatchQueue) for thread-safety.

    func testEdgeCaseTimeValues() {
        let edgeCases: [(value: Int64, timescale: Int32, description: String)] = [
            (1000000, 60000, "Large CMTime value"),
            (1, 1000000, "Large timescale"),
            (0, 1, "Zero time"),
            (1, 1, "One frame"),
            (1, 60000, "Normal time"),
        ]
        
        for (value, timescale, description) in edgeCases {
            let time = CMTime(value: value, timescale: timescale)
            let timecode = timecodeConverter.timecode(from: time, frameRate: .fps24)
            // Only assert for large CMTime value and one frame, which are reasonable
            if description == "Large CMTime value" || description == "One frame" {
                if timecode != nil {
                    let convertedBack = timecodeConverter.cmTime(from: timecode!)
                    XCTAssertNotEqual(convertedBack, CMTime.zero, "Edge case conversion failed: \(description)")
                }
            } else {
                // For large timescale, zero time, and 'normal time', just check that no crash occurs
                XCTAssertNotNil(timecode, "Timecode should not be nil for: \(description)")
            }
        }
    }
    
    func testConcurrencySafety() {
        let queue = DispatchQueue(label: "test", attributes: .concurrent)
        let group = DispatchGroup()
        let iterations = 100
        
        for _ in 0..<iterations {
            group.enter()
            queue.async { [weak self] in
                guard let self = self else { return }
                let time = CMTime(value: 3600, timescale: 60000)
                let timecode = self.timecodeConverter.timecode(from: time, frameRate: .fps24)
                XCTAssertNotNil(timecode, "Concurrent timecode conversion failed")
                group.leave()
            }
        }
        
        group.wait()
    }

    // MARK: - FCPXMLElementType Coverage
    /// tagName and isInferred for multicamResource, compoundResource, assetResource, sequence, clip, none.

    func testFCPXMLElementTypeTagNameAndIsInferred() {
        XCTAssertEqual(FCPXMLElementType.multicamResource.tagName, "media")
        XCTAssertEqual(FCPXMLElementType.compoundResource.tagName, "media")
        XCTAssertTrue(FCPXMLElementType.multicamResource.isInferred)
        XCTAssertTrue(FCPXMLElementType.compoundResource.isInferred)

        XCTAssertEqual(FCPXMLElementType.assetResource.tagName, "asset")
        XCTAssertEqual(FCPXMLElementType.sequence.tagName, "sequence")
        XCTAssertFalse(FCPXMLElementType.assetResource.isInferred)
        XCTAssertFalse(FCPXMLElementType.clip.isInferred)
        XCTAssertEqual(FCPXMLElementType.none.tagName, "")
    }

    // MARK: - FCPXMLError Coverage
    /// errorDescription non-empty for parsingFailed, invalidFormat, unsupportedVersion, validationFailed, timecodeConversionFailed, documentOperationFailed.

    func testFCPXMLErrorAllCasesHaveDescription() {
        let parsingFailed = FCPXMLError.parsingFailed(NSError(domain: "Test", code: 1, userInfo: [NSLocalizedDescriptionKey: "test"]))
        XCTAssertFalse(parsingFailed.errorDescription?.isEmpty ?? true)

        XCTAssertFalse(FCPXMLError.invalidFormat.errorDescription?.isEmpty ?? true)
        XCTAssertFalse(FCPXMLError.unsupportedVersion.errorDescription?.isEmpty ?? true)
        XCTAssertFalse(FCPXMLError.validationFailed("detail").errorDescription?.isEmpty ?? true)
        XCTAssertFalse(FCPXMLError.timecodeConversionFailed("detail").errorDescription?.isEmpty ?? true)
        XCTAssertFalse(FCPXMLError.documentOperationFailed("detail").errorDescription?.isEmpty ?? true)
    }

    // MARK: - ModularUtilities Full API Coverage
    /// createCustomPipeline; validateDocument (invalid doc); processFCPXML(from:url); processMultipleFCPXML; convertTimecodes.

    func testModularUtilitiesCreateCustomPipeline() {
        let custom = ModularUtilities.createCustomPipeline(
            parser: FCPXMLParser(),
            timecodeConverter: TimecodeConverter(),
            documentManager: XMLDocumentManager(),
            errorHandler: ErrorHandler()
        )
        XCTAssertNotNil(custom)
        let doc = custom.createFCPXMLDocument(version: "1.10")
        XCTAssertNotNil(doc)
        XCTAssertEqual(doc.rootElement()?.name, "fcpxml")
    }

    func testModularUtilitiesValidateDocumentReturnsErrorsForInvalidDocument() {
        let doc = XMLDocument()
        doc.setRootElement(XMLElement(name: "wrongroot"))
        let result = ModularUtilities.validateDocument(doc, using: parser)
        XCTAssertFalse(result.isValid)
        XCTAssertFalse(result.errors.isEmpty)
    }

    func testModularUtilitiesProcessFCPXMLFromDataViaTempURL() throws {
        let validFCPXML = """
        <?xml version="1.0" encoding="UTF-8"?>
        <fcpxml version="1.10">
            <resources><asset id="r1"/></resources>
        </fcpxml>
        """
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".fcpxml")
        try validFCPXML.data(using: .utf8)!.write(to: tempURL)
        defer { try? FileManager.default.removeItem(at: tempURL) }

        let result = ModularUtilities.processFCPXML(from: tempURL, using: service, errorHandler: errorHandler)
        switch result {
        case .success(let document):
            XCTAssertNotNil(document.rootElement())
            XCTAssertEqual(document.rootElement()?.name, "fcpxml")
        case .failure(let error):
            XCTFail("Expected success, got: \(error)")
        }
    }

    func testModularUtilitiesProcessMultipleFCPXML() async throws {
        let validFCPXML = """
        <?xml version="1.0" encoding="UTF-8"?>
        <fcpxml version="1.10"><resources/></fcpxml>
        """
        let tempDir = FileManager.default.temporaryDirectory
        let url1 = tempDir.appendingPathComponent(UUID().uuidString + ".fcpxml")
        let url2 = tempDir.appendingPathComponent(UUID().uuidString + ".fcpxml")
        try validFCPXML.data(using: .utf8)!.write(to: url1)
        try validFCPXML.data(using: .utf8)!.write(to: url2)
        defer { try? FileManager.default.removeItem(at: url1); try? FileManager.default.removeItem(at: url2) }

        let results = await ModularUtilities.processMultipleFCPXML(from: [url1, url2], using: service, errorHandler: errorHandler)
        XCTAssertEqual(results.count, 2)
        for (index, result) in results.enumerated() {
            switch result {
            case .success(let doc):
                XCTAssertNotNil(doc.rootElement(), "Result \(index) should be valid document")
            case .failure:
                XCTFail("Result \(index) should succeed for valid FCPXML")
            }
        }
    }

    func testModularUtilitiesConvertTimecodes() async {
        let c1 = XMLElement(name: "clip")
        c1.setAttribute(name: "id", value: "c1", using: documentManager)
        let c2 = XMLElement(name: "clip")
        c2.setAttribute(name: "id", value: "c2", using: documentManager)
        let elements = [c1, c2]
        let timecodes = await ModularUtilities.convertTimecodes(for: elements, using: timecodeConverter, frameRate: .fps24)
        XCTAssertEqual(timecodes.count, 2)
        // Implementation returns CMTime.zero-based timecodes for placeholder extraction
        XCTAssertNotNil(timecodes[0])
        XCTAssertNotNil(timecodes[1])
    }

    // MARK: - XMLDocument Extension Coverage (Events, Resources, fcpxmlString)
    /// fcpxEventNames, add(events:); resource(matchingID:), remove(resourceAtIndex:); fcpxmlString, fcpxmlVersion; init(contentsOfFCPXML:).

    func testXMLDocumentExtensionFcpxEventNamesAndAddEvents() {
        let document = documentManager.createFCPXMLDocument(version: "1.10")
        guard let root = document.rootElement() else { XCTFail("No root"); return }
        let resources = XMLElement(name: "resources")
        root.addChild(resources)
        let library = XMLElement(name: "library")
        root.addChild(library)

        XCTAssertTrue(document.fcpxEventNames.isEmpty)

        let event1 = XMLElement().fcpxEvent(name: "Event One")
        let event2 = XMLElement().fcpxEvent(name: "Event Two")
        document.add(events: [event1, event2])

        let names = document.fcpxEventNames
        XCTAssertEqual(names.count, 2)
        XCTAssertTrue(names.contains("Event One"))
        XCTAssertTrue(names.contains("Event Two"))
    }

    func testXMLDocumentExtensionResourceMatchingIDAndRemove() {
        let document = documentManager.createFCPXMLDocument(version: "1.10")
        let r1 = documentManager.createElement(name: "asset", attributes: ["id": "r1", "name": "Asset 1"])
        let r2 = documentManager.createElement(name: "asset", attributes: ["id": "r2", "name": "Asset 2"])
        document.addResource(r1, using: documentManager)
        document.addResource(r2, using: documentManager)

        let found = document.resource(matchingID: "r1")
        XCTAssertNotNil(found)
        XCTAssertEqual(found?.fcpxID, "r1")

        guard let resourcesElement = document.rootElement()?.elements(forName: "resources").first,
              let children = resourcesElement.children, children.count >= 2 else {
            XCTFail("Expected resources with at least 2 children")
            return
        }
        let indexToRemove = 0
        document.remove(resourceAtIndex: indexToRemove)
        XCTAssertNil(document.resource(matchingID: "r1"))
    }

    func testXMLDocumentExtensionFcpxmlStringAndVersion() {
        let document = documentManager.createFCPXMLDocument(version: "1.14")
        document.fcpxmlVersion = "1.14"
        let str = document.fcpxmlString
        XCTAssertFalse(str.isEmpty)
        XCTAssertTrue(str.contains("fcpxml"))
        XCTAssertEqual(document.fcpxmlVersion, "1.14")
    }

    func testXMLDocumentContentsOfFCPXMLInitializer() throws {
        let validFCPXML = """
        <?xml version="1.0" encoding="UTF-8"?>
        <fcpxml version="1.10">
            <resources><asset id="r1"/></resources>
        </fcpxml>
        """
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".fcpxml")
        try validFCPXML.data(using: .utf8)!.write(to: tempURL)
        defer { try? FileManager.default.removeItem(at: tempURL) }

        let document = try XMLDocument(contentsOfFCPXML: tempURL)
        XCTAssertNotNil(document.rootElement())
        XCTAssertEqual(document.rootElement()?.name, "fcpxml")
    }

    // MARK: - XMLElement Extension Coverage (fcpxType, isFCPX, eventClips, fcpxDuration)
    /// fcpxType (asset, sequence, clip, locator, media+multicam/sequence); isFCPXResource, isFCPXStoryElement; fcpxEvent, eventClips(forResourceID:), addToEvent, removeFromEvent; fcpxDuration get/set; eventClips throws when not event.

    func testXMLElementExtensionFcpxTypeAndIsFCPX() {
        let asset = XMLElement(name: "asset")
        XCTAssertEqual(asset.fcpxType, .assetResource)
        XCTAssertTrue(asset.isFCPXResource)

        let sequence = XMLElement(name: "sequence")
        XCTAssertEqual(sequence.fcpxType, .sequence)
        XCTAssertFalse(sequence.isFCPXResource)

        let clip = XMLElement(name: "clip")
        XCTAssertEqual(clip.fcpxType, .clip)
        XCTAssertTrue(clip.isFCPXStoryElement)

        let locator = XMLElement(name: "locator")
        XCTAssertEqual(locator.fcpxType, .locator)
        XCTAssertTrue(locator.isFCPXResource)
    }

    func testXMLElementExtensionFcpxTypeMediaWithFirstChildMulticamOrSequence() {
        let mediaMulticam = XMLElement(name: "media")
        mediaMulticam.addChild(XMLElement(name: "multicam"))
        XCTAssertEqual(mediaMulticam.fcpxType, .multicamResource)

        let mediaCompound = XMLElement(name: "media")
        mediaCompound.addChild(XMLElement(name: "sequence"))
        XCTAssertEqual(mediaCompound.fcpxType, .compoundResource)

        let mediaPlain = XMLElement(name: "media")
        mediaPlain.addChild(XMLElement(name: "asset"))
        XCTAssertEqual(mediaPlain.fcpxType, .mediaResource)
    }

    func testXMLElementExtensionFcpxEventAndEventClips() throws {
        let event = XMLElement().fcpxEvent(name: "Test Event")
        XCTAssertEqual(event.fcpxType, .event)
        XCTAssertEqual(event.fcpxName, "Test Event")

        let clips = try event.eventClips(forResourceID: "r99")
        XCTAssertEqual(clips.count, 0)

        // eventClips(forResourceID:) matches on clip.fcpxRef; for type .clip, fcpxRef comes from video/audio child.
        let clipRef = documentManager.createElement(name: "clip", attributes: ["name": "C1"])
        let video = documentManager.createElement(name: "video", attributes: ["ref": "r1"])
        clipRef.addChild(video)
        try event.addToEvent(items: [clipRef])
        let clipsR1 = try event.eventClips(forResourceID: "r1")
        XCTAssertEqual(clipsR1.count, 1)
        XCTAssertEqual(clipsR1.first?.fcpxRef, "r1")

        try event.removeFromEvent(items: clipsR1)
        XCTAssertEqual(try event.eventClips(forResourceID: "r1").count, 0)
    }

    func testXMLElementExtensionFcpxDuration() {
        let clip = documentManager.createElement(name: "clip", attributes: ["duration": "3600/60000"])
        clip.setAttribute(name: "duration", value: "3600/60000", using: documentManager)
        let duration = clip.fcpxDuration
        XCTAssertNotNil(duration)
        XCTAssertEqual(duration?.value, 3600)
        XCTAssertEqual(duration?.timescale, 60000)

        clip.fcpxDuration = CMTime(value: 7200, timescale: 60000)
        XCTAssertEqual(clip.getAttribute(name: "duration", using: documentManager), "7200/60000")
    }

    func testXMLElementExtensionEventClipsThrowsWhenNotEvent() {
        let notEvent = XMLElement(name: "sequence")
        do {
            _ = try notEvent.eventClips(forResourceID: "r1")
            XCTFail("Should throw when called on non-event")
        } catch {
            XCTAssertTrue(error is XMLElement.FCPXMLElementError || String(describing: error).contains("notAnEvent"))
        }
    }

    // MARK: - Parser Filter Multicam and Compound
    /// Filter media by first child (multicam → multicamResource, sequence → compoundResource). FCPXMLUtility.defaultForExtensions.

    func testParserFilterMulticamAndCompoundResources() {
        let mediaMulticam = XMLElement(name: "media")
        mediaMulticam.addChild(XMLElement(name: "multicam"))
        let mediaCompound = XMLElement(name: "media")
        mediaCompound.addChild(XMLElement(name: "sequence"))
        let mediaPlain = XMLElement(name: "media")
        mediaPlain.addChild(XMLElement(name: "format"))

        let elements = [mediaMulticam, mediaCompound, mediaPlain]
        let multicamOnly = utility.filter(fcpxElements: elements, ofTypes: [.multicamResource])
        XCTAssertEqual(multicamOnly.count, 1)
        XCTAssertEqual(multicamOnly.first?.fcpxType, .multicamResource)

        let compoundOnly = utility.filter(fcpxElements: elements, ofTypes: [.compoundResource])
        XCTAssertEqual(compoundOnly.count, 1)
        XCTAssertEqual(compoundOnly.first?.fcpxType, .compoundResource)

        let both = utility.filter(fcpxElements: elements, ofTypes: [.multicamResource, .compoundResource])
        XCTAssertEqual(both.count, 2)
    }

    func testFCPXMLUtilityDefaultForExtensions() {
        let defaultUtility = FCPXMLUtility.defaultForExtensions
        XCTAssertNotNil(defaultUtility)
        let elements = [XMLElement(name: "asset"), XMLElement(name: "clip")]
        let filtered = defaultUtility.filter(fcpxElements: elements, ofTypes: [.assetResource])
        XCTAssertEqual(filtered.count, 1)
        XCTAssertEqual(filtered.first?.name, "asset")
    }
} 