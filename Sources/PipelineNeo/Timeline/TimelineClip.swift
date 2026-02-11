//
//  TimelineClip.swift
//  Pipeline Neo • https://github.com/TheAcharya/pipeline-neo
//  © 2026 • Licensed under MIT License
//

//
//	Single clip within a Timeline, with source reference, offset, and duration.
//

import Foundation
import CoreMedia

/// A clip on a timeline for FCPXML export.
///
/// References an asset by string ID (e.g. `"r2"`). Use with `Timeline` and `FCPXMLExporter`;
/// assets are provided separately as `FCPXMLExportAsset`.
@available(macOS 12.0, *)
public struct TimelineClip: Sendable, Equatable {

    /// Optional display name.
    public var name: String?

    /// Resource ID of the asset (e.g. `"r2"`). Must match an `FCPXMLExportAsset.id` when exporting.
    public var assetRef: String

    /// Position on the timeline (CMTime).
    public var offset: CMTime

    /// Duration of the clip on the timeline (CMTime).
    public var duration: CMTime

    /// Start time within the source asset (trim start). Default zero.
    public var start: CMTime

    /// Lane: 0 = primary storyline, positive = above, negative = below.
    public var lane: Int

    /// When true, video is disabled (audio-only clip).
    public var isVideoDisabled: Bool

    public init(
        name: String? = nil,
        assetRef: String,
        offset: CMTime,
        duration: CMTime,
        start: CMTime = .zero,
        lane: Int = 0,
        isVideoDisabled: Bool = false
    ) {
        self.name = name
        self.assetRef = assetRef
        self.offset = offset
        self.duration = duration
        self.start = start
        self.lane = lane
        self.isVideoDisabled = isVideoDisabled
    }

    /// End time on the timeline (offset + duration).
    public var endTime: CMTime {
        CMTimeAdd(offset, duration)
    }
}
