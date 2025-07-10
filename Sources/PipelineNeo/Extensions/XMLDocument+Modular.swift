//
//  XMLDocument+Modular.swift
//  Pipeline Neo • https://github.com/TheAcharya/pipeline-neo
//  © 2025 • Licensed under MIT License
//

import Foundation

/// Modular XMLDocument extensions using dependency injection
@available(macOS 12.0, *)
public extension XMLDocument {
    
    /// Adds resource to document using injected document operations service
    /// - Parameters:
    ///   - resource: Resource element to add
    ///   - operations: Document operations service
    func addResource(_ resource: XMLElement, using operations: XMLDocumentOperations) {
        operations.addResource(resource, to: self)
    }
    
    /// Adds sequence to document using injected document operations service
    /// - Parameters:
    ///   - sequence: Sequence element to add
    ///   - operations: Document operations service
    func addSequence(_ sequence: XMLElement, using operations: XMLDocumentOperations) {
        operations.addSequence(sequence, to: self)
    }
    
    /// Saves document to URL using injected document operations service
    /// - Parameters:
    ///   - url: Target URL
    ///   - operations: Document operations service
    /// - Throws: Error if saving fails
    func save(to url: URL, using operations: XMLDocumentOperations) throws {
        try operations.saveDocument(self, to: url)
    }
    
    /// Validates document using injected parsing service
    /// - Parameter parser: FCPXML parsing service
    /// - Returns: True if valid, false otherwise
    func isValid(using parser: FCPXMLParsing) -> Bool {
        return parser.validate(self)
    }
} 