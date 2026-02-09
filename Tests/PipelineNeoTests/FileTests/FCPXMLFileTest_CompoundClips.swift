//
//  FCPXMLFileTest_CompoundClips.swift
//  Pipeline Neo • https://github.com/TheAcharya/pipeline-neo
//  © 2026 • Licensed under MIT License


//
//	File Tests: CompoundClips.fcpxml.
//

import XCTest
@testable import PipelineNeo

@available(macOS 12.0, *)
final class FCPXMLFileTest_CompoundClips: XCTestCase {

    func testParse() throws {
        let fcpxml = try loadFCPXMLSample(named: "CompoundClips")
        XCTAssertEqual(fcpxml.root.element.name, "fcpxml")
        XCTAssertFalse(fcpxml.allProjects().isEmpty)
    }
}
