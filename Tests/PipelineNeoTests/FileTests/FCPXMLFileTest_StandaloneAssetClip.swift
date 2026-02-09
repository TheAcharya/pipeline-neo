//
//  FCPXMLFileTest_StandaloneAssetClip.swift
//  Pipeline Neo • https://github.com/TheAcharya/pipeline-neo
//  © 2026 • Licensed under MIT License


//
//	File Tests: StandaloneAssetClip.fcpxml.
//

import XCTest
@testable import PipelineNeo

@available(macOS 12.0, *)
final class FCPXMLFileTest_StandaloneAssetClip: XCTestCase {

    func testParse() throws {
        let fcpxml = try loadFCPXMLSample(named: "StandaloneAssetClip")
        XCTAssertEqual(fcpxml.root.element.name, "fcpxml")
        XCTAssertTrue(fcpxml.root.resources.childElements.count >= 1)
    }
}
