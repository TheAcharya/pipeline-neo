//
//  XMLDocumentManager.swift
//  Pipeline Neo • https://github.com/TheAcharya/pipeline-neo
//  © 2025 • Licensed under MIT License
//

import Foundation
import SwiftExtensions

/// Implementation of XML document operations
@available(macOS 12.0, *)
public final class XMLDocumentManager: XMLDocumentOperations, XMLElementOperations, Sendable {
    
    public init() {}
    
    // MARK: - XMLDocumentOperations Implementation
    
    public func createFCPXMLDocument(version: String) -> XMLDocument {
        let rootElement = XMLElement(name: "fcpxml")
        rootElement.setAttributesAs(["version": version])
        
        let document = XMLDocument()
        document.setRootElement(rootElement)
        return document
    }
    
    public func addResource(_ resource: XMLElement, to document: XMLDocument) {
        guard let rootElement = document.rootElement() else { return }
        
        var resourcesElement = rootElement.firstChildElement(named: "resources")
        if resourcesElement == nil {
            resourcesElement = XMLElement(name: "resources")
            rootElement.addChild(resourcesElement!)
        }
        
        resourcesElement!.addChild(resource)
    }
    
    public func addSequence(_ sequence: XMLElement, to document: XMLDocument) {
        guard let rootElement = document.rootElement() else { return }
        rootElement.addChild(sequence)
    }
    
    public func saveDocument(_ document: XMLDocument, to url: URL) throws {
        let data = document.xmlData
        try data.write(to: url)
    }
    
    // MARK: - XMLDocumentOperations Async Implementation
    
    public func createFCPXMLDocument(version: String) async -> XMLDocument {
        // For now, just call the synchronous version
        let rootElement = XMLElement(name: "fcpxml")
        rootElement.setAttributesAs(["version": version])
        
        let document = XMLDocument()
        document.setRootElement(rootElement)
        return document
    }
    
    public func addResource(_ resource: XMLElement, to document: XMLDocument) async {
        // For now, just call the synchronous version
        guard let rootElement = document.rootElement() else { return }
        
        var resourcesElement = rootElement.firstChildElement(named: "resources")
        if resourcesElement == nil {
            resourcesElement = XMLElement(name: "resources")
            rootElement.addChild(resourcesElement!)
        }
        
        resourcesElement!.addChild(resource)
    }
    
    public func addSequence(_ sequence: XMLElement, to document: XMLDocument) async {
        // For now, just call the synchronous version
        guard let rootElement = document.rootElement() else { return }
        rootElement.addChild(sequence)
    }
    
    public func saveDocument(_ document: XMLDocument, to url: URL) async throws {
        // For now, just call the synchronous version
        let data = document.xmlData
        try data.write(to: url)
    }
    
    // MARK: - XMLElementOperations Implementation
    
    public func createElement(name: String, attributes: [String: String]) -> XMLElement {
        let element = XMLElement(name: name)
        element.setAttributesAs(attributes)
        return element
    }
    
    public func addChild(_ child: XMLElement, to parent: XMLElement) {
        parent.addChild(child)
    }
    
    public func setAttribute(name: String, value: String, on element: XMLElement) {
        element.setAttributesAs([name: value])
    }
    
    public func getAttribute(name: String, from element: XMLElement) -> String? {
        element.stringValue(forAttributeNamed: name)
    }
    
    // MARK: - XMLElementOperations Async Implementation
    
    public func createElement(name: String, attributes: [String: String]) async -> XMLElement {
        // For now, just call the synchronous version
        let element = XMLElement(name: name)
        element.setAttributesAs(attributes)
        return element
    }
    
    public func addChild(_ child: XMLElement, to parent: XMLElement) async {
        // For now, just call the synchronous version
        parent.addChild(child)
    }
    
    public func setAttribute(name: String, value: String, on element: XMLElement) async {
        // For now, just call the synchronous version
        element.setAttributesAs([name: value])
    }
    
    public func getAttribute(name: String, from element: XMLElement) async -> String? {
        element.stringValue(forAttributeNamed: name)
    }
} 