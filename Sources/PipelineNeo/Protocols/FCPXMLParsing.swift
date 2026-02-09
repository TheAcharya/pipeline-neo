//
//  FCPXMLParsing.swift
//  Pipeline Neo • https://github.com/TheAcharya/pipeline-neo
//  © 2026 • Licensed under MIT License


//
//	Protocols for FCPXML parsing and element filtering operations.
//

import Foundation

/// Protocol defining FCPXML parsing operations
@available(macOS 12.0, *)
public protocol FCPXMLParsing: Sendable {
    /// Parses FCPXML data into an XMLDocument
    /// - Parameter data: The FCPXML data to parse
    /// - Returns: An XMLDocument representation
    /// - Throws: FCPXMLError if parsing fails
    func parse(_ data: Data) throws -> XMLDocument
    
    /// Parses FCPXML from a URL
    /// - Parameter url: The URL containing FCPXML data
    /// - Returns: An XMLDocument representation
    /// - Throws: FCPXMLError if parsing fails
    func parse(from url: URL) throws -> XMLDocument
    
    /// Checks whether the document has a valid fcpxml root element.
    ///
    /// This is a lightweight structural check, not full DTD validation.
    /// For semantic validation use `FCPXMLValidator`; for DTD validation use `FCPXMLDTDValidator`.
    ///
    /// - Parameter document: The XMLDocument to check
    /// - Returns: True if the root element is `fcpxml`, false otherwise
    func validate(_ document: XMLDocument) -> Bool
    
    // MARK: - Async Methods
    
    /// Asynchronously parses FCPXML data into an XMLDocument
    /// - Parameter data: The FCPXML data to parse
    /// - Returns: An XMLDocument representation
    /// - Throws: FCPXMLError if parsing fails
    func parse(_ data: Data) async throws -> XMLDocument
    
    /// Asynchronously parses FCPXML from a URL
    /// - Parameter url: The URL containing FCPXML data
    /// - Returns: An XMLDocument representation
    /// - Throws: FCPXMLError if parsing fails
    func parse(from url: URL) async throws -> XMLDocument
    
    /// Asynchronously checks whether the document has a valid fcpxml root element.
    /// - Parameter document: The XMLDocument to check
    /// - Returns: True if the root element is `fcpxml`, false otherwise
    func validate(_ document: XMLDocument) async -> Bool
}

/// Protocol defining FCPXML element filtering operations
@available(macOS 12.0, *)
public protocol FCPXMLElementFiltering: Sendable {
    /// Filters elements by type
    /// - Parameters:
    ///   - elements: Array of XMLElements to filter
    ///   - types: Array of FCPXMLElementType to match
    /// - Returns: Filtered array of XMLElements
    func filter(elements: [XMLElement], ofTypes types: [FCPXMLElementType]) -> [XMLElement]
    
    /// Finds elements by resource ID
    /// - Parameters:
    ///   - elements: Array of XMLElements to search
    ///   - resourceID: The resource ID to match
    /// - Returns: Array of matching XMLElements
    func findElements(withResourceID resourceID: String, in elements: [XMLElement]) -> [XMLElement]
    
    // MARK: - Async Methods
    
    /// Asynchronously filters elements by type
    /// - Parameters:
    ///   - elements: Array of XMLElements to filter
    ///   - types: Array of FCPXMLElementType to match
    /// - Returns: Filtered array of XMLElements
    func filter(elements: [XMLElement], ofTypes types: [FCPXMLElementType]) async -> [XMLElement]
    
    /// Asynchronously finds elements by resource ID
    /// - Parameters:
    ///   - elements: Array of XMLElements to search
    ///   - resourceID: The resource ID to match
    /// - Returns: Array of matching XMLElements
    func findElements(withResourceID resourceID: String, in elements: [XMLElement]) async -> [XMLElement]
} 
