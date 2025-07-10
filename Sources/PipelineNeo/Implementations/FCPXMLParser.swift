//
//  FCPXMLParser.swift
//  Pipeline Neo • https://github.com/TheAcharya/pipeline-neo
//  © 2025 • Licensed under MIT License
//

import Foundation

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
    
    // MARK: - FCPXMLElementFiltering Implementation
    
    public func filter(elements: [XMLElement], ofTypes types: [FCPXMLElementType]) -> [XMLElement] {
        return elements.filter { element in
            guard let elementName = element.name else { return false }
            return types.contains { type in
                elementName == type.rawValue
            }
        }
    }
    
    public func findElements(withResourceID resourceID: String, in elements: [XMLElement]) -> [XMLElement] {
        return elements.filter { element in
            element.attribute(forName: "id")?.stringValue == resourceID
        }
    }
} 