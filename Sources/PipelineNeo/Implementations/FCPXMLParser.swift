//
//  FCPXMLParser.swift
//  Pipeline Neo • https://github.com/TheAcharya/pipeline-neo
//  © 2025 • Licensed under MIT License
//

import Foundation
import SwiftExtensions

/// Implementation of FCPXML parsing operations
@available(macOS 12.0, *)
public final class FCPXMLParser: FCPXMLParsing, FCPXMLElementFiltering, Sendable {
    
    public init() {}
    
    // MARK: - FCPXMLParsing Implementation
    
    public func parse(_ data: Data) throws -> XMLDocument {
        do {
            let document = try XMLDocument(data: data)
            return document
        } catch {
            throw FCPXMLError.parsingFailed(error)
        }
    }
    
    public func parse(from url: URL) throws -> XMLDocument {
        do {
            let data = try Data(contentsOf: url)
            return try parse(data)
        } catch {
            throw FCPXMLError.parsingFailed(error)
        }
    }
    
    public func validate(_ document: XMLDocument) -> Bool {
        // Basic validation - can be extended with DTD validation
        guard let rootElement = document.rootElement() else { return false }
        return rootElement.name == "fcpxml"
    }
    
    // MARK: - FCPXMLParsing Async Implementation
    
    public func parse(_ data: Data) async throws -> XMLDocument {
        // For now, just call the synchronous version
        // In a real implementation, this could be moved to a background queue
        do {
            let document = try XMLDocument(data: data)
            return document
        } catch {
            throw FCPXMLError.parsingFailed(error)
        }
    }
    
    public func parse(from url: URL) async throws -> XMLDocument {
        // For now, just call the synchronous version
        // In a real implementation, this could be moved to a background queue
        do {
            let data = try Data(contentsOf: url)
            let document = try XMLDocument(data: data)
            return document
        } catch {
            throw FCPXMLError.parsingFailed(error)
        }
    }
    
    public func validate(_ document: XMLDocument) async -> Bool {
        // For now, just call the synchronous version
        guard let rootElement = document.rootElement() else { return false }
        return rootElement.name == "fcpxml"
    }
    
    // MARK: - FCPXMLElementFiltering Implementation
    
    /// Returns the name of the first child element (used for media → multicam/compound inference).
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
                return elementName == type.rawValue
            }
        }
    }

    public func filter(elements: [XMLElement], ofTypes types: [FCPXMLElementType]) -> [XMLElement] {
        return Self.filterElements(elements, ofTypes: types)
    }
    
    public func findElements(withResourceID resourceID: String, in elements: [XMLElement]) -> [XMLElement] {
        elements.filter { $0.stringValue(forAttributeNamed: "id") == resourceID }
    }
    
    // MARK: - FCPXMLElementFiltering Async Implementation
    
    public func filter(elements: [XMLElement], ofTypes types: [FCPXMLElementType]) async -> [XMLElement] {
        return Self.filterElements(elements, ofTypes: types)
    }
    
    public func findElements(withResourceID resourceID: String, in elements: [XMLElement]) async -> [XMLElement] {
        elements.filter { $0.stringValue(forAttributeNamed: "id") == resourceID }
    }
} 