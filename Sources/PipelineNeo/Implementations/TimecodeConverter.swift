//
//  TimecodeConverter.swift
//  Pipeline Neo • https://github.com/TheAcharya/pipeline-neo
//  © 2025 • Licensed under MIT License
//

import Foundation
import CoreMedia
import SwiftTimecode
import SwiftExtensions

/// Implementation of timecode conversion operations
@available(macOS 12.0, *)
public final class TimecodeConverter: TimecodeConversion, FCPXMLTimeStringConversion, TimeConforming, Sendable {
    
    public init() {}
    
    // MARK: - TimecodeConversion Implementation
    
    public func timecode(from time: CMTime, frameRate: TimecodeFrameRate) -> Timecode? {
        let seconds = CMTimeGetSeconds(time)
        do {
            return try Timecode(.realTime(seconds: seconds), at: frameRate)
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
    
    // MARK: - TimecodeConversion Async Implementation
    
    public func timecode(from time: CMTime, frameRate: TimecodeFrameRate) async -> Timecode? {
        // For now, just call the synchronous version
        let seconds = CMTimeGetSeconds(time)
        do {
            return try Timecode(.realTime(seconds: seconds), at: frameRate)
        } catch {
            return nil
        }
    }
    
    public func cmTime(from timecode: Timecode) async -> CMTime {
        // For now, just call the synchronous version
        let seconds = timecode.realTimeValue
        return CMTime(seconds: seconds, preferredTimescale: 600)
    }
    
    public func cmTimeFrom(timecodeHours: Int, timecodeMinutes: Int, timecodeSeconds: Int, timecodeFrames: Int, frameDuration: CMTime) async -> CMTime {
        // For now, just call the synchronous version
        let totalSeconds = Double(timecodeHours * 3600 + timecodeMinutes * 60 + timecodeSeconds)
        let frameTime = CMTimeMultiply(frameDuration, multiplier: Int32(timecodeFrames))
        return CMTime(seconds: totalSeconds, preferredTimescale: 600) + frameTime
    }
    
    // MARK: - FCPXMLTimeStringConversion Implementation
    
    public func cmTime(fromFCPXMLTime timeString: String) -> CMTime {
        let components = timeString.components(separatedBy: "/")
        guard components.count == 2,
              let numerator = components[safe: 0].flatMap({ Int64($0) }),
              let denominator = components[safe: 1].flatMap({ Int32($0) }),
              denominator != 0 else {
            return CMTime.zero
        }
        return CMTime(value: numerator, timescale: denominator)
    }
    
    public func fcpxmlTime(fromCMTime time: CMTime) -> String {
        return "\(time.value)/\(time.timescale)"
    }
    
    // MARK: - FCPXMLTimeStringConversion Async Implementation
    
    public func cmTime(fromFCPXMLTime timeString: String) async -> CMTime {
        let components = timeString.components(separatedBy: "/")
        guard components.count == 2,
              let numerator = components[safe: 0].flatMap({ Int64($0) }),
              let denominator = components[safe: 1].flatMap({ Int32($0) }),
              denominator != 0 else {
            return CMTime.zero
        }
        return CMTime(value: numerator, timescale: denominator)
    }
    
    public func fcpxmlTime(fromCMTime time: CMTime) async -> String {
        // For now, just call the synchronous version
        return "\(time.value)/\(time.timescale)"
    }
    
    // MARK: - TimeConforming Implementation
    
    public func conform(time: CMTime, toFrameDuration frameDuration: CMTime) -> CMTime {
        let frameDurationSeconds = CMTimeGetSeconds(frameDuration)
        guard frameDurationSeconds > 0, frameDurationSeconds.isFinite else {
            return .zero
        }
        let frameCount = CMTimeGetSeconds(time) / frameDurationSeconds
        let roundedFrames = round(frameCount)
        return CMTimeMultiply(frameDuration, multiplier: Int32(roundedFrames))
    }
    
    // MARK: - TimeConforming Async Implementation
    
    public func conform(time: CMTime, toFrameDuration frameDuration: CMTime) async -> CMTime {
        let frameDurationSeconds = CMTimeGetSeconds(frameDuration)
        guard frameDurationSeconds > 0, frameDurationSeconds.isFinite else {
            return .zero
        }
        let frameCount = CMTimeGetSeconds(time) / frameDurationSeconds
        let roundedFrames = round(frameCount)
        return CMTimeMultiply(frameDuration, multiplier: Int32(roundedFrames))
    }
} 