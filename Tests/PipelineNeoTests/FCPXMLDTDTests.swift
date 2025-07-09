//
//  FCPXMLDTDTests.swift
//  Pipeline Neo • https://github.com/TheAcharya/pipeline-neo
//  © 2025 • Licensed under MIT License
//

import XCTest
@testable import PipelineNeo

final class FCPXMLDTDTests: XCTestCase {
    
    func testDTDVersionsAvailable() throws {
        let document = XMLDocument()
        let versions = document.fcpxmlDTDVersions()
        
        // Should have DTDs from 1.5 to 1.13
        XCTAssertFalse(versions.isEmpty, "No DTD versions found")
        
        // Check for specific versions
        XCTAssertTrue(versions.contains("1.5"), "DTD version 1.5 not found")
        XCTAssertTrue(versions.contains("1.6"), "DTD version 1.6 not found")
        XCTAssertTrue(versions.contains("1.7"), "DTD version 1.7 not found")
        XCTAssertTrue(versions.contains("1.8"), "DTD version 1.8 not found")
        XCTAssertTrue(versions.contains("1.9"), "DTD version 1.9 not found")
        XCTAssertTrue(versions.contains("1.10"), "DTD version 1.10 not found")
        XCTAssertTrue(versions.contains("1.11"), "DTD version 1.11 not found")
        XCTAssertTrue(versions.contains("1.12"), "DTD version 1.12 not found")
        XCTAssertTrue(versions.contains("1.13"), "DTD version 1.13 not found")
        
        // Should be sorted
        let sortedVersions = versions.sorted { version1, version2 in
            let v1 = document.versionArrayFrom(version: version1)
            let v2 = document.versionArrayFrom(version: version2)
            return v1.lexicographicallyPrecedes(v2)
        }
        XCTAssertEqual(versions, sortedVersions, "DTD versions should be sorted")
    }
    
    func testLatestVersionIs1_13() throws {
        let document = XMLDocument()
        let versions = document.fcpxmlDTDVersions()
        
        guard let latestVersion = versions.last else {
            XCTFail("No DTD versions available")
            return
        }
        
        XCTAssertEqual(latestVersion, "1.13", "Latest DTD version should be 1.13")
    }
    
    func testDTDFilenameGeneration() throws {
        let document = XMLDocument()
        
        // Test filename generation for different versions
        let filename1_5 = document.fcpxmlDTDFilename(fromVersion: "1.5", withExtension: false)
        XCTAssertEqual(filename1_5, "Final_Cut_Pro_XML_DTD_version_1.5")
        
        let filename1_13 = document.fcpxmlDTDFilename(fromVersion: "1.13", withExtension: true)
        XCTAssertEqual(filename1_13, "Final_Cut_Pro_XML_DTD_version_1.13.dtd")
    }
    
    func testDTDVersionExtraction() throws {
        let document = XMLDocument()
        
        // Test version extraction from filenames
        let version1_5 = document.fcpxmlDTDVersion(fromFilename: "Final_Cut_Pro_XML_DTD_version_1.5.dtd")
        XCTAssertEqual(version1_5, "1.5")
        
        let version1_13 = document.fcpxmlDTDVersion(fromFilename: "Final_Cut_Pro_XML_DTD_version_1.13.dtd")
        XCTAssertEqual(version1_13, "1.13")
        
        // Test without extension
        let version1_8 = document.fcpxmlDTDVersion(fromFilename: "Final_Cut_Pro_XML_DTD_version_1.8")
        XCTAssertEqual(version1_8, "1.8")
    }
    
    func testVersionComparison() throws {
        // Test with a document that has a version
        let testDocument = XMLDocument()
        
        // Create proper FCPXML structure
        let fcpxmlElement = XMLElement(name: "fcpxml")
        testDocument.addChild(fcpxmlElement)
        
        testDocument.fcpxmlVersion = "1.10"
        
        XCTAssertTrue(testDocument.versionIs(atMinimum: "1.5"), "Document v1.10 should be >= v1.5")
        XCTAssertTrue(testDocument.versionIs(atMinimum: "1.10"), "Document v1.10 should be >= v1.10")
        XCTAssertFalse(testDocument.versionIs(atMinimum: "1.11"), "Document v1.10 should not be >= v1.11")
    }
    
    func testVersionArrayConversion() throws {
        let document = XMLDocument()
        
        // Test version string to array conversion
        let version1_5 = document.versionArrayFrom(version: "1.5")
        XCTAssertEqual(version1_5, [1, 5, 0])
        
        let version1_13 = document.versionArrayFrom(version: "1.13")
        XCTAssertEqual(version1_13, [1, 13, 0])
        
        let version1_8_2 = document.versionArrayFrom(version: "1.8.2")
        XCTAssertEqual(version1_8_2, [1, 8, 2])
        
        // Test single number
        let version2 = document.versionArrayFrom(version: "2")
        XCTAssertEqual(version2, [2, 0, 0])
    }
} 