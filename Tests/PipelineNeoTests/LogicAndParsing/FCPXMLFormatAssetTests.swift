//
//  FCPXMLFormatAssetTests.swift
//  Pipeline Neo • https://github.com/TheAcharya/pipeline-neo
//  © 2026 • Licensed under MIT License
//

//
//	Tests for Format and Asset resource models (FCPXML 1.13+ heroEye / heroEyeOverride, Asset mediaReps).
//	Backward compatible with 1.5: heroEye and heroEyeOverride are optional; mediaReps supports single or multiple media-rep.
//

import Foundation
import XCTest
@testable import PipelineNeo

@available(macOS 12.0, *)
final class FCPXMLFormatAssetTests: XCTestCase {

    // MARK: - Format heroEye (1.13+)

    func testFormatHeroEyeRoundTrip() {
        let format = FinalCutPro.FCPXML.Format(id: "f1")
        XCTAssertNil(format.heroEye)

        format.heroEye = "left"
        XCTAssertEqual(format.heroEye, "left")
        XCTAssertEqual(format.element.stringValue(forAttributeNamed: "heroEye"), "left")

        format.heroEye = "right"
        XCTAssertEqual(format.heroEye, "right")

        format.heroEye = nil
        XCTAssertNil(format.heroEye)
        XCTAssertNil(format.element.stringValue(forAttributeNamed: "heroEye"))
    }

    func testFormatInitWithHeroEye() {
        let format = FinalCutPro.FCPXML.Format(
            id: "f1",
            name: "Stereo",
            heroEye: "right"
        )
        XCTAssertEqual(format.heroEye, "right")
    }

    func testFormatFromElementWithHeroEye() {
        let formatEl = XMLElement(name: "format")
        formatEl.addAttribute(withName: "id", value: "f1")
        formatEl.addAttribute(withName: "heroEye", value: "left")
        guard let format = FinalCutPro.FCPXML.Format(element: formatEl) else {
            XCTFail("Format init from element failed"); return
        }
        XCTAssertEqual(format.heroEye, "left")
    }

    // MARK: - Asset heroEyeOverride (1.13+)

    func testAssetHeroEyeOverrideRoundTrip() {
        let asset = FinalCutPro.FCPXML.Asset(id: "a1")
        asset.mediaRep = FinalCutPro.FCPXML.MediaRep(src: URL(fileURLWithPath: "/tmp/test.mov"))
        XCTAssertNil(asset.heroEyeOverride)

        asset.heroEyeOverride = "left"
        XCTAssertEqual(asset.heroEyeOverride, "left")
        XCTAssertEqual(asset.element.stringValue(forAttributeNamed: "heroEyeOverride"), "left")

        asset.heroEyeOverride = "right"
        XCTAssertEqual(asset.heroEyeOverride, "right")

        asset.heroEyeOverride = nil
        XCTAssertNil(asset.heroEyeOverride)
    }

    func testAssetInitWithHeroEyeOverride() {
        let asset = FinalCutPro.FCPXML.Asset(
            id: "a1",
            heroEyeOverride: "right",
            mediaRep: FinalCutPro.FCPXML.MediaRep(src: URL(fileURLWithPath: "/tmp/v.mov"))
        )
        XCTAssertEqual(asset.heroEyeOverride, "right")
    }

    func testAssetFromElementWithHeroEyeOverride() {
        let assetEl = XMLElement(name: "asset")
        assetEl.addAttribute(withName: "id", value: "a1")
        assetEl.addAttribute(withName: "heroEyeOverride", value: "right")
        let mediaRepEl = XMLElement(name: "media-rep")
        mediaRepEl.addAttribute(withName: "src", value: "file:///tmp/v.mov")
        assetEl.addChild(mediaRepEl)
        guard let asset = FinalCutPro.FCPXML.Asset(element: assetEl) else {
            XCTFail("Asset init from element failed"); return
        }
        XCTAssertEqual(asset.heroEyeOverride, "right")
    }

    // MARK: - Asset mediaReps (multiple media-rep)

    func testAssetMediaRepsRoundTrip() {
        let asset = FinalCutPro.FCPXML.Asset(id: "a1")
        let rep1 = FinalCutPro.FCPXML.MediaRep(kind: .originalMedia, src: URL(fileURLWithPath: "/tmp/original.mov"))
        let rep2 = FinalCutPro.FCPXML.MediaRep(kind: .proxyMedia, src: URL(fileURLWithPath: "/tmp/proxy.mov"))
        asset.mediaReps = [rep1, rep2]
        XCTAssertEqual(asset.mediaReps.count, 2)
        XCTAssertEqual(asset.mediaReps[0].kind, .originalMedia)
        XCTAssertEqual(asset.mediaReps[1].kind, .proxyMedia)
        let mediaRepElements = asset.element.childElements.filter { $0.name == "media-rep" }
        XCTAssertEqual(mediaRepElements.count, 2)
    }

    func testAssetMediaRepBackwardCompatibility() {
        let asset = FinalCutPro.FCPXML.Asset(id: "a1")
        asset.mediaRep = FinalCutPro.FCPXML.MediaRep(src: URL(fileURLWithPath: "/tmp/single.mov"))
        XCTAssertEqual(asset.mediaReps.count, 1)
        XCTAssertEqual(asset.mediaRep.src?.path, "/tmp/single.mov")
        let proxy = FinalCutPro.FCPXML.MediaRep(kind: .proxyMedia, src: URL(fileURLWithPath: "/tmp/proxy.mov"))
        asset.mediaReps = asset.mediaReps + [proxy]
        XCTAssertEqual(asset.mediaReps.count, 2)
        XCTAssertEqual(asset.mediaRep.src?.path, "/tmp/single.mov")
    }

    func testAssetInitWithMediaReps() {
        let rep1 = FinalCutPro.FCPXML.MediaRep(kind: .originalMedia, src: URL(fileURLWithPath: "/tmp/o.mov"))
        let rep2 = FinalCutPro.FCPXML.MediaRep(kind: .proxyMedia, src: URL(fileURLWithPath: "/tmp/p.mov"))
        let asset = FinalCutPro.FCPXML.Asset(id: "a2", mediaReps: [rep1, rep2])
        XCTAssertEqual(asset.mediaReps.count, 2)
        XCTAssertEqual(asset.mediaReps[0].kind, .originalMedia)
        XCTAssertEqual(asset.mediaReps[1].kind, .proxyMedia)
    }

    func testAssetFromElementWithMultipleMediaReps() {
        let assetEl = XMLElement(name: "asset")
        assetEl.addAttribute(withName: "id", value: "a3")
        let rep1 = XMLElement(name: "media-rep")
        rep1.addAttribute(withName: "kind", value: "original-media")
        rep1.addAttribute(withName: "src", value: "file:///tmp/orig.mov")
        let rep2 = XMLElement(name: "media-rep")
        rep2.addAttribute(withName: "kind", value: "proxy-media")
        rep2.addAttribute(withName: "src", value: "file:///tmp/proxy.mov")
        assetEl.addChild(rep1)
        assetEl.addChild(rep2)
        guard let asset = FinalCutPro.FCPXML.Asset(element: assetEl) else {
            XCTFail("Asset init from element failed"); return
        }
        XCTAssertEqual(asset.mediaReps.count, 2)
        XCTAssertEqual(asset.mediaReps[0].kind, .originalMedia)
        XCTAssertEqual(asset.mediaReps[1].kind, .proxyMedia)
    }
}
