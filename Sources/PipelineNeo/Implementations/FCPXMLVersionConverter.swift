//
//  FCPXMLVersionConverter.swift
//  Pipeline Neo • https://github.com/TheAcharya/pipeline-neo
//  © 2026 • Licensed under MIT License
//

//
//	Default implementation of FCPXMLVersionConverting: sets root version, strips elements not in the target version's DTD (like Capacitor), and returns a copy.
//	

import Foundation

/// Default implementation of `FCPXMLVersionConverting`.
///
/// Produces a copy of the document with the root `version` attribute set to the
/// target version. Elements that are not defined in the target version’s DTD
/// (e.g. `adjust-colorConform` in 1.11+) are automatically removed so the output
/// validates in Final Cut Pro, similar to Capacitor’s behaviour.
@available(macOS 12.0, *)
public final class FCPXMLVersionConverter: FCPXMLVersionConverting, Sendable {

    public init() {}

    // MARK: - FCPXMLVersionConverting (Sync)

    public func convert(_ document: XMLDocument, to targetVersion: FCPXMLVersion) throws -> XMLDocument {
        try _convert(document, to: targetVersion)
    }

    // MARK: - FCPXMLVersionConverting (Async)

    public func convert(_ document: XMLDocument, to targetVersion: FCPXMLVersion) async throws -> XMLDocument {
        try _convert(document, to: targetVersion)
    }

    /// Elements introduced after a given version (per DTD). When converting to a target version,
    /// any element whose introduced version is greater than the target is stripped.
    private static let elementsIntroducedAfter: [(name: String, introducedIn: FCPXMLVersion)] = [
        ("object-tracker", .v1_10),
        ("adjust-cinematic", .v1_10),
        ("adjust-colorConform", .v1_11),
        ("adjust-voiceIsolation", .v1_11),
        ("adjust-stereo-3D", .v1_13),
    ]

    /// Element names to remove when converting to `target` (elements not in that version’s DTD).
    private static func elementNamesToStrip(whenConvertingTo target: FCPXMLVersion) -> Set<String> {
        var names: Set<String> = []
        for entry in elementsIntroducedAfter {
            if target.isOlder(than: entry.introducedIn) {
                names.insert(entry.name)
            }
        }
        return names
    }

    private func _convert(_ document: XMLDocument, to targetVersion: FCPXMLVersion) throws -> XMLDocument {
        let data = document.xmlData
        let copy = try XMLDocument(
            data: data,
            options: [.nodePreserveWhitespace, .nodePrettyPrint, .nodeCompactEmptyElement]
        )
        copy.fcpxmlVersion = targetVersion.stringValue

        let toStrip = Self.elementNamesToStrip(whenConvertingTo: targetVersion)
        if !toStrip.isEmpty {
            guard let root = copy.rootElement() else {
                // XMLDocument should always have a root element when created from valid XML data.
                // If root is nil, this indicates potential document corruption or an edge case.
                // In debug builds, assert to catch this during development.
                // In release builds, conversion continues without stripping (version is still set correctly).
                #if DEBUG
                assertionFailure("FCPXMLVersionConverter: Document copy has no root element. Element stripping skipped.")
                #endif
                return copy
            }
            stripElements(in: root, names: toStrip)
        }

        return copy
    }

    /// Recursively removes direct children whose name is in `names`, then recurses into remaining children.
    private func stripElements(in element: XMLElement, names: Set<String>) {
        let children = element.children ?? []
        var indicesToRemove: [Int] = []
        for (index, node) in children.enumerated() {
            guard let child = node as? XMLElement, let name = child.name, names.contains(name) else { continue }
            indicesToRemove.append(index)
        }
        for index in indicesToRemove.reversed() {
            element.removeChild(at: index)
        }
        for node in element.children ?? [] {
            if let child = node as? XMLElement {
                stripElements(in: child, names: names)
            }
        }
    }
}

// MARK: - FCPXMLVersion ordering

@available(macOS 12.0, *)
private extension FCPXMLVersion {
    /// Returns `true` if this version is strictly older than `other` (e.g. 1.10 is older than 1.11).
    func isOlder(than other: FCPXMLVersion) -> Bool {
        guard let selfIndex = FCPXMLVersion.allCases.firstIndex(of: self),
              let otherIndex = FCPXMLVersion.allCases.firstIndex(of: other) else {
            return false
        }
        return selfIndex < otherIndex
    }
}
