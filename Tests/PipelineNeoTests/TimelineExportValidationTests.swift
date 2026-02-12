//
//  TimelineExportValidationTests.swift
//  Pipeline Neo • https://github.com/TheAcharya/pipeline-neo
//  © 2026 • Licensed under MIT License
//

//
//	Tests for timeline, export, validation, and file loading.
//

import XCTest
import CoreMedia
@testable import PipelineNeo

@available(macOS 12.0, *)
final class TimelineExportValidationTests: XCTestCase {

    // MARK: - Timeline & TimelineClip

    func testTimelineClipEndTime() {
        let clip = TimelineClip(
            assetRef: "r2",
            offset: CMTime(value: 10, timescale: 1),
            duration: CMTime(value: 5, timescale: 1)
        )
        XCTAssertEqual(CMTimeGetSeconds(clip.endTime), 15)
    }

    func testTimelineDurationFromPrimaryLane() {
        let clips: [TimelineClip] = [
            TimelineClip(assetRef: "r2", offset: .zero, duration: CMTime(value: 10, timescale: 1), lane: 0),
            TimelineClip(assetRef: "r3", offset: CMTime(value: 10, timescale: 1), duration: CMTime(value: 5, timescale: 1), lane: 0),
        ]
        let timeline = Timeline(name: "T", clips: clips)
        XCTAssertEqual(CMTimeGetSeconds(timeline.duration), 15)
    }

    func testTimelineSortedClips() {
        let clips: [TimelineClip] = [
            TimelineClip(assetRef: "r3", offset: CMTime(value: 10, timescale: 1), duration: CMTime(value: 1, timescale: 1), lane: 0),
            TimelineClip(assetRef: "r2", offset: .zero, duration: CMTime(value: 10, timescale: 1), lane: 0),
        ]
        let timeline = Timeline(name: "T", clips: clips)
        let sorted = timeline.sortedClips
        XCTAssertEqual(sorted[0].assetRef, "r2")
        XCTAssertEqual(sorted[1].assetRef, "r3")
    }

    func testTimelineFormatHelpers() {
        let fd = CMTime(value: 1001, timescale: 24000)
        let hd = TimelineFormat.hd1080p(frameDuration: fd, colorSpace: .rec709)
        XCTAssertEqual(hd.width, 1920)
        XCTAssertEqual(hd.height, 1080)
        XCTAssertFalse(hd.interlaced)
        XCTAssertTrue(hd.isHD)
        XCTAssertTrue(hd.is1080p)
        XCTAssertFalse(hd.isUHD)
        
        let uhd = TimelineFormat.uhd4K(frameDuration: fd, colorSpace: .rec2020)
        XCTAssertEqual(uhd.width, 3840)
        XCTAssertEqual(uhd.height, 2160)
        XCTAssertTrue(uhd.isUHD)
        XCTAssertTrue(uhd.isStandard4K)
        XCTAssertFalse(uhd.isDCI4K)
        
        let dci = TimelineFormat.dci4K(frameDuration: fd, colorSpace: .rec2020)
        XCTAssertEqual(dci.width, 4096)
        XCTAssertEqual(dci.height, 2160)
        XCTAssertTrue(dci.isUHD)
        XCTAssertTrue(dci.isDCI4K)
        XCTAssertFalse(dci.isStandard4K)
        
        let hd720 = TimelineFormat.hd720p(frameDuration: fd, colorSpace: .rec709)
        XCTAssertEqual(hd720.width, 1280)
        XCTAssertEqual(hd720.height, 720)
        XCTAssertTrue(hd720.isHD)
        XCTAssertTrue(hd720.is720p)
        
        let hd1080i = TimelineFormat.hd1080i(frameDuration: fd, colorSpace: .rec709)
        XCTAssertTrue(hd1080i.interlaced)
        XCTAssertEqual(hd1080i.width, 1920)
        XCTAssertEqual(hd1080i.height, 1080)
    }
    
    func testTimelineFormatComputedProperties() {
        let fd = CMTime(value: 1001, timescale: 24000)
        let format = TimelineFormat.hd1080p(frameDuration: fd)
        
        // Aspect ratio
        XCTAssertEqual(format.aspectRatio, 1920.0 / 1080.0, accuracy: 0.001)
        
        // Resolution checks
        XCTAssertTrue(format.isHD)
        XCTAssertTrue(format.is1080p)
        XCTAssertFalse(format.is720p)
        XCTAssertFalse(format.isUHD)
        XCTAssertFalse(format.interlaced)
    }
    
