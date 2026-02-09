//
//  CheckVersion.swift
//  Pipeline Neo • https://github.com/TheAcharya/pipeline-neo
//  © 2026 • Licensed under MIT License
//
//
//  Check and print FCPXML document version (used by --check-version).
//

import Foundation
import PipelineNeo

enum CheckVersion {
    /// Loads the FCPXML at the given URL and prints its document version.
    static func run(fcpxmlPath: URL) throws {
        let loader = FCPXMLFileLoader()
        let document = try loader.loadDocument(from: fcpxmlPath)
        let version = document.fcpxmlVersion ?? "(none)"
        print(version)
    }
}
