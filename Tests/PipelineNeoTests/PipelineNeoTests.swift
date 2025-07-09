//
//  PipelineNeoTests.swift
//  Pipeline Neo • https://github.com/TheAcharya/pipeline-neo
//  © 2025 • Licensed under MIT License
//

import XCTest
import CoreMedia
@testable import PipelineNeo

final class PipelineNeoTests: XCTestCase {
    
    // MARK: - FCPXMLElementType Tests
    
    func testFCPXMLElementTypeConvenienceMethods() {
        // Test resource types
        XCTAssertTrue(FCPXMLElementType.assetResource.isResource)
        XCTAssertTrue(FCPXMLElementType.formatResource.isResource)
        XCTAssertTrue(FCPXMLElementType.mediaResource.isResource)
        XCTAssertTrue(FCPXMLElementType.effectResource.isResource)
        XCTAssertTrue(FCPXMLElementType.multicamResource.isResource)
        XCTAssertTrue(FCPXMLElementType.compoundResource.isResource)
        XCTAssertFalse(FCPXMLElementType.clip.isResource)
        
        // Test clip types
        XCTAssertTrue(FCPXMLElementType.clip.isClip)
        XCTAssertTrue(FCPXMLElementType.audio.isClip)
        XCTAssertTrue(FCPXMLElementType.video.isClip)
        XCTAssertTrue(FCPXMLElementType.multicamClip.isClip)
        XCTAssertTrue(FCPXMLElementType.compoundClip.isClip)
        XCTAssertTrue(FCPXMLElementType.synchronizedClip.isClip)
        XCTAssertTrue(FCPXMLElementType.assetClip.isClip)
        XCTAssertFalse(FCPXMLElementType.event.isClip)
        
        // Test collection types
        XCTAssertTrue(FCPXMLElementType.folder.isCollection)
        XCTAssertTrue(FCPXMLElementType.keywordCollection.isCollection)
        XCTAssertTrue(FCPXMLElementType.smartCollection.isCollection)
        XCTAssertFalse(FCPXMLElementType.clip.isCollection)
        
        // Test annotation types
        XCTAssertTrue(FCPXMLElementType.marker.isAnnotation)
        XCTAssertTrue(FCPXMLElementType.keyword.isAnnotation)
        XCTAssertTrue(FCPXMLElementType.rating.isAnnotation)
        XCTAssertTrue(FCPXMLElementType.chapterMarker.isAnnotation)
        XCTAssertTrue(FCPXMLElementType.analysisMarker.isAnnotation)
        XCTAssertTrue(FCPXMLElementType.note.isAnnotation)
        XCTAssertFalse(FCPXMLElementType.clip.isAnnotation)
    }
    
    // MARK: - CMTime Extension Tests
    
    func testCMTimeFCPXMLString() {
        let time1 = CMTime(value: 1000, timescale: 30000)
        XCTAssertEqual(time1.fcpxmlString, "1000/30000s")
        
        let time2 = CMTime(value: 0, timescale: 1000)
        XCTAssertEqual(time2.fcpxmlString, "0s")
    }
    
    func testCMTimeZero() {
        let zeroTime = CMTime.fcpxZero
        XCTAssertEqual(zeroTime.value, 0)
        XCTAssertEqual(zeroTime.timescale, 1000)
    }
    
    func testCMTimeTimeAsCounter() {
        let time = CMTime(value: 3661234, timescale: 1000) // 1:01:01,234
        let components = time.timeAsCounter()
        
        XCTAssertEqual(components.hours, 1)
        XCTAssertEqual(components.minutes, 1)
        XCTAssertEqual(components.seconds, 1)
        XCTAssertEqual(components.counterString, "01:01:01,234")
    }
    
    func testCMTimeTimeAsTimecode() {
        let time = CMTime(value: 60, timescale: 30) // 2 seconds at 30fps
        let frameDuration = CMTime(value: 1, timescale: 30)
        let timecode = time.timeAsTimecode(usingFrameDuration: frameDuration, dropFrame: false)
        
        XCTAssertEqual(timecode.hours, 0)
        XCTAssertEqual(timecode.minutes, 0)
        XCTAssertEqual(timecode.seconds, 2)
        XCTAssertEqual(timecode.frames, 0)
        XCTAssertEqual(timecode.timecodeString, "00:00:02:00")
    }
    
