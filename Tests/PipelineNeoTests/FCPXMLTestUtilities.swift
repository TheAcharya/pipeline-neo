//
//  FCPXMLTestUtilities.swift
//  Pipeline Neo • https://github.com/TheAcharya/pipeline-neo
//  © 2026 • Licensed under MIT License
//

//
//	Test helper functions for loading FCPXML samples.
//

import Foundation
import XCTest
@testable import PipelineNeo

/// Loads FCPXML sample data by name. Throws XCTSkip if file is missing.
func loadFCPXMLSampleData(named name: String) throws -> Data {
    let url = urlForFCPXMLSample(named: name)
    guard FileManager.default.fileExists(atPath: url.path) else {
        throw XCTSkip("Sample not found: \(name).fcpxml at \(url.path)")
    }
    return try Data(contentsOf: url)
}

/// Loads FCPXML as FinalCutPro.FCPXML from a sample by name. Throws XCTSkip if file missing.
func loadFCPXMLSample(named name: String) throws -> FinalCutPro.FCPXML {
    let data = try loadFCPXMLSampleData(named: name)
    return try FinalCutPro.FCPXML(fileContent: data)
}

/// Frame rate sample names (one test file per frame rate in DAW).
let fcpxmlFrameRateSampleNames: [String] = [
    "23.98", "24", "24With25Media", "25i", "29.97", "29.97d", "30", "50", "59.94", "60"
]

/// All sample names for smoke/iteration tests.
func allFCPXMLSampleNames() -> [String] {
    let dir = fcpxmlSamplesDirectory()
    guard let enumerator = FileManager.default.enumerator(at: dir, includingPropertiesForKeys: [.isRegularFileKey], options: [.skipsHiddenFiles]) else {
        return []
    }
    var names: [String] = []
    for case let url as URL in enumerator {
        guard url.pathExtension == "fcpxml" else { continue }
        names.append(url.deletingPathExtension().lastPathComponent)
    }
    return names.sorted()
}
