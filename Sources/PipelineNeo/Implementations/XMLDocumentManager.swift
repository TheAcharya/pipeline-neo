//
//  XMLDocumentManager.swift
//  Pipeline Neo • https://github.com/TheAcharya/pipeline-neo
//  © 2026 • Licensed under MIT License


//
//	Implementation of XML document creation, resource management, and save operations.
//

import Foundation
import SwiftExtensions

/// Default implementation of `XMLDocumentOperations` and `XMLElementOperations`.
///
/// Creates FCPXML documents, manages resources and sequences, and provides
/// element creation and attribute manipulation.
@available(macOS 12.0, *)
public final class XMLDocumentManager: XMLDocumentOperations, XMLElementOperations, Sendable {
    
    /// Creates a new XML document manager.
    public init() {}
    
    // MARK: - Internal Sync Implementations
    
    private func _createFCPXMLDocument(version: String) -> XMLDocument {
        let rootElement = XMLElement(name: "fcpxml")
        rootElement.setAttributesAs(["version": version])
        let document = XMLDocument()
        document.setRootElement(rootElement)
        return document
    }
    
    private func _addResource(_ resource: XMLElement, to document: XMLDocument) {
        guard let rootElement = document.rootElement() else { return }
        let resourcesElement: XMLElement
        if let existing = rootElement.firstChildElement(named: "resources") {
            resourcesElement = existing
        } else {
            let newResources = XMLElement(name: "resources")
            rootElement.addChild(newResources)
            resourcesElement = newResources
        }
        resourcesElement.addChild(resource)
    }
    
    private func _addSequence(_ sequence: XMLElement, to document: XMLDocument) {
        guard let rootElement = document.rootElement() else { return }
        rootElement.addChild(sequence)
    }
    
    private func _saveDocument(_ document: XMLDocument, to url: URL) throws {
        let data = document.xmlData
        do {
            try data.write(to: url)
        } catch {
            throw FCPXMLError.documentOperationFailed("Failed to save document to \(url.path): \(error.localizedDescription)")
        }
    }
    
    private func _createElement(name: String, attributes: [String: String]) -> XMLElement {
        let element = XMLElement(name: name)
        element.setAttributesAs(attributes)
        return element
    }
    
    private func _setAttribute(name: String, value: String, on element: XMLElement) {
        element.removeAttribute(forName: name)
        if let attr = XMLNode.attribute(withName: name, stringValue: value) as? XMLNode {
            element.addAttribute(attr)
        }
    }
    
    // MARK: - XMLDocumentOperations (Sync)
    
    /// Creates a new FCPXML document with the given version attribute.
    public func createFCPXMLDocument(version: String) -> XMLDocument {
        _createFCPXMLDocument(version: version)
    }
    
    /// Adds a resource element to the document's resources container.
    public func addResource(_ resource: XMLElement, to document: XMLDocument) {
        _addResource(resource, to: document)
    }
    
    /// Adds a sequence element to the document root.
    public func addSequence(_ sequence: XMLElement, to document: XMLDocument) {
        _addSequence(sequence, to: document)
    }
    
    /// Saves the document XML data to a file URL.
    public func saveDocument(_ document: XMLDocument, to url: URL) throws {
        try _saveDocument(document, to: url)
    }
    
    // MARK: - XMLDocumentOperations (Async)
    
    /// Creates a new FCPXML document asynchronously.
    public func createFCPXMLDocument(version: String) async -> XMLDocument {
        _createFCPXMLDocument(version: version)
    }
    
    /// Adds a resource element asynchronously.
    public func addResource(_ resource: XMLElement, to document: XMLDocument) async {
        _addResource(resource, to: document)
    }
    
    /// Adds a sequence element asynchronously.
    public func addSequence(_ sequence: XMLElement, to document: XMLDocument) async {
        _addSequence(sequence, to: document)
    }
    
    /// Saves the document asynchronously.
    public func saveDocument(_ document: XMLDocument, to url: URL) async throws {
        try _saveDocument(document, to: url)
    }
    
    // MARK: - XMLElementOperations (Sync)
    
    /// Creates a new XML element with the given name and attributes.
    public func createElement(name: String, attributes: [String: String]) -> XMLElement {
        _createElement(name: name, attributes: attributes)
    }
    
    /// Appends a child element to a parent element.
    public func addChild(_ child: XMLElement, to parent: XMLElement) {
        parent.addChild(child)
    }
    
    /// Sets an attribute on an element, replacing any existing value.
    public func setAttribute(name: String, value: String, on element: XMLElement) {
        _setAttribute(name: name, value: value, on: element)
    }
    
    /// Returns the string value of a named attribute on an element.
    public func getAttribute(name: String, from element: XMLElement) -> String? {
        element.stringValue(forAttributeNamed: name)
    }
    
    // MARK: - XMLElementOperations (Async)
    
    /// Creates a new XML element asynchronously.
    public func createElement(name: String, attributes: [String: String]) async -> XMLElement {
        _createElement(name: name, attributes: attributes)
    }
    
    /// Appends a child element asynchronously.
    public func addChild(_ child: XMLElement, to parent: XMLElement) async {
        parent.addChild(child)
    }
    
    /// Sets an attribute on an element asynchronously.
    public func setAttribute(name: String, value: String, on element: XMLElement) async {
        _setAttribute(name: name, value: value, on: element)
    }
    
    /// Returns the string value of a named attribute asynchronously.
    public func getAttribute(name: String, from element: XMLElement) async -> String? {
        element.stringValue(forAttributeNamed: name)
    }
}