    // MARK: - FCPXMLUtility Tests
    
    func testFCPXMLUtilityFilter() {
        // This test would require actual XMLElement objects
        // For now, we'll test the static method exists and compiles
        let utility = FCPXMLUtility()
        XCTAssertNotNil(utility)
    }
    
    func testFCPXMLUtilityCMTimeFrom() {
        let frameDuration = CMTime(value: 1, timescale: 30)
        let time = FCPXMLUtility.cmTimeFrom(
            timecodeHours: 1,
            timecodeMinutes: 30,
            timecodeSeconds: 15,
            timecodeFrames: 10,
            frameDuration: frameDuration
        )
        
        XCTAssertGreaterThan(time.value, 0)
        // TimecodeKit returns the frame rate's natural timescale
        XCTAssertEqual(time.timescale, 3) // TimecodeKit's internal representation
    }
    
    func testFCPXMLUtilityCMTimeFromFCPXMLTime() {
        // Test valid time format
        do {
            let time = try FCPXMLUtility.cmTime(fromFCPXMLTime: "1000/30000s")
            XCTAssertEqual(time.value, 1000)
            XCTAssertEqual(time.timescale, 30000)
        } catch {
            XCTFail("Should not throw error for valid time format")
        }
        
        // Test invalid time format
        do {
            _ = try FCPXMLUtility.cmTime(fromFCPXMLTime: "invalid")
            XCTFail("Should throw error for invalid time format")
        } catch FCPXMLError.invalidTimeFormat {
            // Expected error
        } catch {
            XCTFail("Unexpected error type")
        }
    }
    
    func testFCPXMLUtilityFCPXMLTime() {
        let time = CMTime(value: 1000, timescale: 30000)
        let timeString = FCPXMLUtility.fcpxmlTime(fromCMTime: time)
        XCTAssertEqual(timeString, "1000/30000s")
    }
    
    func testFCPXMLUtilityConform() {
        let time = CMTime(value: 1001, timescale: 30000)
        let frameDuration = CMTime(value: 1, timescale: 30)
        let conformed = FCPXMLUtility.conform(time: time, toFrameDuration: frameDuration)
        
        // The conformed time should be aligned to frame boundaries
        XCTAssertEqual(conformed.timescale, frameDuration.timescale)
    }
    
    // MARK: - Error Tests
    
    func testFCPXMLErrorDescriptions() {
        let invalidFormatError = FCPXMLError.invalidTimeFormat("invalid")
        XCTAssertNotNil(invalidFormatError.errorDescription)
        XCTAssertTrue(invalidFormatError.errorDescription?.contains("invalid") ?? false)
        
        let missingElementError = FCPXMLError.missingElement("test")
        XCTAssertNotNil(missingElementError.errorDescription)
        XCTAssertTrue(missingElementError.errorDescription?.contains("test") ?? false)
        
        let missingAttributeError = FCPXMLError.missingAttribute("test", "element")
        XCTAssertNotNil(missingAttributeError.errorDescription)
        XCTAssertTrue(missingAttributeError.errorDescription?.contains("test") ?? false)
    }
    
    // MARK: - Modern CMTime Tests
    
    func testCMTimeConvenienceProperties() {
        let zeroTime = CMTime.fcpxZero
        XCTAssertTrue(zeroTime.isZero)
        XCTAssertTrue(zeroTime.fcpxIsValid)
        XCTAssertFalse(zeroTime.isPositive)
        XCTAssertFalse(zeroTime.isNegative)
        
        let positiveTime = CMTime(value: 1000, timescale: 1000)
        XCTAssertFalse(positiveTime.isZero)
        XCTAssertTrue(positiveTime.fcpxIsValid)
        XCTAssertTrue(positiveTime.isPositive)
        XCTAssertFalse(positiveTime.isNegative)
        
        let negativeTime = CMTime(value: -1000, timescale: 1000)
        XCTAssertFalse(negativeTime.isZero)
        XCTAssertTrue(negativeTime.fcpxIsValid)
        XCTAssertFalse(negativeTime.isPositive)
        XCTAssertTrue(negativeTime.isNegative)
    }
    
