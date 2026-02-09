//
//  FCPXMLExporter.swift
//  Pipeline Neo • https://github.com/TheAcharya/pipeline-neo
//  © 2026 • Licensed under MIT License


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
    /// - Parameters:
    ///   - timeline: The timeline (clips reference `assetRef` matching `assets[].id`).
    ///   - assets: Assets referenced by timeline clips. Each `id` must match a `TimelineClip.assetRef`.
    ///   - libraryName: Library element name.
    ///   - eventName: Event element name.
    ///   - projectName: Project name (default: timeline name).
    /// - Returns: FCPXML XML string.
    /// - Note: Asset IDs must not equal `FCPXMLExporter.formatResourceID` (`r1`).
    public func export(
        timeline: Timeline,
        assets: [FCPXMLExportAsset],
        libraryName: String = "Exported Library",
        eventName: String = "Exported Event",
        projectName: String? = nil
    ) throws -> String {
        let utility = FCPXMLUtility.defaultForExtensions
        let assetIds = Set(assets.map(\.id))

        if timeline.clips.isEmpty {
            throw FCPXMLExportError.invalidTimeline(reason: "Timeline has no clips")
        }

        for clip in timeline.clips {
            if !assetIds.contains(clip.assetRef) {
                throw FCPXMLExportError.missingAsset(assetId: clip.assetRef)
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
            isInterlaced: false,
            isSD16x9: false
        )
        formatEl.addStringAttribute(name: "name", value: formatName)
        formatEl.addStringAttribute(name: "frameDuration", value: utility.fcpxmlTime(fromCMTime: format.frameDuration))
        formatEl.addStringAttribute(name: "width", value: "\(format.width)")
        formatEl.addStringAttribute(name: "height", value: "\(format.height)")
        if format.colorSpace.fcpxmlValue != "1-1-1 (Rec. 709)" {
            formatEl.addStringAttribute(name: "colorSpace", value: format.colorSpace.fcpxmlValue)
        }
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
        let project = XMLElement(name: "project")
        project.addStringAttribute(name: "name", value: projectName ?? timeline.name)
        let sequence = XMLElement(name: "sequence")
        sequence.addStringAttribute(name: "format", value: formatID)
        sequence.addStringAttribute(name: "duration", value: utility.fcpxmlTime(fromCMTime: timeline.duration))
        sequence.addStringAttribute(name: "tcStart", value: "0s")

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
        library.addStringAttribute(name: "name", value: libraryName)
        library.addChild(event)
        root.addChild(library)
        let doc = XMLDocument()
        doc.documentContentKind = .xml
        doc.characterEncoding = "UTF-8"
        doc.version = "1.0"
        doc.setRootElement(root)
        doc.fcpxmlVersion = version.stringValue
        return doc.fcpxmlString
    }
}
