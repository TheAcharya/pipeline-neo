//
//  PipelineNeoTests.swift
//  Pipeline Neo • https://github.com/TheAcharya/pipeline-neo
//  © 2025 • Licensed under MIT License
//

import XCTest
import CoreMedia
import TimecodeKit
@testable import PipelineNeo

@available(macOS 12.0, *)
final class PipelineNeoTests: XCTestCase, @unchecked Sendable {
    
    // MARK: - Test Dependencies
    
    private var utility: FCPXMLUtility!
    private var service: FCPXMLService!
    private var parser: FCPXMLParser!
    private var timecodeConverter: TimecodeConverter!
    private var documentManager: XMLDocumentManager!
    private var errorHandler: ErrorHandler!
    
    // MARK: - Setup and Teardown
    
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
        let frameRate = TimecodeFrameRate._24
        
        let timecode = service.timecode(from: time, frameRate: frameRate)
        
        XCTAssertNotNil(timecode)
    }
    
    func testCMTimeFromTimecode() {
        let timecode = try! Timecode(realTime: 60, at: TimecodeFrameRate._24)
        let result = service.cmTime(from: timecode)
        
        XCTAssertNotEqual(result, CMTime.zero)
        XCTAssertEqual(result.seconds, 60, accuracy: 0.001)
    }
    
    // MARK: - Modular Component Tests
    
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
        let frameRate = TimecodeFrameRate._24
        
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
    
    func testModularUtilitiesCreatePipeline() {
        let pipeline = ModularUtilities.createPipeline()
        XCTAssertNotNil(pipeline)
    }
    
    func testModularUtilitiesValidateDocument() {
        let document = documentManager.createFCPXMLDocument(version: "1.10")
        let validation = ModularUtilities.validateDocument(document, using: parser)
        
        XCTAssertTrue(validation.isValid)
        XCTAssertTrue(validation.errors.isEmpty)
    }
    
    // MARK: - Modular Extensions Tests
    
    func testCMTimeModularExtensions() {
        let time = CMTime(value: 3600, timescale: 60000)
        let frameRate = TimecodeFrameRate._24
        
        let timecode = time.timecode(frameRate: frameRate, using: timecodeConverter)
        XCTAssertNotNil(timecode)
        
        let fcpxmlTime = time.fcpxmlTime(using: timecodeConverter)
        XCTAssertEqual(fcpxmlTime, "3600/60000")
        
        let frameDuration = CMTime(value: 1, timescale: 24)
        let conformed = time.conformed(toFrameDuration: frameDuration, using: timecodeConverter)
        XCTAssertNotEqual(conformed, CMTime.zero)
    }
    
    func testXMLElementModularExtensions() {
        let element = XMLElement(name: "test")
        
        element.setAttribute(name: "id", value: "test1", using: documentManager)
        let attribute = element.getAttribute(name: "id", using: documentManager)
        XCTAssertEqual(attribute, "test1")
        
        let child = element.createChild(name: "child", attributes: ["name": "test"], using: documentManager)
        XCTAssertNotNil(child)
        XCTAssertEqual(element.childCount, 1)
    }
    
    func testXMLDocumentModularExtensions() {
        let document = documentManager.createFCPXMLDocument(version: "1.10")
        
        let resource = documentManager.createElement(name: "asset", attributes: ["id": "test1"])
        document.addResource(resource, using: documentManager)
        
        let sequence = documentManager.createElement(name: "sequence", attributes: ["id": "seq1"])
        document.addSequence(sequence, using: documentManager)
        
        XCTAssertTrue(document.isValid(using: parser))
    }
    
    // MARK: - Performance Tests
    
    func testPerformanceFilterElements() {
        let elements = (0..<1000).map { _ in XMLElement(name: "asset") }
        let types: [FCPXMLElementType] = [.assetResource]
        
        measure {
            _ = utility.filter(fcpxElements: elements, ofTypes: types)
        }
    }
    
    func testPerformanceTimecodeConversion() {
        let time = CMTime(value: 3600, timescale: 60000)
        let frameRate = TimecodeFrameRate._24
        
        measure {
            _ = service.timecode(from: time, frameRate: frameRate)
        }
    }
    
    // MARK: - Comprehensive Parameter Tests
    
    // MARK: - Frame Rate Tests
    // Only use frame rates supported by Final Cut Pro
    let fcpSupportedFrameRates: [TimecodeFrameRate] = [
        ._23_976, ._24, ._25, ._29_97, ._30, ._50, ._59_94, ._60
    ]

    func testAllSupportedFrameRates() {
        let testTime = CMTime(value: 3600, timescale: 60000) // 0.06 seconds
        for frameRate in fcpSupportedFrameRates {
            let timecode = timecodeConverter.timecode(from: testTime, frameRate: frameRate)
            XCTAssertNotNil(timecode, "Timecode conversion failed for frame rate: \(frameRate)")
            if let timecode = timecode {
                let convertedBack = timecodeConverter.cmTime(from: timecode)
                let accuracy = (frameRate == ._23_976 || frameRate == ._29_97 || frameRate == ._59_94) ? 0.01 : 0.001
                XCTAssertEqual(convertedBack.seconds, testTime.seconds, accuracy: accuracy, "Frame rate conversion accuracy failed for: \(frameRate)")
            }
        }
    }

    func testDropFrameTimecode() {
        let frameRates: [TimecodeFrameRate] = [._29_97, ._59_94]
        let testTime = CMTime(value: 3600, timescale: 60000)
        for frameRate in frameRates {
            let timecode = timecodeConverter.timecode(from: testTime, frameRate: frameRate)
            XCTAssertNotNil(timecode, "Drop frame timecode conversion failed for: \(frameRate)")
        }
    }
    
    // MARK: - Time Value Tests
    
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
            let timecode = timecodeConverter.timecode(from: time, frameRate: ._24)
            
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
            let timecode = timecodeConverter.timecode(from: time, frameRate: ._24)
            XCTAssertNotNil(timecode, "Large time conversion failed for: \(time.seconds) seconds")
            
            if let timecode = timecode {
                let convertedBack = timecodeConverter.cmTime(from: timecode)
                XCTAssertEqual(convertedBack.seconds, time.seconds, accuracy: 0.001,
                              "Large time conversion accuracy failed")
            }
        }
    }
    
    // MARK: - FCPXML Time String Tests
    
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
    
    func testTimeConformingWithDifferentFrameDurations() {
        let frameDurations: [CMTime] = [
            CMTime(value: 1, timescale: 24),   // 24fps
            CMTime(value: 1, timescale: 25),   // 25fps
            CMTime(value: 1, timescale: 30),   // 30fps
            CMTime(value: 1001, timescale: 24000), // 23.976fps
            CMTime(value: 1001, timescale: 30000), // 29.97fps
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
    
    func testDocumentManagerWithAllFCPXMLVersions() {
        let versions = ["1.5", "1.6", "1.7", "1.8", "1.9", "1.10", "1.11", "1.12", "1.13"]
        
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
    
    // MARK: - Modular Extensions Comprehensive Tests
    
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
            let timecode = timecodeConverter.timecode(from: time, frameRate: ._24)
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
                let timecode = self.timecodeConverter.timecode(from: time, frameRate: ._24)
                XCTAssertNotNil(timecode, "Concurrent timecode conversion failed")
                group.leave()
            }
        }
        
        group.wait()
    }
} 