    func testTimelineFormatEquality() {
        let fd = CMTime(value: 1001, timescale: 24000)
        let format1 = TimelineFormat.hd1080p(frameDuration: fd)
        let format2 = TimelineFormat.hd1080p(frameDuration: fd)
        let format3 = TimelineFormat.hd1080p(frameDuration: fd, colorSpace: .rec2020)
        let format4 = TimelineFormat.hd1080i(frameDuration: fd)
        
        XCTAssertEqual(format1, format2)
        XCTAssertNotEqual(format1, format3) // Different color space
        XCTAssertNotEqual(format1, format4) // Different interlaced
    }
    
    func testTimelineFormatHelpersOnTimeline() {
        let timeline = Timeline(name: "Test")
        XCTAssertFalse(timeline.isHD)
        XCTAssertFalse(timeline.isUHD)
        XCTAssertEqual(timeline.aspectRatio, 0)
        
        let fd = CMTime(value: 1001, timescale: 24000)
        let format = TimelineFormat.hd1080p(frameDuration: fd)
        let timelineWithFormat = Timeline(name: "Test", format: format)
        
        XCTAssertTrue(timelineWithFormat.isHD)
        XCTAssertFalse(timelineWithFormat.isUHD)
        XCTAssertEqual(timelineWithFormat.aspectRatio, 1920.0 / 1080.0, accuracy: 0.001)
    }

    // MARK: - FCPXMLExporter

    func testFCPXMLExporterExportMinimal() throws {
        let clip = TimelineClip(
            assetRef: "r2",
            offset: .zero,
            duration: CMTime(value: 1001, timescale: 24000),
            start: .zero,
            lane: 0
        )
        let timeline = Timeline(name: "Test", clips: [clip])
        let asset = FCPXMLExportAsset(
            id: "r2",
            name: "Clip1",
            src: URL(fileURLWithPath: "/tmp/sample.mov"),
            duration: CMTime(value: 1001, timescale: 24000),
            hasVideo: true,
            hasAudio: true
        )
        let exporter = FCPXMLExporter(version: .default)
        let xml = try exporter.export(timeline: timeline, assets: [asset])
        XCTAssertTrue(xml.contains("<fcpxml"))
        XCTAssertTrue(xml.contains("resources"))
        XCTAssertTrue(xml.contains("r1"))
        XCTAssertTrue(xml.contains("r2"))
        XCTAssertTrue(xml.contains("asset-clip"))
        XCTAssertTrue(xml.contains("ref=\"r2\""))
    }

    func testFCPXMLExporterMissingAssetThrows() {
        let clip = TimelineClip(assetRef: "r99", offset: .zero, duration: CMTime(value: 1, timescale: 1), lane: 0)
        let timeline = Timeline(name: "T", clips: [clip])
        let exporter = FCPXMLExporter(version: .default)
        XCTAssertThrowsError(try exporter.export(timeline: timeline, assets: [])) { err in
            guard case FCPXMLExportError.missingAsset(let id) = err else {
                XCTFail("Expected missingAsset, got \(err)"); return
            }
            XCTAssertEqual(id, "r99")
        }
    }

    func testFCPXMLExporterEmptyTimelineThrows() {
        let timeline = Timeline(name: "Empty", clips: [])
        let exporter = FCPXMLExporter(version: .default)
        XCTAssertThrowsError(try exporter.export(timeline: timeline, assets: [])) { err in
            guard case FCPXMLExportError.invalidTimeline = err else {
                XCTFail("Expected invalidTimeline, got \(err)"); return
            }
        }
    }

    // MARK: - FCPXMLBundleExporter

