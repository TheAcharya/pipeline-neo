//
//  FCPXMLVersionConverter.swift
//  Pipeline Neo • https://github.com/TheAcharya/pipeline-neo
//  © 2026 • Licensed under MIT License
//
//
//	Default implementation of FCPXMLVersionConverting: sets root version and returns a copy.
//

import Foundation

/// Default implementation of `FCPXMLVersionConverting`.
///
/// Produces a copy of the document with the root `version` attribute set to the
/// target version. Content is otherwise unchanged; elements introduced in
/// newer versions are not stripped when downgrading.
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

    private func _convert(_ document: XMLDocument, to targetVersion: FCPXMLVersion) throws -> XMLDocument {
        let data = document.xmlData
        let copy = try XMLDocument(
            data: data,
            options: [.nodePreserveWhitespace, .nodePrettyPrint, .nodeCompactEmptyElement]
        )
        copy.fcpxmlVersion = targetVersion.stringValue
        return copy
    }
}
