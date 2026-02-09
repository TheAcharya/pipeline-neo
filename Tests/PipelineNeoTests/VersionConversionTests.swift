//
//  VersionConversionTests.swift
//  Pipeline Neo • https://github.com/TheAcharya/pipeline-neo
//  © 2026 • Licensed under MIT License
//
//
//	Tests for FCPXML version conversion and save as .fcpxml / .fcpxmld.
//

import XCTest
@testable import PipelineNeo

@available(macOS 12.0, *)
final class VersionConversionTests: XCTestCase, @unchecked Sendable {

    private var service: FCPXMLService!
    private var converter: FCPXMLVersionConverter!

    override func setUpWithError() throws {
        try super.setUpWithError()
        converter = FCPXMLVersionConverter()
        service = FCPXMLService(versionConverter: converter)
    }

    override func tearDownWithError() throws {
        service = nil
        converter = nil
        try super.tearDownWithError()
    }

    // MARK: - Convert to version

    func testConvertToVersion_1_14_to_1_10() throws {
        let doc = service.createFCPXMLDocument(version: "1.14")
        XCTAssertEqual(doc.fcpxmlVersion, "1.14")
        let converted = try service.convertToVersion(doc, targetVersion: .v1_10)
        XCTAssertEqual(converted.fcpxmlVersion, "1.10")
    }

    func testConvertToVersion_1_10_to_1_14() throws {
        let doc = service.createFCPXMLDocument(version: "1.10")
        let converted = try service.convertToVersion(doc, targetVersion: .v1_14)
        XCTAssertEqual(converted.fcpxmlVersion, "1.14")
    }

    func testConvertToVersion_ReturnsNewDocument() throws {
        let doc = service.createFCPXMLDocument(version: "1.13")
        let converted = try service.convertToVersion(doc, targetVersion: .v1_10)
        XCTAssertNotIdentical(doc, converted)
        XCTAssertEqual(doc.fcpxmlVersion, "1.13")
        XCTAssertEqual(converted.fcpxmlVersion, "1.10")
    }

    // MARK: - Save as .fcpxml

    func testSaveAsFCPXML() throws {
        let doc = try service.convertToVersion(service.createFCPXMLDocument(version: "1.14"), targetVersion: .v1_10)
        let tempDir = FileManager.default.temporaryDirectory
        let fileURL = tempDir.appendingPathComponent("VersionConversionTests_\(UUID().uuidString).fcpxml")
        defer { try? FileManager.default.removeItem(at: fileURL) }
        try service.saveAsFCPXML(doc, to: fileURL)
        XCTAssertTrue(FileManager.default.fileExists(atPath: fileURL.path))
        let data = try Data(contentsOf: fileURL)
        let loaded = try XMLDocument(data: data)
        XCTAssertEqual(loaded.fcpxmlVersion, "1.10")
    }

    // MARK: - Save as .fcpxmld (1.10+ only)

    func testSaveAsBundle_WhenVersion1_10_Succeeds() throws {
        let doc = try service.convertToVersion(service.createFCPXMLDocument(version: "1.14"), targetVersion: .v1_10)
        let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent("VersionConversionTests_\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: tempDir) }
        let bundleURL = try service.saveAsBundle(doc, to: tempDir, bundleName: "TestProject")
        XCTAssertTrue(FileManager.default.fileExists(atPath: bundleURL.path))
        let infoFcpxml = bundleURL.appendingPathComponent("Info.fcpxml")
        let infoPlist = bundleURL.appendingPathComponent("Info.plist")
        XCTAssertTrue(FileManager.default.fileExists(atPath: infoFcpxml.path))
        XCTAssertTrue(FileManager.default.fileExists(atPath: infoPlist.path))
        let data = try Data(contentsOf: infoFcpxml)
        let loaded = try XMLDocument(data: data)
        XCTAssertEqual(loaded.fcpxmlVersion, "1.10")
    }

    func testSaveAsBundle_WhenVersionBelow1_10_Throws() throws {
        let doc = service.createFCPXMLDocument(version: "1.9")
        let tempDir = FileManager.default.temporaryDirectory
        do {
            _ = try service.saveAsBundle(doc, to: tempDir, bundleName: "Test")
            XCTFail("Expected bundleRequiresVersion1_10OrHigher")
        } catch let error as FCPXMLBundleExportError {
            if case .bundleRequiresVersion1_10OrHigher(let v) = error {
                XCTAssertEqual(v, "1.9")
            } else {
                XCTFail("Expected bundleRequiresVersion1_10OrHigher, got \(error)")
            }
        }
    }

    // MARK: - Async

    func testConvertToVersionAsync() async throws {
        let doc = await service.createFCPXMLDocument(version: "1.14")
        let converted = try await service.convertToVersion(doc, targetVersion: .v1_10)
        XCTAssertEqual(converted.fcpxmlVersion, "1.10")
    }

    func testSaveAsBundleAsync() async throws {
        let doc = await service.createFCPXMLDocument(version: "1.14")
        let converted = try await service.convertToVersion(doc, targetVersion: .v1_10)
        let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent("VersionConversionTests_async_\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: tempDir) }
        let bundleURL = try await service.saveAsBundle(converted, to: tempDir, bundleName: "AsyncProject")
        XCTAssertTrue(FileManager.default.fileExists(atPath: bundleURL.appendingPathComponent("Info.fcpxml").path))
    }
}