    func testFCPXMLBundleExporterCreatesBundle() throws {
        let temp = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: temp, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: temp) }

        let clip = TimelineClip(assetRef: "r2", offset: .zero, duration: CMTime(value: 1, timescale: 1), lane: 0)
        let timeline = Timeline(name: "BundleTest", clips: [clip])
        let asset = FCPXMLExportAsset(
            id: "r2",
            src: URL(fileURLWithPath: "/nonexistent.mov"),
            hasVideo: true,
            hasAudio: true
        )

        // Without media: should still create bundle structure (but we'd fail on copy if includeMedia true and file missing)
        let exporter = FCPXMLBundleExporter(version: .default, includeMedia: false)
        // Export with includeMedia: false doesn't copy files; we need valid FCPXML. So we build assets that aren't copied.
        // Actually with includeMedia: false we don't copy, so we never touch asset.src. So we can use a fake URL.
        let bundleURL = try exporter.exportBundle(timeline: timeline, assets: [asset], to: temp, bundleName: "Out")
        XCTAssertTrue(FileManager.default.fileExists(atPath: bundleURL.path))
        XCTAssertEqual(bundleURL.lastPathComponent, "Out.fcpxmld")
        let infoFcpxml = bundleURL.appendingPathComponent("Info.fcpxml")
        let infoPlist = bundleURL.appendingPathComponent("Info.plist")
        XCTAssertTrue(FileManager.default.fileExists(atPath: infoFcpxml.path))
        XCTAssertTrue(FileManager.default.fileExists(atPath: infoPlist.path))
        let xmlData = try Data(contentsOf: infoFcpxml)
        let xml = String(data: xmlData, encoding: .utf8)
        XCTAssertNotNil(xml)
        XCTAssertTrue(xml?.contains("<fcpxml") == true)
    }

    func testFCPXMLBundleExporterWithMediaCopiesFiles() throws {
        let temp = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: temp, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: temp) }

        // Create a real temp file to copy
        let sample = temp.appendingPathComponent("sample.mov")
        try Data("fake".utf8).write(to: sample)

        let clip = TimelineClip(assetRef: "r2", offset: .zero, duration: CMTime(value: 1, timescale: 1), lane: 0)
        let timeline = Timeline(name: "WithMedia", clips: [clip])
        let asset = FCPXMLExportAsset(id: "r2", src: sample, hasVideo: true, hasAudio: true)

        let exporter = FCPXMLBundleExporter(version: .default, includeMedia: true)
        let bundleURL = try exporter.exportBundle(timeline: timeline, assets: [asset], to: temp, bundleName: "WithMedia")
        let mediaDir = bundleURL.appendingPathComponent("Media")
        XCTAssertTrue(FileManager.default.fileExists(atPath: mediaDir.path))
        let mediaContents = try FileManager.default.contentsOfDirectory(atPath: mediaDir.path)
        XCTAssertEqual(mediaContents.count, 1)
        XCTAssertTrue(mediaContents[0].hasSuffix(".mov") || mediaContents[0] == "sample.mov")
        let xmlData = try Data(contentsOf: bundleURL.appendingPathComponent("Info.fcpxml"))
        let xml = String(data: xmlData, encoding: .utf8)!
        XCTAssertTrue(xml.contains("<fcpxml"))
        // Exporter uses relativePath "Media/filename" when includeMedia is true
        XCTAssertTrue(xml.contains("Media/") || xml.contains("src="), "FCPXML should reference media")
    }

    // MARK: - FCPXMLValidator (semantic)

    func testFCPXMLValidatorSuccessWithValidStructure() {
        let root = XMLElement(name: "fcpxml")
        root.addAttribute(XMLNode.attribute(withName: "version", stringValue: "1.14") as! XMLNode)
        let resources = XMLElement(name: "resources")
        let format = XMLElement(name: "format")
        format.addAttribute(XMLNode.attribute(withName: "id", stringValue: "r1") as! XMLNode)
        resources.addChild(format)
        root.addChild(resources)
        let doc = XMLDocument()
        doc.setRootElement(root)
        let validator = FCPXMLValidator()
        let result = validator.validate(doc)
        XCTAssertTrue(result.isValid)
    }

    func testFCPXMLValidatorMissingRoot() {
        let doc = XMLDocument()
        doc.setRootElement(XMLElement(name: "notfcpxml"))
        let validator = FCPXMLValidator()
        let result = validator.validate(doc)
        XCTAssertFalse(result.isValid)
        XCTAssertTrue(result.errors.contains { $0.message.contains("fcpxml") })
    }

    func testFCPXMLValidatorUnresolvedRef() {
        let root = XMLElement(name: "fcpxml")
        root.addAttribute(XMLNode.attribute(withName: "version", stringValue: "1.14") as! XMLNode)
        let resources = XMLElement(name: "resources")
        root.addChild(resources)
        let event = XMLElement(name: "event")
        event.addAttribute(XMLNode.attribute(withName: "name", stringValue: "E1") as! XMLNode)
        let project = XMLElement(name: "project")
        let sequence = XMLElement(name: "sequence")
        let spine = XMLElement(name: "spine")
        let clip = XMLElement(name: "asset-clip")
        clip.addAttribute(XMLNode.attribute(withName: "ref", stringValue: "r99") as! XMLNode)
        spine.addChild(clip)
        sequence.addChild(spine)
        project.addChild(sequence)
        event.addChild(project)
        root.addChild(event)
        let doc = XMLDocument()
        doc.setRootElement(root)
        let validator = FCPXMLValidator()
        let result = validator.validate(doc)
        XCTAssertFalse(result.isValid)
        XCTAssertTrue(result.errors.contains { $0.type == .missingAssetReference })
    }

    // MARK: - FCPXMLDTDValidator

    func testFCPXMLDTDValidatorReturnsResult() {
        let doc = XMLDocument(resources: [], events: [], fcpxmlVersion: .default)
        let validator = FCPXMLDTDValidator()
        let result = validator.validate(doc, version: .default)
        // A well-formed document with resources + events should validate against the DTD.
        XCTAssertTrue(result.isValid, "Expected valid FCPXML, got errors: \(result.errors.map(\.message))")
    }

    // MARK: - FCPXMLService DTD validation (per-version)

    func testValidateDocumentAgainstDTD_EachSupportedVersion() {
        let service = FCPXMLService()
        // 1.5 DTD requires (import-options?, resources?, library); the convenience init produces (resources?, events); use 1.6–1.14.
        let versionsToTest = FCPXMLVersion.allCases.filter { $0 != .v1_5 }
        for version in versionsToTest {
            let doc = XMLDocument(resources: [], events: [], fcpxmlVersion: version)
            let result = service.validateDocumentAgainstDTD(doc, version: version)
            XCTAssertTrue(
                result.isValid,
                "Version \(version.rawValue) should validate against its own DTD. Errors: \(result.detailedDescription)"
            )
        }
        // Version 1.5 DTD requires (import-options?, resources?, library). Build minimal valid doc.
        let doc1_5 = XMLDocument()
        doc1_5.setRootElement(XMLElement(name: "fcpxml"))
        doc1_5.fcpxmlVersion = "1.5"
        doc1_5.rootElement()?.addChild(XMLElement(name: "resources"))
        doc1_5.rootElement()?.addChild(XMLElement(name: "library"))
        let result1_5 = service.validateDocumentAgainstDTD(doc1_5, version: .v1_5)
        XCTAssertTrue(result1_5.isValid, "Version 1.5 with library should validate. Errors: \(result1_5.detailedDescription)")
    }

    func testValidateDocumentAgainstDeclaredVersion_ValidDocument() {
        let service = FCPXMLService()
        let doc = XMLDocument(resources: [], events: [], fcpxmlVersion: .v1_10)
        let result = service.validateDocumentAgainstDeclaredVersion(doc)
        XCTAssertTrue(result.isValid, "Declared version 1.10 should validate. Errors: \(result.detailedDescription)")
    }

    func testValidateDocumentAgainstDeclaredVersion_MissingVersion() {
        let service = FCPXMLService()
        let doc = XMLDocument()
        doc.setRootElement(XMLElement(name: "fcpxml"))
        // No version attribute
        let result = service.validateDocumentAgainstDeclaredVersion(doc)
        XCTAssertFalse(result.isValid)
        XCTAssertTrue(result.errors.contains { $0.message.contains("no FCPXML version") })
    }

    func testValidateDocumentAgainstDeclaredVersion_UnsupportedVersion() {
        let service = FCPXMLService()
        let doc = XMLDocument(resources: [], events: [], fcpxmlVersion: .v1_14)
        doc.fcpxmlVersion = "99.99"
        let result = service.validateDocumentAgainstDeclaredVersion(doc)
        XCTAssertFalse(result.isValid)
        XCTAssertTrue(result.errors.contains { $0.message.contains("Unsupported") || $0.message.contains("99.99") })
    }

    // MARK: - performValidation (semantic + DTD)

    func testPerformValidation_ValidDocument() {
        let service = FCPXMLService()
        let doc = XMLDocument(resources: [], events: [], fcpxmlVersion: .v1_10)
        // Ensure resources element exists (semantic validator requires it)
        if doc.fcpxmlElement?.firstChildElement(named: "resources") == nil {
            let resourcesEl = XMLElement(name: "resources")
            doc.fcpxmlElement?.addChild(resourcesEl)
        }
        let report = service.performValidation(doc)
        XCTAssertTrue(report.isValid, "Valid document should pass full validation. \(report.summary)")
        XCTAssertTrue(report.semantic.isValid)
        XCTAssertTrue(report.dtd.isValid)
    }

    func testPerformValidation_InvalidSemantic() {
        let service = FCPXMLService()
        let doc = XMLDocument(resources: [], events: [], fcpxmlVersion: .v1_10)
        if doc.fcpxmlElement?.firstChildElement(named: "resources") == nil {
            doc.fcpxmlElement?.addChild(XMLElement(name: "resources"))
        }
        let root = doc.fcpxmlElement!
        let clip = XMLElement(name: "ref-clip")
        clip.addAttribute(withName: "ref", value: "missing-resource")
        root.addChild(clip)
        let report = service.performValidation(doc)
        XCTAssertFalse(report.isValid)
        XCTAssertFalse(report.semantic.isValid, "Semantic validation should fail for unresolved ref")
        XCTAssertTrue(report.semantic.errors.contains { $0.message.contains("missing-resource") || $0.message.contains("Reference") })
    }

    func testPerformValidation_InvalidDTD() {
        let service = FCPXMLService()
        let doc = XMLDocument()
        doc.setRootElement(XMLElement(name: "fcpxml"))
        // No version attribute -> DTD validation fails
        let report = service.performValidation(doc)
        XCTAssertFalse(report.isValid)
        XCTAssertFalse(report.semantic.isValid) // also missing resources
        XCTAssertFalse(report.dtd.isValid)
    }

    // MARK: - FCPXMLFileLoader (.fcpxml / .fcpxmld file I/O)

    func testFCPXMLFileLoaderLoadsSingleFile() throws {
        let temp = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".fcpxml")
        let xml = """
        <?xml version="1.0" encoding="UTF-8"?>
        <fcpxml version="1.14">
            <resources/>
        </fcpxml>
        """
        try xml.write(to: temp, atomically: true, encoding: .utf8)
        defer { try? FileManager.default.removeItem(at: temp) }
        let loader = FCPXMLFileLoader()
        let doc = try loader.loadDocument(from: temp)
        XCTAssertNotNil(doc.rootElement())
        XCTAssertTrue(doc.fcpxmlElement?.name == "fcpxml")
    }

    func testFCPXMLFileLoaderLoadsBundle() throws {
        let temp = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: temp, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: temp) }
        let clip = TimelineClip(assetRef: "r2", offset: .zero, duration: CMTime(value: 1, timescale: 1), lane: 0)
        let timeline = Timeline(name: "LoadTest", clips: [clip])
        let asset = FCPXMLExportAsset(id: "r2", src: URL(fileURLWithPath: "/tmp/x.mov"), hasVideo: true, hasAudio: true)
        let exporter = FCPXMLBundleExporter(version: .default, includeMedia: false)
        let bundleURL = try exporter.exportBundle(timeline: timeline, assets: [asset], to: temp, bundleName: "Bundle")
        let loader = FCPXMLFileLoader()
        let resolved = try loader.resolveFCPXMLFileURL(from: bundleURL)
        XCTAssertEqual(resolved.lastPathComponent, "Info.fcpxml")
        let doc = try loader.loadDocument(from: bundleURL)
        XCTAssertNotNil(doc.rootElement())
    }

    func testFCPXMLFileLoaderThrowsForMissingURL() {
        let url = URL(fileURLWithPath: "/nonexistent/path.fcpxml")
        let loader = FCPXMLFileLoader()
        XCTAssertThrowsError(try loader.loadDocument(from: url)) { err in
            XCTAssertTrue(err is FCPXMLLoadError)
        }
    }
}
