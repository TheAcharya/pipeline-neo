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
final class PipelineNeoTests: XCTestCase {
    
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
} 