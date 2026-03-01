//
//  FCPXMLExporter.swift
//  Pipeline Neo • https://github.com/TheAcharya/pipeline-neo
//  © 2026 • Licensed under MIT License
//

//
//	Exports Timeline and assets to an FCPXML document string.
//

import Foundation
import CoreMedia

/// Helper for creating XML attributes safely (Foundation XMLNode.attribute returns Any).
@available(macOS 12.0, *)
private extension XMLElement {
    func addStringAttribute(name: String, value: String) {
        if let attr = XMLNode.attribute(withName: name, stringValue: value) as? XMLNode {
            addAttribute(attr)
        }
    }
}

/// Errors that can occur during FCPXML export.
@available(macOS 12.0, *)
public enum FCPXMLExportError: Error, LocalizedError, Sendable {
    case missingFormat
    case missingAsset(assetId: String)
    case invalidTimeline(reason: String)
    case cancelled

    public var errorDescription: String? {
        switch self {
        case .missingFormat: return "Missing format resource"
        case .missingAsset(let id): return "Missing asset resource: \(id)"
        case .invalidTimeline(let reason): return "Invalid timeline: \(reason)"
        case .cancelled: return "Export was cancelled"
        }
    }
}

/// Exports a Timeline and assets to FCPXML document string.
@available(macOS 12.0, *)
public struct FCPXMLExporter: Sendable {

    public var version: FCPXMLVersion

    /// Format resource ID used in exported FCPXML. Must not collide with asset IDs.
    public static let formatResourceID = "r1"

    public init(version: FCPXMLVersion = .default) {
        self.version = version
    }

