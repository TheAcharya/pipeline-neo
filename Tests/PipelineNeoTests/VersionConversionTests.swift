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

    /// When converting to 1.10, elements not in the 1.10 DTD (e.g. adjust-colorConform from 1.11+) are stripped so FCP can import.
    func testConvertToVersion_1_10_StripsAdjustColorConform() throws {
        let doc = service.createFCPXMLDocument(version: "1.14")
        guard let root = doc.rootElement() else {
            XCTFail("No root")
            return
        }
        let assetClip = XMLElement(name: "asset-clip")
        let adjustColorConform = XMLElement(name: "adjust-colorConform")
        adjustColorConform.setAttributesWith(["enabled": "1", "autoOrManual": "automatic", "conformType": "conformNone", "peakNitsOfPQSource": "1000", "peakNitsOfSDRToPQSource": "100"])
        assetClip.addChild(adjustColorConform)
        root.addChild(assetClip)

        let converted = try service.convertToVersion(doc, targetVersion: .v1_10)
        XCTAssertEqual(converted.fcpxmlVersion, "1.10")

        let found = findElement(named: "adjust-colorConform", in: converted)
        XCTAssertNil(found, "adjust-colorConform must be stripped when converting to 1.10 for FCP DTD validation")
    }

    /// When converting to 1.12, adjust-stereo-3D (1.13+) is stripped.
    func testConvertToVersion_1_12_StripsAdjustStereo3D() throws {
        let doc = service.createFCPXMLDocument(version: "1.14")
        guard let root = doc.rootElement() else {
            XCTFail("No root")
            return
        }
        let assetClip = XMLElement(name: "asset-clip")
        let adjustStereo = XMLElement(name: "adjust-stereo-3D")
        assetClip.addChild(adjustStereo)
        root.addChild(assetClip)

        let converted = try service.convertToVersion(doc, targetVersion: .v1_12)
        XCTAssertEqual(converted.fcpxmlVersion, "1.12")
        let found = findElement(named: "adjust-stereo-3D", in: converted)
        XCTAssertNil(found, "adjust-stereo-3D must be stripped when converting to 1.12")
    }

    private func findElement(named name: String, in document: XMLDocument) -> XMLElement? {
        guard let root = document.rootElement() else { return nil }
        return findElement(named: name, in: root)
    }

    private func findElement(named name: String, in element: XMLElement) -> XMLElement? {
        if element.name == name { return element }
        for node in element.children ?? [] {
            if let el = node as? XMLElement, let match = findElement(named: name, in: el) { return match }
        }
        return nil
    }
    
    // MARK: - Edge Cases
    
    func testConvertToVersion_DocumentAlwaysHasRoot() throws {
        // Verify that converted documents always have a root element
        // This tests the edge case handling in FCPXMLVersionConverter
        let doc = service.createFCPXMLDocument(version: "1.14")
        let converted = try service.convertToVersion(doc, targetVersion: .v1_10)
        
        // Converted document should always have a root element
        let root = converted.rootElement()
        XCTAssertNotNil(root, "Converted document should always have a root element")
        XCTAssertEqual(root?.name, "fcpxml", "Root element should be 'fcpxml'")
        XCTAssertEqual(converted.fcpxmlVersion, "1.10", "Version should be set correctly")
    }
    
    func testConvertToVersion_StrippingWorksWithValidRoot() throws {
        // Verify that element stripping works when root exists
        let doc = service.createFCPXMLDocument(version: "1.14")
        
        // Add an element that should be stripped when converting to 1.10
        // (adjust-colorConform was introduced in 1.11)
        guard let root = doc.rootElement() else {
            XCTFail("Document should have root element")
            return
        }
        
        let resources = root.firstChildElement(named: "resources") ?? XMLElement(name: "resources")
        if root.firstChildElement(named: "resources") == nil {
            root.addChild(resources)
        }
        
        let asset = XMLElement(name: "asset")
        asset.setAttributesWith(["id": "r1", "name": "Test"])
        let adjustColorConform = XMLElement(name: "adjust-colorConform")
        adjustColorConform.setAttributesWith(["enabled": "1"])
        asset.addChild(adjustColorConform)
        resources.addChild(asset)
        
        let converted = try service.convertToVersion(doc, targetVersion: .v1_10)
        
        // Verify adjust-colorConform was stripped
        let convertedRoot = converted.rootElement()
        XCTAssertNotNil(convertedRoot, "Converted document should have root")
        
        // Search for adjust-colorConform - it should not exist
        let found = findElement(named: "adjust-colorConform", in: convertedRoot!)
        XCTAssertNil(found, "adjust-colorConform should be stripped when converting to 1.10")
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
