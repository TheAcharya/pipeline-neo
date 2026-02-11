//
//  Timeline.swift
//  Pipeline Neo • https://github.com/TheAcharya/pipeline-neo
//  © 2026 • Licensed under MIT License
//

//
//	Timeline model with clips, format settings, and duration calculation.
//

import Foundation
import CoreMedia

/// Video format descriptor for export (resolution, frame duration, color space).
@available(macOS 12.0, *)
public struct TimelineFormat: Sendable, Equatable {

    public var width: Int
    public var height: Int
    public var frameDuration: CMTime
    public var colorSpace: ColorSpace

    public init(width: Int, height: Int, frameDuration: CMTime, colorSpace: ColorSpace = .rec709) {
        self.width = width
        self.height = height
        self.frameDuration = frameDuration
        self.colorSpace = colorSpace
    }

    /// 1920×1080 progressive.
    public static func hd1080p(frameDuration: CMTime, colorSpace: ColorSpace = .rec709) -> TimelineFormat {
        TimelineFormat(width: 1920, height: 1080, frameDuration: frameDuration, colorSpace: colorSpace)
    }

    /// 3840×2160 (4K UHD).
    public static func uhd4K(frameDuration: CMTime, colorSpace: ColorSpace = .rec2020) -> TimelineFormat {
        TimelineFormat(width: 3840, height: 2160, frameDuration: frameDuration, colorSpace: colorSpace)
    }
}

/// In-memory timeline used to build or export FCPXML. No persistence; clips reference assets by string ID.
@available(macOS 12.0, *)
public struct Timeline: Sendable, Equatable {

    public var name: String
    public var format: TimelineFormat?
    public var clips: [TimelineClip]

    public init(name: String, format: TimelineFormat? = nil, clips: [TimelineClip] = []) {
        self.name = name
        self.format = format
        self.clips = clips
    }

    /// Total duration (max of offset+duration on lane 0). Returns zero if empty.
    public var duration: CMTime {
        let primary = clips.filter { $0.lane == 0 }
        guard !primary.isEmpty else { return .zero }
        var maxEnd = CMTime.zero
        for clip in primary {
            let end = CMTimeAdd(clip.offset, clip.duration)
            if CMTimeCompare(end, maxEnd) > 0 {
                maxEnd = end
            }
        }
        return maxEnd
    }

    /// Clips sorted by offset then lane.
    public var sortedClips: [TimelineClip] {
        clips.sorted { lhs, rhs in
            let c = CMTimeCompare(lhs.offset, rhs.offset)
            if c != 0 { return c < 0 }
            return lhs.lane < rhs.lane
        }
    }

    public var isEmpty: Bool { clips.isEmpty }
    public var clipCount: Int { clips.count }
}