    /// Exports the timeline to FCPXML string.
    ///
    /// Supports timelines with zero clips (empty spine). When clips are present, every `assetRef` must match an asset `id`.
    /// Event and project UIDs are generated when not provided so the document matches FCP-style identifiers.
    ///
    /// - Parameters:
    ///   - timeline: The timeline (clips reference `assetRef` matching `assets[].id`; may be empty).
    ///   - assets: Assets referenced by timeline clips. Required only when timeline has clips; each `id` must match a `TimelineClip.assetRef`.
    ///   - libraryName: Library element name.
    ///   - eventName: Event element name.
    ///   - projectName: Project name (default: timeline name).
    ///   - eventUid: Event `uid` attribute; if nil, a new FCPXML-style UID is generated.
    ///   - projectUid: Project `uid` attribute; if nil, a new FCPXML-style UID is generated.
    ///   - libraryLocation: Optional library `location` attribute (e.g. file URL of the library bundle).
    ///   - includeDefaultSmartCollections: If true, adds FCP-style default smart collections (Projects, All Video, Audio Only, Stills, Favorites) under the library.
    /// - Returns: FCPXML XML string.
    /// - Note: Asset IDs must not equal `FCPXMLExporter.formatResourceID` (`r1`).
    public func export(
        timeline: Timeline,
        assets: [FCPXMLExportAsset],
        libraryName: String = "Exported Library",
        eventName: String = "Exported Event",
        projectName: String? = nil,
        eventUid: String? = nil,
        projectUid: String? = nil,
        libraryLocation: String? = nil,
        includeDefaultSmartCollections: Bool = false
    ) throws -> String {
        let utility = FCPXMLUtility.defaultForExtensions
        let assetIds = Set(assets.map(\.id))

        if !timeline.clips.isEmpty {
            for clip in timeline.clips {
                if !assetIds.contains(clip.assetRef) {
                    throw FCPXMLExportError.missingAsset(assetId: clip.assetRef)
                }
            }
        }

        let format = timeline.format ?? .hd1080p(
            frameDuration: CMTime(value: 1001, timescale: 24000),
            colorSpace: .rec709
        )
        let formatID = Self.formatResourceID
        var resourceElements: [XMLElement] = []

        // Format resource
        let formatEl = XMLElement(name: "format")
        formatEl.addStringAttribute(name: "id", value: formatID)
        let fps = 1.0 / CMTimeGetSeconds(format.frameDuration)
        let roundedFPS = Float(round(fps * 100) / 100)
        let formatName = utility.ffVideoFormat(
            fromWidth: format.width,
            height: format.height,
            frameRate: roundedFPS,
            isInterlaced: format.interlaced,
            isSD16x9: false
        )
        // Always set name: use the preset identifier when known, or FFVideoFormatRateUndefined for custom dimensions so FCP recognizes the format.
        formatEl.addStringAttribute(name: "name", value: formatName)
        formatEl.addStringAttribute(name: "frameDuration", value: utility.fcpxmlTime(fromCMTime: format.frameDuration))
        formatEl.addStringAttribute(name: "width", value: "\(format.width)")
        formatEl.addStringAttribute(name: "height", value: "\(format.height)")
        formatEl.addStringAttribute(name: "colorSpace", value: format.colorSpace.fcpxmlValue)
        resourceElements.append(formatEl)

        // Asset resources
        for asset in assets {
            let el = XMLElement(name: "asset")
            el.addStringAttribute(name: "id", value: asset.id)
            if let name = asset.name, !name.isEmpty {
                el.addStringAttribute(name: "name", value: name)
            }
            if let dur = asset.duration {
                el.addStringAttribute(name: "duration", value: utility.fcpxmlTime(fromCMTime: dur))
            }
            el.addStringAttribute(name: "hasVideo", value: asset.hasVideo ? "1" : "0")
            el.addStringAttribute(name: "hasAudio", value: asset.hasAudio ? "1" : "0")
            let mediaRep = XMLElement(name: "media-rep")
            mediaRep.addStringAttribute(name: "kind", value: "original-media")
            let srcString = asset.relativePath ?? asset.src.absoluteString
            mediaRep.addStringAttribute(name: "src", value: srcString)
            el.addChild(mediaRep)
            resourceElements.append(el)
        }

        // Event > project > sequence > spine
        let event = XMLElement(name: "event")
        event.addStringAttribute(name: "name", value: eventName)
        event.addStringAttribute(name: "uid", value: eventUid ?? FCPXMLUID.random())
        let project = XMLElement(name: "project")
        project.addStringAttribute(name: "name", value: projectName ?? timeline.name)
        project.addStringAttribute(name: "uid", value: projectUid ?? FCPXMLUID.random())
        project.addStringAttribute(name: "modDate", value: Self._fcpxmlModDateString(from: Date()))
        let sequence = XMLElement(name: "sequence")
        sequence.addStringAttribute(name: "format", value: formatID)
        sequence.addStringAttribute(name: "duration", value: utility.fcpxmlTime(fromCMTime: timeline.duration))
        sequence.addStringAttribute(name: "tcStart", value: "0s")
        sequence.addStringAttribute(name: "tcFormat", value: "NDF")
        sequence.addStringAttribute(name: "audioLayout", value: "stereo")
        sequence.addStringAttribute(name: "audioRate", value: "48k")

        let spine = XMLElement(name: "spine")
        for clip in timeline.sortedClips {
            let clipEl = XMLElement(name: "asset-clip")
            clipEl.addStringAttribute(name: "ref", value: clip.assetRef)
            if let name = clip.name, !name.isEmpty {
                clipEl.addStringAttribute(name: "name", value: name)
            }
            clipEl.addStringAttribute(name: "offset", value: utility.fcpxmlTime(fromCMTime: clip.offset))
            clipEl.addStringAttribute(name: "duration", value: utility.fcpxmlTime(fromCMTime: clip.duration))
            if clip.start != .zero {
                clipEl.addStringAttribute(name: "start", value: utility.fcpxmlTime(fromCMTime: clip.start))
            }
            if clip.lane != 0 {
                clipEl.addStringAttribute(name: "lane", value: "\(clip.lane)")
            }
            if clip.isVideoDisabled {
                clipEl.addStringAttribute(name: "enabled", value: "0")
            }

            // Add clip-level metadata as children of asset-clip
            for marker in clip.markers {
                clipEl.addChild(Self._markerElement(marker, utility: utility))
            }
            for chapterMarker in clip.chapterMarkers {
                clipEl.addChild(Self._chapterMarkerElement(chapterMarker, utility: utility))
            }
            for keyword in clip.keywords {
                clipEl.addChild(Self._keywordElement(keyword, utility: utility))
            }
            for rating in clip.ratings {
                clipEl.addChild(Self._ratingElement(rating, utility: utility))
            }
            if let metadata = clip.metadata {
                clipEl.addChild(Self._metadataElement(metadata))
            }

            spine.addChild(clipEl)
        }
        sequence.addChild(spine)
        project.addChild(sequence)
        event.addChild(project)

        // Build document tree: fcpxml > resources + library > event
        let root = XMLElement(name: "fcpxml")
        root.addStringAttribute(name: "version", value: version.stringValue)
        let resourcesEl = XMLElement(name: "resources")
        for el in resourceElements {
            resourcesEl.addChild(el)
        }
        root.addChild(resourcesEl)
        let library = XMLElement(name: "library")
        // DTD allows only location and colorProcessing on library; no "name" attribute.
        if let location = libraryLocation, !location.isEmpty {
            library.addStringAttribute(name: "location", value: location)
        }
        library.addChild(event)
        if includeDefaultSmartCollections {
            for smartCollection in Self._defaultSmartCollectionElements() {
                library.addChild(smartCollection)
            }
        }
        root.addChild(library)
        let doc = XMLDocument()
        doc.documentContentKind = .xml
        doc.characterEncoding = "UTF-8"
        doc.version = "1.0"
        doc.setRootElement(root)
        doc.fcpxmlVersion = version.stringValue
        let dtd = XMLDTD()
        dtd.name = "fcpxml"
        doc.dtd = dtd
        return doc.fcpxmlString
    }

