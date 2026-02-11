//
//  XMLDocumentOperations.swift
//  Pipeline Neo • https://github.com/TheAcharya/pipeline-neo
//  © 2026 • Licensed under MIT License
//

//
//	Protocols for XML document and element manipulation operations.
//

import Foundation

/// Protocol defining XML document operations
@available(macOS 12.0, *)
public protocol XMLDocumentOperations: Sendable {
    /// Creates a new FCPXML document
    /// - Parameter version: FCPXML version to use
    /// - Returns: New XMLDocument
    func createFCPXMLDocument(version: String) -> XMLDocument
    
    /// Adds a resource to the document
    /// - Parameters:
    ///   - resource: The resource element to add
    ///   - document: The target document
    func addResource(_ resource: XMLElement, to document: XMLDocument)
    
    /// Adds a sequence to the document
    /// - Parameters:
    ///   - sequence: The sequence element to add
    ///   - document: The target document
    func addSequence(_ sequence: XMLElement, to document: XMLDocument)
    
    /// Saves document to URL
    /// - Parameters:
    ///   - document: The document to save
    ///   - url: The target URL
    /// - Throws: Error if saving fails
    func saveDocument(_ document: XMLDocument, to url: URL) throws
    
    // MARK: - Async Methods
    
    /// Asynchronously creates a new FCPXML document
    /// - Parameter version: FCPXML version to use
    /// - Returns: New XMLDocument
    func createFCPXMLDocument(version: String) async -> XMLDocument
    
    /// Asynchronously adds a resource to the document
    /// - Parameters:
    ///   - resource: The resource element to add
    ///   - document: The target document
    func addResource(_ resource: XMLElement, to document: XMLDocument) async
    
    /// Asynchronously adds a sequence to the document
    /// - Parameters:
    ///   - sequence: The sequence element to add
    ///   - document: The target document
    func addSequence(_ sequence: XMLElement, to document: XMLDocument) async
    
    /// Asynchronously saves document to URL
    /// - Parameters:
    ///   - document: The document to save
    ///   - url: The target URL
    /// - Throws: Error if saving fails
    func saveDocument(_ document: XMLDocument, to url: URL) async throws
}

/// Protocol defining XML element operations
@available(macOS 12.0, *)
public protocol XMLElementOperations: Sendable {
    /// Creates a new XMLElement with attributes
    /// - Parameters:
    ///   - name: Element name
    ///   - attributes: Dictionary of attributes
    /// - Returns: New XMLElement
    func createElement(name: String, attributes: [String: String]) -> XMLElement
    
    /// Adds child element to parent
    /// - Parameters:
    ///   - child: Child element to add
    ///   - parent: Parent element
    func addChild(_ child: XMLElement, to parent: XMLElement)
    
    /// Sets attribute on element
    /// - Parameters:
    ///   - name: Attribute name
    ///   - value: Attribute value
    ///   - element: Target element
    func setAttribute(name: String, value: String, on element: XMLElement)
    
    /// Gets attribute value from element
    /// - Parameters:
    ///   - name: Attribute name
    ///   - element: Source element
    /// - Returns: Attribute value or nil
    func getAttribute(name: String, from element: XMLElement) -> String?
    
    // MARK: - Async Methods
    
    /// Asynchronously creates a new XMLElement with attributes
    /// - Parameters:
    ///   - name: Element name
    ///   - attributes: Dictionary of attributes
    /// - Returns: New XMLElement
    func createElement(name: String, attributes: [String: String]) async -> XMLElement
    
    /// Asynchronously adds child element to parent
    /// - Parameters:
    ///   - child: Child element to add
    ///   - parent: Parent element
    func addChild(_ child: XMLElement, to parent: XMLElement) async
    
    /// Asynchronously sets attribute on element
    /// - Parameters:
    ///   - name: Attribute name
    ///   - value: Attribute value
    ///   - element: Target element
    func setAttribute(name: String, value: String, on element: XMLElement) async
    
    /// Asynchronously gets attribute value from element
    /// - Parameters:
    ///   - name: Attribute name
    ///   - element: Source element
    /// - Returns: Attribute value or nil
    func getAttribute(name: String, from element: XMLElement) async -> String?
} 
