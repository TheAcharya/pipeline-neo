//
//  FCPXMLFileTest_SyncClip.swift
//  Pipeline Neo • https://github.com/TheAcharya/pipeline-neo
//  © 2026 • Licensed under MIT License


//
//	File Tests: SyncClip.fcpxml.
//

import XCTest
@testable import PipelineNeo

@available(macOS 12.0, *)
final class FCPXMLFileTest_SyncClip: XCTestCase {

    func testParse() throws {
        let fcpxml = try loadFCPXMLSample(named: "SyncClip")
        XCTAssertEqual(fcpxml.root.element.name, "fcpxml")
        XCTAssertFalse(fcpxml.allProjects().isEmpty)
    }
}