    /// FCP-style default smart collections (Projects, All Video, Audio Only, Stills, Favorites).
    private static func _defaultSmartCollectionElements() -> [XMLElement] {
        let projects = XMLElement(name: "smart-collection")
        projects.addStringAttribute(name: "name", value: "Projects")
        projects.addStringAttribute(name: "match", value: "all")
        let matchClip = XMLElement(name: "match-clip")
        matchClip.addStringAttribute(name: "rule", value: "is")
        matchClip.addStringAttribute(name: "type", value: "project")
        projects.addChild(matchClip)

        let allVideo = XMLElement(name: "smart-collection")
        allVideo.addStringAttribute(name: "name", value: "All Video")
        allVideo.addStringAttribute(name: "match", value: "any")
        for type in ["videoOnly", "videoWithAudio"] {
            let m = XMLElement(name: "match-media")
            m.addStringAttribute(name: "rule", value: "is")
            m.addStringAttribute(name: "type", value: type)
            allVideo.addChild(m)
        }

        let audioOnly = XMLElement(name: "smart-collection")
        audioOnly.addStringAttribute(name: "name", value: "Audio Only")
        audioOnly.addStringAttribute(name: "match", value: "all")
        let ma = XMLElement(name: "match-media")
        ma.addStringAttribute(name: "rule", value: "is")
        ma.addStringAttribute(name: "type", value: "audioOnly")
        audioOnly.addChild(ma)

        let stills = XMLElement(name: "smart-collection")
        stills.addStringAttribute(name: "name", value: "Stills")
        stills.addStringAttribute(name: "match", value: "all")
        let ms = XMLElement(name: "match-media")
        ms.addStringAttribute(name: "rule", value: "is")
        ms.addStringAttribute(name: "type", value: "stills")
        stills.addChild(ms)

        let favorites = XMLElement(name: "smart-collection")
        favorites.addStringAttribute(name: "name", value: "Favorites")
        favorites.addStringAttribute(name: "match", value: "all")
        let mr = XMLElement(name: "match-ratings")
        mr.addStringAttribute(name: "value", value: "favorites")
        favorites.addChild(mr)

        return [projects, allVideo, audioOnly, stills, favorites]
    }

