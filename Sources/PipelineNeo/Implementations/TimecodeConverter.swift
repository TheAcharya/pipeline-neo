//
//  TimecodeConverter.swift
//  Pipeline Neo • https://github.com/TheAcharya/pipeline-neo
//  © 2025 • Licensed under MIT License
//

import Foundation
import CoreMedia
import TimecodeKit

/// Implementation of timecode conversion operations
@available(macOS 12.0, *)
public final class TimecodeConverter: TimecodeConversion, FCPXMLTimeStringConversion, TimeConforming, Sendable {
    
    public init() {}
    
    // MARK: - TimecodeConversion Implementation
    
    public func timecode(from time: CMTime, frameRate: TimecodeFrameRate) -> Timecode? {
        let seconds = CMTimeGetSeconds(time)
        do {
            return try Timecode(realTime: seconds, at: frameRate)
        } catch {
            return nil
        }
    }
    
    public func cmTime(from timecode: Timecode) -> CMTime {
        let seconds = timecode.realTimeValue
        return CMTime(seconds: seconds, preferredTimescale: 600)
    }
    
    public func cmTimeFrom(timecodeHours: Int, timecodeMinutes: Int, timecodeSeconds: Int, timecodeFrames: Int, frameDuration: CMTime) -> CMTime {
        let totalSeconds = Double(timecodeHours * 3600 + timecodeMinutes * 60 + timecodeSeconds)
        let frameTime = CMTimeMultiply(frameDuration, multiplier: Int32(timecodeFrames))
        return CMTime(seconds: totalSeconds, preferredTimescale: 600) + frameTime
    }
    
    // MARK: - FCPXMLTimeStringConversion Implementation
    
    public func cmTime(fromFCPXMLTime timeString: String) -> CMTime {
        let components = timeString.components(separatedBy: "/")
        guard components.count == 2,
              let numerator = Int64(components[0]),
              let denominator = Int32(components[1]) else {
            return CMTime.zero
        }
        return CMTime(value: numerator, timescale: denominator)
    }
    
    public func fcpxmlTime(fromCMTime time: CMTime) -> String {
        return "\(time.value)/\(time.timescale)"
    }
    
    // MARK: - TimeConforming Implementation
    
    public func conform(time: CMTime, toFrameDuration frameDuration: CMTime) -> CMTime {
        let frameCount = CMTimeGetSeconds(time) / CMTimeGetSeconds(frameDuration)
        let roundedFrames = round(frameCount)
        return CMTimeMultiply(frameDuration, multiplier: Int32(roundedFrames))
    }
} 