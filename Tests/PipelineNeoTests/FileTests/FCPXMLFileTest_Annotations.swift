//
//  FCPXMLFileTest_Annotations.swift
//  Pipeline Neo • https://github.com/TheAcharya/pipeline-neo
//  © 2026 • Licensed under MIT License
//

//
//	File Tests: Annotations.fcpxml.
//

import XCTest
@testable import PipelineNeo

@available(macOS 12.0, *)
final class FCPXMLFileTest_Annotations: XCTestCase {

    func testParse() throws {
        let fcpxml = try loadFCPXMLSample(named: "Annotations")
        XCTAssertEqual(fcpxml.root.element.name, "fcpxml")
        XCTAssertFalse(fcpxml.allEvents().isEmpty)
        XCTAssertFalse(fcpxml.allProjects().isEmpty)
    }
}