    /// FCP-style modDate string (e.g. "2026-02-23 08:18:53 +0800").
    private static func _fcpxmlModDateString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        formatter.timeZone = TimeZone.current
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.string(from: date)
    }

    // MARK: - Metadata Element Generators

    /// Generates a `<marker>` XML element from a Marker.
    private static func _markerElement(_ marker: Marker, utility: FCPXMLUtility) -> XMLElement {
        let el = XMLElement(name: "marker")
        el.addStringAttribute(name: "start", value: utility.fcpxmlTime(fromCMTime: marker.start))
        el.addStringAttribute(name: "duration", value: utility.fcpxmlTime(fromCMTime: marker.duration))
        el.addStringAttribute(name: "value", value: marker.value)
        if let note = marker.note, !note.isEmpty {
            el.addStringAttribute(name: "note", value: note)
        }
        if marker.completed {
            el.addStringAttribute(name: "completed", value: "1")
        }
        return el
    }

    /// Generates a `<chapter-marker>` XML element from a ChapterMarker.
    private static func _chapterMarkerElement(_ chapterMarker: ChapterMarker, utility: FCPXMLUtility) -> XMLElement {
        let el = XMLElement(name: "chapter-marker")
        el.addStringAttribute(name: "start", value: utility.fcpxmlTime(fromCMTime: chapterMarker.start))
        el.addStringAttribute(name: "value", value: chapterMarker.value)
        if let posterOffset = chapterMarker.posterOffset {
            el.addStringAttribute(name: "posterOffset", value: utility.fcpxmlTime(fromCMTime: posterOffset))
        }
        if let note = chapterMarker.note, !note.isEmpty {
            el.addStringAttribute(name: "note", value: note)
        }
        return el
    }

    /// Generates a `<keyword>` XML element from a Keyword.
    private static func _keywordElement(_ keyword: Keyword, utility: FCPXMLUtility) -> XMLElement {
        let el = XMLElement(name: "keyword")
        el.addStringAttribute(name: "start", value: utility.fcpxmlTime(fromCMTime: keyword.start))
        el.addStringAttribute(name: "duration", value: utility.fcpxmlTime(fromCMTime: keyword.duration))
        el.addStringAttribute(name: "value", value: keyword.value)
        if let note = keyword.note, !note.isEmpty {
            el.addStringAttribute(name: "note", value: note)
        }
        return el
    }

    /// Generates a `<rating>` XML element from a Rating.
    private static func _ratingElement(_ rating: Rating, utility: FCPXMLUtility) -> XMLElement {
        let el = XMLElement(name: "rating")
        el.addStringAttribute(name: "start", value: utility.fcpxmlTime(fromCMTime: rating.start))
        el.addStringAttribute(name: "duration", value: utility.fcpxmlTime(fromCMTime: rating.duration))
        el.addStringAttribute(name: "value", value: rating.value.rawValue)
        if let note = rating.note, !note.isEmpty {
            el.addStringAttribute(name: "note", value: note)
        }
        return el
    }

    /// Generates a `<metadata>` XML element from a Metadata struct.
    private static func _metadataElement(_ metadata: Metadata) -> XMLElement {
        let el = XMLElement(name: "metadata")
        for (key, value) in metadata.entries.sorted(by: { $0.key < $1.key }) {
            let mdEl = XMLElement(name: "md")
            mdEl.addStringAttribute(name: "key", value: key)
            mdEl.addStringAttribute(name: "value", value: value)
            el.addChild(mdEl)
        }
        return el
    }
}
