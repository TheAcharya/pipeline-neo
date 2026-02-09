//
//  FCPXMLFileTest_Complex.swift
//  Pipeline Neo • https://github.com/TheAcharya/pipeline-neo
//  © 2026 • Licensed under MIT License


//
//	File Tests: Complex.fcpxml — resources, library, events, sequence. Mirrors DAW Complex.
//

import XCTest
@testable import PipelineNeo

@available(macOS 12.0, *)
final class FCPXMLFileTest_Complex: XCTestCase {

    func testParse() throws {
        let fcpxml = try loadFCPXMLSample(named: "Complex")
        XCTAssertEqual(fcpxml.root.element.name, "fcpxml")
        XCTAssertEqual(fcpxml.version, .ver1_11)
        let events = fcpxml.allEvents()
        XCTAssertFalse(events.isEmpty)
        let projects = fcpxml.allProjects()
        XCTAssertFalse(projects.isEmpty)
    }

    func testRootVersionAttribute() throws {
        let fcpxml = try loadFCPXMLSample(named: "Complex")
        XCTAssertTrue(fcpxml.version.major == 1 && fcpxml.version.minor >= 10)
    }

    func testResourcesExist() throws {
        let fcpxml = try loadFCPXMLSample(named: "Complex")
        let resources = fcpxml.root.resources
        XCTAssertGreaterThan(resources.childElements.count, 0, "Expected resource children")
    }
}
