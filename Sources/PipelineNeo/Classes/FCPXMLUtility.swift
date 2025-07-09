//
//  FCPXMLUtility.swift
//  Pipeline Neo • https://github.com/TheAcharya/pipeline-neo
//  © 2025 • Licensed under MIT License
//

import Foundation
import CoreMedia
import TimecodeKit

#if canImport(Logging)
import Logging
#endif

/// Contains utility methods for processing FCPXML data.
///
/// This struct provides a collection of static methods for common FCPXML operations
/// including filtering, time conversion, and document manipulation.
public struct FCPXMLUtility: Sendable {
    // MARK: - Initialization
    public init() {}
    // MARK: - Element Filtering
    public static func filter(
        fcpxElements elements: [XMLElement],
        ofTypes types: [FCPXMLElementType]
    ) -> [XMLElement] {
        elements.filter { element in
            types.contains(element.fcpxType)
        }
    }
    public static func filter(
        fcpxElements elements: [XMLElement],
        ofType type: FCPXMLElementType
    ) -> [XMLElement] {
        elements.filter { $0.fcpxType == type }
    }
    // MARK: - Time Conversion Methods
    /// Creates a CMTime value that represents real time from timecode values using TimecodeKit.
    public static func cmTimeFrom(
        timecodeHours: Int,
        timecodeMinutes: Int,
        timecodeSeconds: Int,
        timecodeFrames: Int,
        frameDuration: CMTime
    ) -> CMTime {
        let frameRate = TimecodeFrameRate(frameDuration: frameDuration, drop: false) ?? .fps30
        let tc = try! Timecode(
            .components(
                h: timecodeHours,
                m: timecodeMinutes,
                s: timecodeSeconds,
                f: timecodeFrames
            ),
            at: frameRate
        )
        return tc.cmTimeValue
    }
    /// Converts an FCPXML time value to a CMTime value.
    public static func cmTime(fromFCPXMLTime timeString: String) throws -> CMTime {
        let components = timeString.components(separatedBy: "/")
        guard !components.isEmpty else {
            throw FCPXMLError.invalidTimeFormat(timeString)
        }
        if components.count > 1 {
            guard let valueString = components.first,
                  let timescaleString = components.last?.dropLast(),
                  let value = Int64(valueString),
                  let timescale = Int32(String(timescaleString)) else {
                throw FCPXMLError.invalidTimeFormat(timeString)
            }
            return CMTime(value: value, timescale: timescale)
        } else {
            guard let valueString = components.first?.dropLast(),
                  let value = Int64(String(valueString)) else {
                throw FCPXMLError.invalidTimeFormat(timeString)
            }
            return CMTime(value: value, timescale: 1)
        }
    }
    /// Converts a CMTime value to an FCPXML time value.
    public static func fcpxmlTime(fromCMTime time: CMTime) -> String {
        time.fcpxmlString
    }
    /// Conforms a given CMTime value to the frameDuration so that the value falls on an edit frame boundary using TimecodeKit.
    public static func conform(time: CMTime, toFrameDuration frameDuration: CMTime) -> CMTime {
        let frameRate = TimecodeFrameRate(frameDuration: frameDuration, drop: false) ?? .fps30
        let tc = try! Timecode(.cmTime(time), at: frameRate)
        return tc.cmTimeValue
    }
    // MARK: - Sequence Time Conversion
    public static func sequenceTimecode(
        fromCounterValue counterValue: CMTime,
        inSequence sequence: XMLElement
    ) -> CMTime? {
        guard let sequenceTCStart = sequence.fcpxTCStart else {
            return nil
        }
        return CMTimeAdd(sequenceTCStart, counterValue)
    }
    public static func sequenceCounterTime(
        fromTimecodeValue timecodeValue: CMTime,
        inSequence sequence: XMLElement
    ) -> CMTime? {
        guard let sequenceTCStart = sequence.fcpxTCStart else {
            return nil
        }
        return CMTimeSubtract(timecodeValue, sequenceTCStart)
    }
    // MARK: - Deprecated Methods
    @available(*, deprecated, message: "Use sequenceTimecode(fromCounterValue:inSequence:) instead.")
    public static func projectTimecode(
        fromCounterValue counterValue: CMTime,
        inProject project: XMLElement
    ) -> CMTime? {
        guard let projectSequence = project.fcpxProjectSequence else {
            return nil
        }
        return sequenceTimecode(fromCounterValue: counterValue, inSequence: projectSequence)
    }
    @available(*, deprecated, message: "Use sequenceCounterTime(fromTimecodeValue:inSequence:) instead.")
    public static func projectCounterTime(
        fromTimecodeValue timecodeValue: CMTime,
        inProject project: XMLElement
    ) -> CMTime? {
        guard let projectSequence = project.fcpxProjectSequence else {
            return nil
        }
        return sequenceCounterTime(fromTimecodeValue: timecodeValue, inSequence: projectSequence)
    }
}

// MARK: - Async Support

extension FCPXMLUtility {
    
    /// Asynchronously filters elements that match specified FCPXML element types.
    ///
    /// - Parameters:
    ///   - elements: An array of XMLElement objects
    ///   - types: An array of FCPXMLElementType enumeration values
    /// - Returns: A filtered array of XMLElement objects
    @available(macOS 10.15, *)
    public static func filterAsync(
        fcpxElements elements: [XMLElement],
        ofTypes types: [FCPXMLElementType]
    ) async -> [XMLElement] {
        // Note: This is a synchronous operation wrapped in async for future extensibility
        // XMLElement is not Sendable, so we perform the operation directly
        filter(fcpxElements: elements, ofTypes: types)
    }
    
    /// Asynchronously converts an FCPXML time value to a CMTime value.
    ///
    /// - Parameter timeString: The FCPXML time value as a string.
    /// - Returns: The equivalent CMTime value.
    /// - Throws: `FCPXMLError.invalidTimeFormat` if the time string format is invalid.
    @available(macOS 10.15, *)
    public static func cmTimeAsync(fromFCPXMLTime timeString: String) async throws -> CMTime {
        // Note: This is a synchronous operation wrapped in async for future extensibility
        try cmTime(fromFCPXMLTime: timeString)
    }
}
