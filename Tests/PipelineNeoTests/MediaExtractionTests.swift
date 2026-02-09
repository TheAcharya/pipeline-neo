//
//  MediaExtractionTests.swift
//  Pipeline Neo • https://github.com/TheAcharya/pipeline-neo
//  © 2026 • Licensed under MIT License
//
//
//	Tests for media reference extraction and copy.
//

import XCTest
@testable import PipelineNeo

@available(macOS 12.0, *)
final class MediaExtractionTests: XCTestCase, @unchecked Sendable {

    private var service: FCPXMLService!

    override func setUpWithError() throws {
        try super.setUpWithError()
        service = FCPXMLService()
    }

    override func tearDownWithError() throws {
        service = nil
        try super.tearDownWithError()
    }

    // MARK: - Extract (Example FCPXML Cut 1)

    func testExtractMediaReferences_ExampleCut1() throws {
        let url = packageRoot()
            .appendingPathComponent("Example FCPXML", isDirectory: true)
            .appendingPathComponent("Cut 1.fcpxmld", isDirectory: true)
            .appendingPathComponent("Info.fcpxml")
        guard FileManager.default.fileExists(atPath: url.path) else {
            throw XCTSkip("Example FCPXML Cut 1 not found at \(url.path)")
        }
        let data = try Data(contentsOf: url)
        let document = try service.parseFCPXML(from: data)
        let baseURL = url.deletingLastPathComponent()
        let result = service.extractMediaReferences(from: document, baseURL: baseURL)
        XCTAssertGreaterThanOrEqual(result.references.count, 1, "Cut 1 has at least one asset")
        let withURL = result.references.filter { $0.url != nil }
        XCTAssertGreaterThanOrEqual(withURL.count, 1)
        let fileRefs = result.fileReferences
        XCTAssertGreaterThanOrEqual(fileRefs.count, 1)
        let first = try XCTUnwrap(result.references.first)
        XCTAssertFalse(first.isLocator, "Asset is not a locator")
        XCTAssertEqual(first.resourceID, "r2")
    }

    func testExtractMediaReferences_ExampleCut1_Async() async throws {
        let url = packageRoot()
            .appendingPathComponent("Example FCPXML", isDirectory: true)
            .appendingPathComponent("Cut 1.fcpxmld", isDirectory: true)
            .appendingPathComponent("Info.fcpxml")
        guard FileManager.default.fileExists(atPath: url.path) else {
            throw XCTSkip("Example FCPXML Cut 1 not found at \(url.path)")
        }
        let data = try Data(contentsOf: url)
        let document = try await service.parseFCPXML(from: data)
        let baseURL = url.deletingLastPathComponent()
        let result = await service.extractMediaReferences(from: document, baseURL: baseURL)
        XCTAssertGreaterThanOrEqual(result.references.count, 1)
        XCTAssertGreaterThanOrEqual(result.fileReferences.count, 1)
    }

    // MARK: - Copy (missing file → skipped)

    func testCopyReferencedMedia_MissingFile_Skips() throws {
        let nonexistent = URL(fileURLWithPath: "/nonexistent/\(UUID().uuidString)/missing.mov")
        let fcpxml = """
        <?xml version="1.0" encoding="UTF-8"?>
        <!DOCTYPE fcpxml>
        <fcpxml version="1.10">
            <resources>
                <format id="r1" name="FFVideoFormat1080p25" frameDuration="100/2500s" width="1920" height="1080"/>
                <asset id="r2" name="Missing" format="r1">
                    <media-rep kind="original-media" src="\(nonexistent.absoluteString)"/>
                </asset>
            </resources>
            <library><event name="E"><project name="P"><sequence format="r1" duration="100/25s" tcStart="0s"/></project></event></library>
        </fcpxml>
        """
        let data = Data(fcpxml.utf8)
        let document = try service.parseFCPXML(from: data)
        let destDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: destDir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: destDir) }
        let result = service.copyReferencedMedia(from: document, to: destDir, baseURL: nil)
        XCTAssertEqual(result.entries.count, 1)
        let entry = try XCTUnwrap(result.entries.first)
        if case .skipped(_, let reason) = entry {
            XCTAssertEqual(reason, "File does not exist")
        } else {
            XCTFail("Expected skipped when source file does not exist, got \(entry)")
        }
    }

    // MARK: - Copy (real file → copied)

    func testCopyReferencedMedia_RealFile_Copies() throws {
        let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: tempDir) }
        let sourceFile = tempDir.appendingPathComponent("test_media.mp4")
        try Data("fake video bytes".utf8).write(to: sourceFile)
        let fcpxmlURL = tempDir.appendingPathComponent("project.fcpxml")
        let fcpxml = """
        <?xml version="1.0" encoding="UTF-8"?>
        <!DOCTYPE fcpxml>
        <fcpxml version="1.10">
            <resources>
                <format id="r1" name="FFVideoFormat1080p25" frameDuration="100/2500s" width="1920" height="1080"/>
                <asset id="r2" name="Test" format="r1">
                    <media-rep kind="original-media" src="\(sourceFile.absoluteString)"/>
                </asset>
            </resources>
            <library>
                <event name="E1">
                    <project name="P1">
                        <sequence format="r1" duration="100/25s" tcStart="0s"/>
                    </project>
                </event>
            </library>
        </fcpxml>
        """
        try Data(fcpxml.utf8).write(to: fcpxmlURL)
        let data = try Data(contentsOf: fcpxmlURL)
        let document = try service.parseFCPXML(from: data)
        let destDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: destDir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: destDir) }
        let result = service.copyReferencedMedia(from: document, to: destDir, baseURL: nil)
        XCTAssertEqual(result.copied.count, 1, "One file should be copied")
        let (src, dest) = try XCTUnwrap(result.copied.first)
        XCTAssertEqual(src.lastPathComponent, "test_media.mp4")
        XCTAssertTrue(FileManager.default.fileExists(atPath: dest.path), "Copied file should exist at destination")
    }

    func testCopyReferencedMedia_RealFile_Async() async throws {
        let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: tempDir) }
        let sourceFile = tempDir.appendingPathComponent("async_test.mp4")
        try Data("async".utf8).write(to: sourceFile)
        let fcpxmlURL = tempDir.appendingPathComponent("project.fcpxml")
        let fcpxml = """
        <?xml version="1.0" encoding="UTF-8"?>
        <!DOCTYPE fcpxml>
        <fcpxml version="1.10">
            <resources>
                <format id="r1" name="FFVideoFormat1080p25" frameDuration="100/2500s" width="1920" height="1080"/>
                <asset id="r2" name="Async" format="r1">
                    <media-rep kind="original-media" src="\(sourceFile.absoluteString)"/>
                </asset>
            </resources>
            <library><event name="E"><project name="P"><sequence format="r1" duration="100/25s" tcStart="0s"/></project></event></library>
        </fcpxml>
        """
        try Data(fcpxml.utf8).write(to: fcpxmlURL)
        let data = try Data(contentsOf: fcpxmlURL)
        let document = try await service.parseFCPXML(from: data)
        let destDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: destDir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: destDir) }
        let result = await service.copyReferencedMedia(from: document, to: destDir, baseURL: nil)
        XCTAssertEqual(result.copied.count, 1)
        XCTAssertTrue(FileManager.default.fileExists(atPath: result.copied[0].destination.path))
    }
}
