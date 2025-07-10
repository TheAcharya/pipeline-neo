//
//  XMLDocumentManager.swift
//  Pipeline Neo • https://github.com/TheAcharya/pipeline-neo
//  © 2025 • Licensed under MIT License
//

import Foundation

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
        
        var resourcesElement = rootElement.elements(forName: "resources").first
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
        return element.attribute(forName: name)?.stringValue
    }
} 