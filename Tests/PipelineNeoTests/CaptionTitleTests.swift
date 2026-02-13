//
//  CaptionTitleTests.swift
//  PipelineNeoTests
//  © 2026 • Licensed under MIT License
//

import XCTest
import SwiftTimecode
@testable import PipelineNeo

final class CaptionTitleTests: XCTestCase {
    
    // MARK: - TextStyle Tests
    
    func testTextStyleInitialization() {
        let textStyle = FinalCutPro.FCPXML.TextStyle(
            referenceID: "ts1",
            value: "Hello World"
        )
        
        XCTAssertEqual(textStyle.referenceID, "ts1")
        XCTAssertEqual(textStyle.value, "Hello World")
    }
    
    func testTextStyleWithFormatting() {
        var textStyle = FinalCutPro.FCPXML.TextStyle()
        textStyle.font = "Helvetica"
        textStyle.fontSize = 24
        textStyle.fontColor = "1.0 1.0 1.0 1.0"
        textStyle.isBold = true
        textStyle.alignment = .center
        
        XCTAssertEqual(textStyle.font, "Helvetica")
        XCTAssertEqual(textStyle.fontSize, 24)
        XCTAssertEqual(textStyle.fontColor, "1.0 1.0 1.0 1.0")
        XCTAssertEqual(textStyle.isBold, true)
        XCTAssertEqual(textStyle.alignment, .center)
    }
    
    func testTextStyleCodable() throws {
        var textStyle = FinalCutPro.FCPXML.TextStyle()
        textStyle.font = "Helvetica"
        textStyle.fontSize = 24
        textStyle.isBold = true
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(textStyle)
        
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(FinalCutPro.FCPXML.TextStyle.self, from: data)
        
        XCTAssertEqual(decoded.font, textStyle.font)
        XCTAssertEqual(decoded.fontSize, textStyle.fontSize)
        XCTAssertEqual(decoded.isBold, textStyle.isBold)
    }
    
    // MARK: - TextStyleDefinition Tests
    
    func testTextStyleDefinitionInitialization() {
        var textStyle = FinalCutPro.FCPXML.TextStyle()
        textStyle.font = "Helvetica"
        textStyle.fontSize = 24
        let styleDef = FinalCutPro.FCPXML.TextStyleDefinition(
            id: "ts1",
            name: "Default Style",
            textStyles: [textStyle]
        )
        
        XCTAssertEqual(styleDef.id, "ts1")
        XCTAssertEqual(styleDef.name, "Default Style")
        XCTAssertEqual(styleDef.textStyles.count, 1)
    }
    
    func testTextStyleDefinitionCodable() throws {
        var textStyle = FinalCutPro.FCPXML.TextStyle()
        textStyle.font = "Helvetica"
        let styleDef = FinalCutPro.FCPXML.TextStyleDefinition(
            id: "ts1",
            name: "Style",
            textStyles: [textStyle]
        )
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(styleDef)
        
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(FinalCutPro.FCPXML.TextStyleDefinition.self, from: data)
        
        XCTAssertEqual(decoded.id, styleDef.id)
        XCTAssertEqual(decoded.name, styleDef.name)
        XCTAssertEqual(decoded.textStyles.count, styleDef.textStyles.count)
    }
    
    // MARK: - Caption Integration Tests
    
    func testCaptionWithTextStyleDefinition() throws {
        let xmlString = """
        <caption duration="5s">
            <text-style-def id="ts1" name="Caption Style">
                <text-style font="Helvetica" fontSize="24" fontColor="1.0 1.0 1.0 1.0" bold="1"/>
            </text-style-def>
        </caption>
        """
        
        let xmlDoc = try XMLDocument(xmlString: xmlString)
        guard let captionElement = xmlDoc.rootElement() else {
            XCTFail("Failed to parse XML")
            return
        }
        
        guard let caption = FinalCutPro.FCPXML.Caption(element: captionElement) else {
            XCTFail("Failed to create Caption")
            return
        }
        
        let styleDefs = caption.typedTextStyleDefinitions
        XCTAssertEqual(styleDefs.count, 1)
        XCTAssertEqual(styleDefs[0].id, "ts1")
        XCTAssertEqual(styleDefs[0].name, "Caption Style")
        XCTAssertEqual(styleDefs[0].textStyles.count, 1)
        XCTAssertEqual(styleDefs[0].textStyles[0].font, "Helvetica")
    }
    
