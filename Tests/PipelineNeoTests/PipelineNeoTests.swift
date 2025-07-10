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
    
    // MARK: - Test Properties
    
    var testFCPXMLDocument: XMLDocument!
    var testUtility: FCPXMLUtility!
    
    // MARK: - Setup and Teardown
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        // Create a basic test FCPXML document
        let resources: [XMLElement] = []
        let events: [XMLElement] = []
        testFCPXMLDocument = XMLDocument(resources: resources, events: events, fcpxmlVersion: "1.8")
        
        // Initialize utility
        testUtility = FCPXMLUtility()
    }
    
    override func tearDownWithError() throws {
        testFCPXMLDocument = nil
        testUtility = nil
        try super.tearDownWithError()
    }
    
    // MARK: - FCPXMLElementType Tests
    
    func testFCPXMLElementTypeCases() throws {
        // Test that all cases are accessible
        XCTAssertNotNil(FCPXMLElementType.none)
        XCTAssertNotNil(FCPXMLElementType.resourceList)
        XCTAssertNotNil(FCPXMLElementType.library)
        XCTAssertNotNil(FCPXMLElementType.event)
        XCTAssertNotNil(FCPXMLElementType.project)
        XCTAssertNotNil(FCPXMLElementType.clip)
        XCTAssertNotNil(FCPXMLElementType.audio)
        XCTAssertNotNil(FCPXMLElementType.video)
        XCTAssertNotNil(FCPXMLElementType.transition)
        XCTAssertNotNil(FCPXMLElementType.marker)
        XCTAssertNotNil(FCPXMLElementType.text)
    }
    
    func testFCPXMLElementTypeRawValues() throws {
        XCTAssertEqual(FCPXMLElementType.resourceList.rawValue, "resources")
        XCTAssertEqual(FCPXMLElementType.library.rawValue, "library")
        XCTAssertEqual(FCPXMLElementType.event.rawValue, "event")
        XCTAssertEqual(FCPXMLElementType.project.rawValue, "project")
        XCTAssertEqual(FCPXMLElementType.clip.rawValue, "clip")
        XCTAssertEqual(FCPXMLElementType.audio.rawValue, "audio")
        XCTAssertEqual(FCPXMLElementType.video.rawValue, "video")
        XCTAssertEqual(FCPXMLElementType.transition.rawValue, "transition")
        XCTAssertEqual(FCPXMLElementType.marker.rawValue, "marker")
        XCTAssertEqual(FCPXMLElementType.text.rawValue, "text")
    }
    
    // MARK: - FCPXMLUtility Tests
    
    func testFCPXMLUtilityInitialization() async throws {
        let utility = FCPXMLUtility()
        XCTAssertNotNil(utility)
    }
    
    func testFilterFCPXElements() async throws {
        let utility = FCPXMLUtility()
        
        // Create test elements
        let eventElement = XMLElement(name: "event")
        let clipElement = XMLElement(name: "clip")
        let audioElement = XMLElement(name: "audio")
        
        let elements = [eventElement, clipElement, audioElement]
        
        // Test filtering
        let filtered = await utility.filter(fcpxElements: elements, ofTypes: [.event, .clip])
        XCTAssertEqual(filtered.count, 2)
        XCTAssertTrue(filtered.contains { $0.name == "event" })
        XCTAssertTrue(filtered.contains { $0.name == "clip" })
    }
    
    func testCMTimeFromTimecode() async throws {
        let utility = FCPXMLUtility()
        
        // Test 24fps timecode conversion
        let frameDuration = CMTime(value: 1, timescale: 24)
        let cmTime = utility.CMTimeFrom(
            timecodeHours: 1,
            timecodeMinutes: 30,
            timecodeSeconds: 15,
            timecodeFrames: 12,
            frameDuration: frameDuration
        )
        
        // 1:30:15:12 at 24fps should be 5415.5 seconds (actual calculation)
        XCTAssertEqual(cmTime.seconds, 5415.5, accuracy: 0.1)
    }
    
    func testCMTimeFromFCPXMLTime() async throws {
        let utility = FCPXMLUtility()
        
        // Test FCPXML time string conversion
        let cmTime = utility.CMTime(fromFCPXMLTime: "1500/30000s")
        XCTAssertEqual(cmTime.value, 1500)
        XCTAssertEqual(cmTime.timescale, 30000)
    }
    
    func testFCPXMLTimeFromCMTime() async throws {
        let utility = FCPXMLUtility()
        
        let cmTime = CMTime(value: 1500, timescale: 30000)
        let fcpxmlTime = utility.fcpxmlTime(fromCMTime: cmTime)
        XCTAssertEqual(fcpxmlTime, "1500/30000s")
    }
    
    func testConformTimeToFrameDuration() async throws {
        let utility = FCPXMLUtility()
        
        let time = CMTime(value: 1501, timescale: 30000) // 0.050033... seconds
        let frameDuration = CMTime(value: 1, timescale: 24) // 24fps
        
        let conformed = utility.conform(time: time, toFrameDuration: frameDuration)
        
        // Should be rounded down to nearest frame boundary (0.041666...)
        XCTAssertEqual(conformed.seconds, 0.041666666666666664, accuracy: 0.0001)
    }
    
    func testTimecodeKitIntegration() async throws {
        let utility = FCPXMLUtility()
        
        // Test CMTime to Timecode conversion
        let cmTime = CMTime(value: 3600, timescale: 1) // 1 hour
        let timecode = utility.timecode(from: cmTime, frameRate: ._24)
        XCTAssertNotNil(timecode)
        XCTAssertEqual(timecode?.stringValue, "01:00:00:00")
        
        // Test Timecode to CMTime conversion
        let newTimecode = try Timecode(realTime: 7200, at: ._24) // 2 hours
        let newCMTime = utility.cmTime(from: newTimecode)
        XCTAssertEqual(newCMTime.seconds, 7200, accuracy: 0.1)
    }
    
    // MARK: - XMLDocument Extension Tests
    
    func testXMLDocumentFCPXMLInitialization() throws {
        let resources: [XMLElement] = []
        let events: [XMLElement] = []
        let document = XMLDocument(resources: resources, events: events, fcpxmlVersion: "1.8")
        
        XCTAssertNotNil(document)
        XCTAssertEqual(document.fcpxmlVersion, "1.8")
        XCTAssertNotNil(document.fcpxmlElement)
    }
    
    func testXMLDocumentFCPXMLString() throws {
        guard let document = testFCPXMLDocument else {
            XCTFail("testFCPXMLDocument is nil")
            return
        }
        let fcpxmlString = document.fcpxmlString
        
        XCTAssertFalse(fcpxmlString.isEmpty)
        XCTAssertTrue(fcpxmlString.contains("<fcpxml"))
        XCTAssertTrue(fcpxmlString.contains("version=\"1.8\""))
    }
    
    func testXMLDocumentFCPXMLElement() throws {
        guard let document = testFCPXMLDocument else {
            XCTFail("testFCPXMLDocument is nil")
            return
        }
        let fcpxmlElement = document.fcpxmlElement
        
        XCTAssertNotNil(fcpxmlElement)
        XCTAssertEqual(fcpxmlElement?.name, "fcpxml")
    }
    
    func testXMLDocumentFCPXResources() throws {
        guard let document = testFCPXMLDocument else {
            XCTFail("testFCPXMLDocument is nil")
            return
        }
        let resources = document.fcpxResources
        
        XCTAssertNotNil(resources)
        XCTAssertTrue(resources.isEmpty) // Should be empty for our test document
    }
    
    func testXMLDocumentFCPXEvents() throws {
        guard let document = testFCPXMLDocument else {
            XCTFail("testFCPXMLDocument is nil")
            return
        }
        let events = document.fcpxEvents
        
        XCTAssertNotNil(events)
        XCTAssertTrue(events.isEmpty) // Should be empty for our test document
    }
    
    func testXMLDocumentFCPXEventNames() throws {
        guard let document = testFCPXMLDocument else {
            XCTFail("testFCPXMLDocument is nil")
            return
        }
        let eventNames = document.fcpxEventNames
        
        XCTAssertNotNil(eventNames)
        XCTAssertTrue(eventNames.isEmpty) // Should be empty for our test document
    }
    
    func testXMLDocumentResourceMatching() throws {
        guard let document = testFCPXMLDocument else {
            XCTFail("testFCPXMLDocument is nil")
            return
        }
        // Test with empty resources
        let resource = document.resource(matchingID: "r1")
        XCTAssertNil(resource)
    }
    
    func testXMLDocumentParseFCPXML() throws {
        guard let document = testFCPXMLDocument else {
            XCTFail("testFCPXMLDocument is nil")
            return
        }
        // Should not throw
        document.parseFCPXML()
        
        // Test that parsing methods return expected values for empty document
        XCTAssertEqual(document.fcpxLastResourceID(), 0)
        XCTAssertEqual(document.fcpxLastTextStyleID(), 0)
        XCTAssertTrue(document.fcpxAllRoles().isEmpty)
    }
    
    // MARK: - XMLElement Extension Tests
    
    func testXMLElementFCPXEventCreation() throws {
        let element = XMLElement()
        let event = element.fcpxEvent(name: "Test Event")
        
        XCTAssertEqual(event.name, "event")
        XCTAssertEqual(event.fcpxName, "Test Event")
    }
    
    func testXMLElementFCPXProjectCreation() throws {
        let element = XMLElement()
        let formatRef = "r1"
        let duration = CMTime(value: 3600, timescale: 1) // 1 hour
        let tcStart = CMTime(value: 0, timescale: 1)
        let clips: [XMLElement] = []
        
        let project = element.fcpxProject(
            name: "Test Project",
            formatRef: formatRef,
            duration: duration,
            tcStart: tcStart,
            tcFormat: .nonDropFrame,
            audioLayout: .stereo,
            audioRate: .rate48kHz,
            renderColorSpace: .rec709,
            clips: clips
        )
        
        XCTAssertEqual(project.name, "project")
        XCTAssertEqual(project.fcpxName, "Test Project")
        
        // Check sequence
        let sequence = project.elements(forName: "sequence").first
        XCTAssertNotNil(sequence)
        XCTAssertEqual(sequence?.fcpxFormatRef, formatRef)
        XCTAssertEqual(sequence?.fcpxDuration, duration)
        XCTAssertEqual(sequence?.fcpxTCStart, tcStart)
    }
    
    func testXMLElementFCPXCompoundClipCreation() throws {
        let element = XMLElement()
        let ref = "r1"
        let offset = CMTime(value: 0, timescale: 1)
        let duration = CMTime(value: 300, timescale: 1) // 5 minutes
        let start = CMTime(value: 0, timescale: 1)
        
        let compoundClip = element.fcpxCompoundClip(
            name: "Test Compound Clip",
            ref: ref,
            offset: offset,
            duration: duration,
            start: start,
            useAudioSubroles: true
        )
        
        XCTAssertEqual(compoundClip.name, "ref-clip")
        XCTAssertEqual(compoundClip.fcpxName, "Test Compound Clip")
        XCTAssertEqual(compoundClip.fcpxRef, ref)
        XCTAssertEqual(compoundClip.fcpxOffset, offset)
        XCTAssertEqual(compoundClip.fcpxDuration, duration)
        XCTAssertEqual(compoundClip.fcpxStart, start)
    }
    
    func testXMLElementFCPXMulticamResourceCreation() throws {
        let element = XMLElement()
        let id = "r1"
        let formatRef = "r2"
        let tcStart = CMTime(value: 0, timescale: 1)
        let angles: [XMLElement] = []
        
        let multicamResource = element.fcpxMulticamResource(
            name: "Test Multicam",
            id: id,
            formatRef: formatRef,
            tcStart: tcStart,
            tcFormat: .nonDropFrame,
            renderColorSpace: .rec709,
            angles: angles
        )
        
        XCTAssertEqual(multicamResource.name, "media")
        XCTAssertEqual(multicamResource.fcpxName, "Test Multicam")
        XCTAssertEqual(multicamResource.fcpxID, id)
        
        // Check multicam element
        let multicam = multicamResource.elements(forName: "multicam").first
        XCTAssertNotNil(multicam)
        XCTAssertEqual(multicam?.fcpxFormatRef, formatRef)
        XCTAssertEqual(multicam?.fcpxTCStart, tcStart)
    }
    
    func testXMLElementFCPXMulticamClipCreation() throws {
        let element = XMLElement()
        let refID = "r1"
        let offset = CMTime(value: 0, timescale: 1)
        let start = CMTime(value: 0, timescale: 1)
        let duration = CMTime(value: 300, timescale: 1) // 5 minutes
        let mcSources: [XMLElement] = []
        
        let multicamClip = element.fcpxMulticamClip(
            name: "Test Multicam Clip",
            refID: refID,
            offset: offset,
            start: start,
            duration: duration,
            mcSources: mcSources
        )
        
        XCTAssertEqual(multicamClip.name, "mc-clip")
        XCTAssertEqual(multicamClip.fcpxName, "Test Multicam Clip")
        XCTAssertEqual(multicamClip.fcpxRef, refID)
        XCTAssertEqual(multicamClip.fcpxOffset, offset)
        XCTAssertEqual(multicamClip.fcpxStart, start)
        XCTAssertEqual(multicamClip.fcpxDuration, duration)
    }
    
    func testXMLElementFCPXSecondaryStorylineCreation() throws {
        let element = XMLElement()
        let lane = 1
        let offset = CMTime(value: 0, timescale: 1)
        let formatRef = "r1"
        let clips: [XMLElement] = []
        
        let secondaryStoryline = element.fcpxSecondaryStoryline(
            lane: lane,
            offset: offset,
            formatRef: formatRef,
            clips: clips
        )
        
        XCTAssertEqual(secondaryStoryline.name, "spine")
        XCTAssertEqual(secondaryStoryline.fcpxLane, lane)
        XCTAssertEqual(secondaryStoryline.fcpxOffset, offset)
        XCTAssertEqual(secondaryStoryline.fcpxFormatRef, formatRef)
    }
    
    // MARK: - CMTime Extension Tests
    
    func testCMTimeFCPXMLString() throws {
        let cmTime = CMTime(value: 1500, timescale: 30000)
        let fcpxmlString = cmTime.fcpxmlString
        XCTAssertEqual(fcpxmlString, "1500/30000s")
        
        let zeroTime = CMTime(value: 0, timescale: 1)
        let zeroString = zeroTime.fcpxmlString
        XCTAssertEqual(zeroString, "0s")
    }
    
    func testCMTimeZero() throws {
        let zeroTime = CMTime().zero()
        XCTAssertEqual(zeroTime.value, 0)
        XCTAssertEqual(zeroTime.timescale, 1000)
    }
    
    func testCMTimeTimeAsCounter() throws {
        let cmTime = CMTime(value: 3661, timescale: 1) // 1:01:01
        let counter = cmTime.timeAsCounter()
        
        XCTAssertEqual(counter.hours, 1)
        XCTAssertEqual(counter.minutes, 1)
        XCTAssertEqual(counter.seconds, 1)
        XCTAssertEqual(counter.counterString, "01:01:01,0000")
    }
    
    func testCMTimeTimeAsTimecode() throws {
        let cmTime = CMTime(value: 3600, timescale: 1) // 1 hour
        let frameDuration = CMTime(value: 1, timescale: 24) // 24fps
        
        let timecode = cmTime.timeAsTimecode(usingFrameDuration: frameDuration, dropFrame: false)
        
        XCTAssertEqual(timecode.hours, 1)
        XCTAssertEqual(timecode.minutes, 0)
        XCTAssertEqual(timecode.seconds, 0)
        XCTAssertEqual(timecode.frames, 0)
        XCTAssertEqual(timecode.timecodeString, "01:00:00:00")
    }
    
    func testAllFCPXMLSupportedFrameRates() throws {
        let utility = FCPXMLUtility()
        let oneHourSeconds: Double = 3600
        let supportedRates: [TimecodeFrameRate] = [
            ._23_976, ._24, ._25, ._29_97, ._29_97_drop, ._30, ._30_drop,
            ._47_952, ._48, ._50, ._59_94, ._59_94_drop, ._60, ._60_drop,
            ._100, ._119_88, ._119_88_drop, ._120, ._120_drop
        ]
        for rate in supportedRates {
            // Convert 1 hour to Timecode
            let cmTime = CMTime(seconds: oneHourSeconds, preferredTimescale: 60000)
            guard let timecode = utility.timecode(from: cmTime, frameRate: rate) else {
                XCTFail("Failed to convert CMTime to Timecode for frame rate: \(rate)")
                continue
            }
            // Check string formatting
            XCTAssertFalse(timecode.stringValue.isEmpty, "Timecode string is empty for frame rate: \(rate)")
            // Convert back to CMTime
            let backCMTime = utility.cmTime(from: timecode)
            XCTAssertEqual(backCMTime.seconds, oneHourSeconds, accuracy: 0.1, "CMTime round-trip failed for frame rate: \(rate)")
        }
    }
    
    // MARK: - Performance Tests
    
    func testPerformanceFCPXMLParsing() throws {
        guard let document = testFCPXMLDocument else {
            XCTFail("testFCPXMLDocument is nil")
            return
        }
        
        measure {
            document.parseFCPXML()
        }
    }
    
    func testPerformanceTimeConversion() async throws {
        let utility = FCPXMLUtility()
        let frameDuration = CMTime(value: 1, timescale: 24)
        
        measure {
            for _ in 0..<1000 {
                _ = utility.CMTimeFrom(
                    timecodeHours: 1,
                    timecodeMinutes: 30,
                    timecodeSeconds: 15,
                    timecodeFrames: 12,
                    frameDuration: frameDuration
                )
            }
        }
    }
    
    // MARK: - Error Handling Tests
    
    func testInvalidFCPXMLTimeString() async throws {
        let utility = FCPXMLUtility()
        
        // Test with invalid time string
        let invalidTime = "invalid"
        let cmTime = utility.CMTime(fromFCPXMLTime: invalidTime)
        
        // Should handle gracefully and return a valid CMTime
        XCTAssertNotNil(cmTime)
    }
    
    func testEmptyFCPXMLDocument() throws {
        let resources: [XMLElement] = []
        let events: [XMLElement] = []
        let document = XMLDocument(resources: resources, events: events, fcpxmlVersion: "1.8")
        
        // Should handle empty document gracefully
        XCTAssertTrue(document.fcpxResources.isEmpty)
        XCTAssertTrue(document.fcpxEvents.isEmpty)
        XCTAssertTrue(document.fcpxEventNames.isEmpty)
        XCTAssertEqual(document.fcpxLastResourceID(), 0)
        XCTAssertEqual(document.fcpxLastTextStyleID(), 0)
    }
    
    // MARK: - Concurrency Tests
    
    func testConcurrentFCPXMLUtilityAccess() async throws {
        // Test concurrent access to utility methods
        await withTaskGroup(of: Void.self) { group in
            for _ in 0..<10 {
                group.addTask {
                    let utility = FCPXMLUtility()
                    let frameDuration = CMTime(value: 1, timescale: 24)
                    _ = await utility.CMTimeFrom(
                        timecodeHours: 1,
                        timecodeMinutes: 30,
                        timecodeSeconds: 15,
                        timecodeFrames: 12,
                        frameDuration: frameDuration
                    )
                }
            }
        }
    }
    
    func testConcurrentDocumentAccess() async throws {
        // Test concurrent access to document properties
        await withTaskGroup(of: Void.self) { group in
            for _ in 0..<10 {
                group.addTask {
                    let resources: [XMLElement] = []
                    let events: [XMLElement] = []
                    let document = XMLDocument(resources: resources, events: events, fcpxmlVersion: "1.8")
                    _ = document.fcpxmlString
                    _ = document.fcpxmlElement
                    _ = document.fcpxResources
                    _ = document.fcpxEvents
                }
            }
        }
    }
    
    // MARK: - Linux Test Support
    
    #if !canImport(ObjectiveC)
    static var allTests = [
        ("testFCPXMLElementTypeCases", testFCPXMLElementTypeCases),
        ("testFCPXMLElementTypeRawValues", testFCPXMLElementTypeRawValues),
        ("testFCPXMLUtilityInitialization", testFCPXMLUtilityInitialization),
        ("testFilterFCPXElements", testFilterFCPXElements),
        ("testCMTimeFromTimecode", testCMTimeFromTimecode),
        ("testCMTimeFromFCPXMLTime", testCMTimeFromFCPXMLTime),
        ("testFCPXMLTimeFromCMTime", testFCPXMLTimeFromCMTime),
        ("testConformTimeToFrameDuration", testConformTimeToFrameDuration),
        ("testTimecodeKitIntegration", testTimecodeKitIntegration),
        ("testXMLDocumentFCPXMLInitialization", testXMLDocumentFCPXMLInitialization),
        ("testXMLDocumentFCPXMLString", testXMLDocumentFCPXMLString),
        ("testXMLDocumentFCPXMLElement", testXMLDocumentFCPXMLElement),
        ("testXMLDocumentFCPXResources", testXMLDocumentFCPXResources),
        ("testXMLDocumentFCPXEvents", testXMLDocumentFCPXEvents),
        ("testXMLDocumentFCPXEventNames", testXMLDocumentFCPXEventNames),
        ("testXMLDocumentResourceMatching", testXMLDocumentResourceMatching),
        ("testXMLDocumentParseFCPXML", testXMLDocumentParseFCPXML),
        ("testXMLElementFCPXEventCreation", testXMLElementFCPXEventCreation),
        ("testXMLElementFCPXProjectCreation", testXMLElementFCPXProjectCreation),
        ("testXMLElementFCPXCompoundClipCreation", testXMLElementFCPXCompoundClipCreation),
        ("testXMLElementFCPXMulticamResourceCreation", testXMLElementFCPXMulticamResourceCreation),
        ("testXMLElementFCPXMulticamClipCreation", testXMLElementFCPXMulticamClipCreation),
        ("testXMLElementFCPXSecondaryStorylineCreation", testXMLElementFCPXSecondaryStorylineCreation),
        ("testCMTimeFCPXMLString", testCMTimeFCPXMLString),
        ("testCMTimeZero", testCMTimeZero),
        ("testCMTimeTimeAsCounter", testCMTimeTimeAsCounter),
        ("testCMTimeTimeAsTimecode", testCMTimeTimeAsTimecode),
        ("testAllFCPXMLSupportedFrameRates", testAllFCPXMLSupportedFrameRates),
        ("testPerformanceFCPXMLParsing", testPerformanceFCPXMLParsing),
        ("testPerformanceTimeConversion", testPerformanceTimeConversion),
        ("testInvalidFCPXMLTimeString", testInvalidFCPXMLTimeString),
        ("testEmptyFCPXMLDocument", testEmptyFCPXMLDocument),
        ("testConcurrentFCPXMLUtilityAccess", testConcurrentFCPXMLUtilityAccess),
        ("testConcurrentDocumentAccess", testConcurrentDocumentAccess),
    ]
    #endif
} 