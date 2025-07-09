//
//  CMTimeExtension.swift
//  Pipeline Neo • https://github.com/TheAcharya/pipeline-neo
//  © 2025 • Licensed under MIT License
//

import CoreMedia
import TimecodeKit

// MARK: - CMTime Extension for TimecodeKit Integration

extension CMTime {
    /// FCPXML zero time (0/1000s)
    public static let fcpxZero = CMTime(value: 0, timescale: 1000)
    /// True if the CMTime value is zero
    public var isZero: Bool { value == 0 }
    /// True if the CMTime value is positive
    public var isPositive: Bool { value > 0 }
    /// True if the CMTime value is negative
    public var isNegative: Bool { value < 0 }
    /// Returns the absolute value of the CMTime
    public var absolute: CMTime { CMTime(value: abs(value), timescale: timescale) }
    /// True if the CMTime is valid (not invalid)
    public var fcpxIsValid: Bool { !CMTIME_IS_INVALID(self) }
    public struct CounterComponents {
        public let hours: Int
        public let minutes: Int
        public let seconds: Int
        public let milliseconds: Int
        public var counterString: String {
            String(format: "%02d:%02d:%02d,%03d", hours, minutes, seconds, milliseconds)
        }
    }
    public func timeAsCounter() -> CounterComponents {
        let totalSeconds = self.seconds
        let hours = Int(totalSeconds / 3600)
        let minutes = Int((totalSeconds.truncatingRemainder(dividingBy: 3600)) / 60)
        let seconds = Int(totalSeconds.truncatingRemainder(dividingBy: 60))
        let milliseconds = Int((totalSeconds.truncatingRemainder(dividingBy: 1) * 1000).rounded())
        return CounterComponents(hours: hours, minutes: minutes, seconds: seconds, milliseconds: milliseconds)
    }
    public struct TimecodeComponents {
        public let hours: Int
        public let minutes: Int
        public let seconds: Int
        public let frames: Int
        public var timecodeString: String {
            String(format: "%02d:%02d:%02d:%02d", hours, minutes, seconds, frames)
        }
    }
    public func timeAsTimecode(usingFrameDuration frameDuration: CMTime, dropFrame: Bool = false) -> TimecodeComponents {
        let frameRate = TimecodeFrameRate(frameDuration: frameDuration, drop: dropFrame) ?? .fps30
        let tc = try! Timecode(.cmTime(self), at: frameRate)
        return TimecodeComponents(hours: tc.hours, minutes: tc.minutes, seconds: tc.seconds, frames: tc.frames)
    }
    /// Returns the CMTime rounded to the nearest frame duration
    public func rounded(toFrameDuration frameDuration: CMTime) -> CMTime {
        let numberOfFrames = seconds / frameDuration.seconds
        let roundedFrames = round(numberOfFrames)
        return CMTime(value: Int64(roundedFrames * Double(frameDuration.value)), timescale: frameDuration.timescale)
    }
    /// Returns the CMTime floored to the nearest frame duration
    public func floored(toFrameDuration frameDuration: CMTime) -> CMTime {
        let numberOfFrames = seconds / frameDuration.seconds
        let flooredFrames = floor(numberOfFrames)
        return CMTime(value: Int64(flooredFrames * Double(frameDuration.value)), timescale: frameDuration.timescale)
    }
    /// Returns the CMTime ceiled to the nearest frame duration
    public func ceiled(toFrameDuration frameDuration: CMTime) -> CMTime {
        let numberOfFrames = seconds / frameDuration.seconds
        let ceiledFrames = ceil(numberOfFrames)
        return CMTime(value: Int64(ceiledFrames * Double(frameDuration.value)), timescale: frameDuration.timescale)
    }
    /// The CMTime value as an FCPXML time string using the format "[value]/[timescale]s" or "0s" if the value is zero.
    public var fcpxmlString: String {
        if value == 0 {
            return "0s"
        } else {
            return "\(value)/\(timescale)s"
        }
    }
}