    func testCaptionTextStyleDefinitionRoundTrip() {
        var caption = FinalCutPro.FCPXML.Caption(duration: Fraction(5, 1))
        
        var textStyle = FinalCutPro.FCPXML.TextStyle()
        textStyle.font = "Helvetica"
        textStyle.fontSize = 24
        textStyle.fontColor = "1.0 1.0 1.0 1.0"
        textStyle.isBold = true
        
        let styleDef = FinalCutPro.FCPXML.TextStyleDefinition(
            id: "ts1",
            name: "Caption Style",
            textStyles: [textStyle]
        )
        
        caption.typedTextStyleDefinitions = [styleDef]
        _ = caption // Explicitly use variable to acknowledge mutation
        
        let retrieved = caption.typedTextStyleDefinitions
        XCTAssertEqual(retrieved.count, 1)
        XCTAssertEqual(retrieved[0].id, "ts1")
        XCTAssertEqual(retrieved[0].textStyles[0].font, "Helvetica")
        
        // Verify XML structure
        let styleDefElements = caption.element.childElements.filter { $0.name == "text-style-def" }
        XCTAssertEqual(styleDefElements.count, 1)
    }
    
    // MARK: - Title Integration Tests
    
    func testTitleWithTextStyleDefinition() throws {
        let xmlString = """
        <title ref="r1" duration="5s">
            <text-style-def id="ts1" name="Title Style">
                <text-style font="Helvetica" fontSize="48" fontColor="1.0 1.0 0.0 1.0" alignment="center"/>
            </text-style-def>
        </title>
        """
        
        let xmlDoc = try XMLDocument(xmlString: xmlString)
        guard let titleElement = xmlDoc.rootElement() else {
            XCTFail("Failed to parse XML")
            return
        }
        
        guard let title = FinalCutPro.FCPXML.Title(element: titleElement) else {
            XCTFail("Failed to create Title")
            return
        }
        
        let styleDefs = title.typedTextStyleDefinitions
        XCTAssertEqual(styleDefs.count, 1)
        XCTAssertEqual(styleDefs[0].id, "ts1")
        XCTAssertEqual(styleDefs[0].name, "Title Style")
        XCTAssertEqual(styleDefs[0].textStyles.count, 1)
        XCTAssertEqual(styleDefs[0].textStyles[0].font, "Helvetica")
        XCTAssertEqual(styleDefs[0].textStyles[0].fontSize, 48)
    }
    
    func testTitleTextStyleDefinitionRoundTrip() {
        var title = FinalCutPro.FCPXML.Title(ref: "r1", duration: Fraction(5, 1))
        
        var textStyle = FinalCutPro.FCPXML.TextStyle()
        textStyle.font = "Helvetica"
        textStyle.fontSize = 48
        textStyle.fontColor = "1.0 1.0 0.0 1.0"
        textStyle.alignment = .center
        
        let styleDef = FinalCutPro.FCPXML.TextStyleDefinition(
            id: "ts1",
            name: "Title Style",
            textStyles: [textStyle]
        )
        
        title.typedTextStyleDefinitions = [styleDef]
        _ = title // Explicitly use variable to acknowledge mutation
        
        let retrieved = title.typedTextStyleDefinitions
        XCTAssertEqual(retrieved.count, 1)
        XCTAssertEqual(retrieved[0].id, "ts1")
        XCTAssertEqual(retrieved[0].textStyles[0].font, "Helvetica")
        XCTAssertEqual(retrieved[0].textStyles[0].alignment, .center)
        
        // Verify XML structure
        let styleDefElements = title.element.childElements.filter { $0.name == "text-style-def" }
        XCTAssertEqual(styleDefElements.count, 1)
    }
}