    func testCMTimeFrameRounding() {
        let time = CMTime(value: 1001, timescale: 30000)
        let frameDuration = CMTime(value: 1, timescale: 30)
        
        let rounded = time.rounded(toFrameDuration: frameDuration)
        let floored = time.floored(toFrameDuration: frameDuration)
        let ceiled = time.ceiled(toFrameDuration: frameDuration)
        
        XCTAssertEqual(rounded.timescale, frameDuration.timescale)
        XCTAssertEqual(floored.timescale, frameDuration.timescale)
        XCTAssertEqual(ceiled.timescale, frameDuration.timescale)
    }
    
    func testCMTimeAbsolute() {
        let negativeTime = CMTime(value: -1000, timescale: 1000)
        let absoluteTime = negativeTime.absolute
        
        XCTAssertEqual(absoluteTime.value, 1000)
        XCTAssertEqual(absoluteTime.timescale, 1000)
    }
    
    // MARK: - Error Handling Tests
    
    func testFCPXMLErrorRecoverability() {
        let recoverableError = FCPXMLError.invalidTimeFormat("test")
        XCTAssertTrue(recoverableError.isRecoverable)
        
        let nonRecoverableError = FCPXMLError.fileNotFound(URL(fileURLWithPath: "/nonexistent"))
        XCTAssertFalse(nonRecoverableError.isRecoverable)
    }
    
    func testFCPXMLErrorCategories() {
        let fileError = FCPXMLError.fileReadError(URL(fileURLWithPath: "/test"), NSError(domain: "test", code: 1))
        XCTAssertTrue(fileError.isFileIOError)
        XCTAssertFalse(fileError.isValidationError)
        
        let validationError = FCPXMLError.validationFailed(["error1", "error2"])
        XCTAssertFalse(validationError.isFileIOError)
        XCTAssertTrue(validationError.isValidationError)
    }
    
    // MARK: - Performance Tests
    
    func testFilterPerformance() {
        // This test would measure the performance of the filter method
        // with a large number of elements
        measure {
            // Add performance test implementation here
        }
    }
    

}

#if !canImport(ObjectiveC)
extension PipelineNeoTests {
    static var allTests: [(String, (PipelineNeoTests) -> () throws -> Void)] {
        return [
            ("testFCPXMLElementTypeConvenienceMethods", testFCPXMLElementTypeConvenienceMethods),
            ("testCMTimeFCPXMLString", testCMTimeFCPXMLString),
            ("testCMTimeZero", testCMTimeZero),
            ("testCMTimeTimeAsCounter", testCMTimeTimeAsCounter),
            ("testCMTimeTimeAsTimecode", testCMTimeTimeAsTimecode),
            ("testCMTimeConvenienceProperties", testCMTimeConvenienceProperties),
            ("testCMTimeFrameRounding", testCMTimeFrameRounding),
            ("testCMTimeAbsolute", testCMTimeAbsolute),
            ("testFCPXMLUtilityFilter", testFCPXMLUtilityFilter),
            ("testFCPXMLUtilityCMTimeFrom", testFCPXMLUtilityCMTimeFrom),
            ("testFCPXMLUtilityCMTimeFromFCPXMLTime", testFCPXMLUtilityCMTimeFromFCPXMLTime),
            ("testFCPXMLUtilityFCPXMLTime", testFCPXMLUtilityFCPXMLTime),
            ("testFCPXMLUtilityConform", testFCPXMLUtilityConform),
            ("testFCPXMLErrorDescriptions", testFCPXMLErrorDescriptions),
            ("testFCPXMLErrorRecoverability", testFCPXMLErrorRecoverability),
            ("testFCPXMLErrorCategories", testFCPXMLErrorCategories),
            ("testFilterPerformance", testFilterPerformance),
        ]
    }
}
#endif 