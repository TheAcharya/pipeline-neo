//
//  FCPXMLParser.swift
//  Pipeline Neo • https://github.com/TheAcharya/pipeline-neo
//  © 2026 • Licensed under MIT License
//

//
//	Implementation of FCPXML parsing and element filtering operations.
//

import Foundation
import SwiftExtensions

/// Default implementation of `FCPXMLParsing` and `FCPXMLElementFiltering`.
///
/// Delegates URL loading to `FCPXMLFileLoader` for unified file/bundle handling
/// and consistent FCPXML parse options.
@available(macOS 12.0, *)
public final class FCPXMLParser: FCPXMLParsing, FCPXMLElementFiltering, Sendable {
    
    /// Creates a new FCPXML parser.
    public init() {}
    
    // MARK: - Internal Sync Implementations
    
    private func _parse(_ data: Data) throws -> XMLDocument {
        do {
            let document = try XMLDocument(data: data)
            return document
        } catch {
            throw FCPXMLError.parsingFailed(error)
        }
    }
    
    private func _parse(from url: URL) throws -> XMLDocument {
        // Delegate to FCPXMLFileLoader for unified file/bundle loading with FCPXML-specific
        // parse options. This avoids duplicating the URL resolution and parse-option logic.
        let loader = FCPXMLFileLoader()
        do {
            return try loader.loadFCPXMLDocument(from: url)
        } catch let error as FCPXMLError {
            throw error
        } catch let error as FCPXMLLoadError {
            throw FCPXMLError.parsingFailed(error)
        } catch {
            throw FCPXMLError.parsingFailed(error)
        }
    }
    
    private func _validate(_ document: XMLDocument) -> Bool {
        guard let rootElement = document.rootElement() else { return false }
        return rootElement.name == "fcpxml"
    }
    
    // MARK: - FCPXMLParsing (Sync)
    
    /// Parses FCPXML from raw data.
    public func parse(_ data: Data) throws -> XMLDocument {
        try _parse(data)
    }
    
    /// Parses FCPXML from a file URL (supports .fcpxml and .fcpxmld bundles).
    public func parse(from url: URL) throws -> XMLDocument {
        try _parse(from: url)
    }
    
    /// Validates that the document has an fcpxml root element.
    public func validate(_ document: XMLDocument) -> Bool {
        _validate(document)
    }
    
    // MARK: - FCPXMLParsing (Async)
    
    /// Parses FCPXML from raw data asynchronously.
    public func parse(_ data: Data) async throws -> XMLDocument {
        try _parse(data)
    }
    
    /// Parses FCPXML from a file URL asynchronously.
    public func parse(from url: URL) async throws -> XMLDocument {
        try _parse(from: url)
    }
    
    /// Validates that the document has an fcpxml root element asynchronously.
    public func validate(_ document: XMLDocument) async -> Bool {
        _validate(document)
    }
    
    // MARK: - FCPXMLElementFiltering (Sync)
    
    /// Returns the name of the first child element (used for media to multicam/compound inference).
    private static func firstChildElementName(of element: XMLElement) -> String? {
        element.childElements.first.flatMap(\.name)
    }

    private static func filterElements(_ elements: [XMLElement], ofTypes types: [FCPXMLElementType]) -> [XMLElement] {
        return elements.filter { element in
            guard let elementName = element.name else { return false }
            return types.contains { type in
                if type == .multicamResource {
                    guard elementName == "media" else { return false }
                    return Self.firstChildElementName(of: element) == "multicam"
                }
                if type == .compoundResource {
                    guard elementName == "media" else { return false }
                    return Self.firstChildElementName(of: element) == "sequence"
                }
                if type == .none { return false }
                return elementName == type.rawValue
            }
        }
    }

    /// Filters elements by their FCPXML element types.
    public func filter(elements: [XMLElement], ofTypes types: [FCPXMLElementType]) -> [XMLElement] {
        Self.filterElements(elements, ofTypes: types)
    }
    
    /// Finds elements matching the given resource ID attribute.
    public func findElements(withResourceID resourceID: String, in elements: [XMLElement]) -> [XMLElement] {
        elements.filter { $0.stringValue(forAttributeNamed: "id") == resourceID }
    }
    
    // MARK: - FCPXMLElementFiltering (Async)
    
    /// Filters elements by their FCPXML element types asynchronously.
    public func filter(elements: [XMLElement], ofTypes types: [FCPXMLElementType]) async -> [XMLElement] {
        Self.filterElements(elements, ofTypes: types)
    }
    
    /// Finds elements matching the given resource ID attribute asynchronously.
    public func findElements(withResourceID resourceID: String, in elements: [XMLElement]) async -> [XMLElement] {
        elements.filter { $0.stringValue(forAttributeNamed: "id") == resourceID }
    }
}
