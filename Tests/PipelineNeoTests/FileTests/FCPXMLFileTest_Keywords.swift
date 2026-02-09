//
//  FCPXMLFileTest_Keywords.swift
//  Pipeline Neo • https://github.com/TheAcharya/pipeline-neo
//  © 2026 • Licensed under MIT License


//
//	File Tests: Keywords.fcpxml.
//

import XCTest
@testable import PipelineNeo

@available(macOS 12.0, *)
final class FCPXMLFileTest_Keywords: XCTestCase {

    func testParse() throws {
        let fcpxml = try loadFCPXMLSample(named: "Keywords")
        XCTAssertEqual(fcpxml.root.element.name, "fcpxml")
    }
}
