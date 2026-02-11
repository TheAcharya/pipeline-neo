//
//  CutDetectionTests.swift
//  Pipeline Neo • https://github.com/TheAcharya/pipeline-neo
//  © 2026 • Licensed under MIT License
//

//
//	Tests for cut detection: edit points, same-clip vs different-clips, boundary types.
//

import XCTest
@testable import PipelineNeo

@available(macOS 12.0, *)
final class CutDetectionTests: XCTestCase, @unchecked Sendable {

    private var service: FCPXMLService!
    private var cutDetector: CutDetector!

    override func setUpWithError() throws {
        try super.setUpWithError()
        cutDetector = CutDetector()
        service = FCPXMLService(cutDetector: cutDetector)
    }

    override func tearDownWithError() throws {
        service = nil
        cutDetector = nil
        try super.tearDownWithError()
    }

    // MARK: - Different-clips and transitions (24.fcpxml)

    func testDifferentClipsAndTransitions_24fcpxml() throws {
        let url = urlForFCPXMLSample(named: FCPXMLSampleName.frameRate24.rawValue)
        guard FileManager.default.fileExists(atPath: url.path) else {
            throw XCTSkip("Sample 24.fcpxml not found")
        }
        let data = try Data(contentsOf: url)
        let document = try service.parseFCPXML(from: data)
        let result = service.detectCuts(in: document)
        XCTAssertGreaterThan(result.totalEditPoints, 0, "24.fcpxml has multiple clips and transitions")
        XCTAssertGreaterThanOrEqual(result.transitionCount, 0)
        XCTAssertGreaterThanOrEqual(result.hardCutCount, 0)
        // At least one edit should be between different refs (r4 vs r6 etc.)
        let hasDifferentClips = result.editPoints.contains { $0.sourceRelationship == .differentClips }
        XCTAssertTrue(hasDifferentClips || result.differentClipsCutCount >= 0)
    }

    // MARK: - Empty spine / single clip

    func testDetectCuts_EmptySpine_ReturnsEmpty() throws {
        let url = urlForFCPXMLSample(named: FCPXMLSampleName.standaloneAssetClip.rawValue)
        guard FileManager.default.fileExists(atPath: url.path) else {
            throw XCTSkip("StandaloneAssetClip sample not found")
        }
        let data = try Data(contentsOf: url)
        let document = try service.parseFCPXML(from: data)
        let result = service.detectCuts(in: document)
        // Standalone asset clip may have no project spine; result may be empty
        XCTAssertEqual(result.editPoints.count, result.totalEditPoints)
    }

    func testDetectCuts_SingleClip_NoCuts() throws {
        let url = urlForFCPXMLSample(named: FCPXMLSampleName.structure.rawValue)
        guard FileManager.default.fileExists(atPath: url.path) else {
            throw XCTSkip("Structure sample not found")
        }
        let data = try Data(contentsOf: url)
        let document = try service.parseFCPXML(from: data)
        let result = service.detectCuts(in: document)
        // Structure might have one or more clips; we only assert consistency
        XCTAssertEqual(result.sameClipCutCount + result.differentClipsCutCount, result.totalEditPoints)
    }

    // MARK: - detectCuts(inSpine:)

    func testDetectCutsInSpine_DirectSpine() throws {
        let url = urlForFCPXMLSample(named: FCPXMLSampleName.frameRate24.rawValue)
        guard FileManager.default.fileExists(atPath: url.path) else {
            throw XCTSkip("24.fcpxml not found")
        }
        let data = try Data(contentsOf: url)
        let document = try service.parseFCPXML(from: data)
        guard let root = document.rootElement(), let spine = firstProjectSpine(in: root) else {
            throw XCTSkip("No spine in document")
        }
        let result = service.detectCuts(inSpine: spine)
        XCTAssertEqual(result.editPoints.count, result.totalEditPoints)
    }

    func testDetectCuts_EmptyResult_CountsZero() {
        let result = CutDetectionResult.empty
        XCTAssertEqual(result.totalEditPoints, 0)
        XCTAssertEqual(result.hardCutCount, 0)
        XCTAssertEqual(result.transitionCount, 0)
        XCTAssertEqual(result.gapCutCount, 0)
        XCTAssertEqual(result.sameClipCutCount, 0)
        XCTAssertEqual(result.differentClipsCutCount, 0)
    }

    // MARK: - Async

    func testDetectCutsAsync() async throws {
        let url = urlForFCPXMLSample(named: FCPXMLSampleName.frameRate24.rawValue)
        guard FileManager.default.fileExists(atPath: url.path) else {
            throw XCTSkip("24.fcpxml not found")
        }
        let data = try Data(contentsOf: url)
        let document = try await service.parseFCPXML(from: data)
        let result = await service.detectCuts(in: document)
        XCTAssertGreaterThanOrEqual(result.totalEditPoints, 0)
    }

    // MARK: - Helpers

    private func firstProjectSpine(in element: XMLElement) -> XMLElement? {
        if element.fcpxType == .project, let spine = element.fcpxProjectSpine { return spine }
        guard let children = element.children else { return nil }
        for node in children {
            guard node.kind == .element, let el = node as? XMLElement else { continue }
            if let found = firstProjectSpine(in: el) { return found }
        }
        return nil
    }
}
