//
//  AttributeParserDelegate.swift
//  Pipeline Neo • https://github.com/TheAcharya/pipeline-neo
//  © 2025 • Licensed under MIT License
//

import Foundation
import CoreMedia

/// An XMLParser delegate for parsing attributes in XMLElement objects.
///
/// This delegate efficiently extracts attribute values from XML elements
/// during parsing operations.
final class AttributeParserDelegate: NSObject, XMLParserDelegate {
    
    // MARK: - Properties
    
    /// The attribute name to search for
    private let attribute: String
    
    /// The element name to filter by (optional)
    private let elementName: String?
    
    /// The values found for the specified attribute
    private(set) var values: [String] = []
    
    // MARK: - Initialization
    
    /// Initializes the delegate with the element and attribute to search for.
    ///
    /// - Parameters:
    ///   - element: The XMLElement to parse
    ///   - attribute: The attribute name to search for
    ///   - elementName: Optional element name to filter by
    init(element: XMLElement, attribute: String, inElementsWithName elementName: String? = nil) {
        self.attribute = attribute
        self.elementName = elementName
        
        super.init()
        
        // Parse the element
        let xmlDoc = XMLDocument(rootElement: element.copy() as? XMLElement)
        
        let parser = XMLParser(data: xmlDoc.xmlData)
        parser.delegate = self
        parser.parse()
    }
    
    // MARK: - XMLParserDelegate
    
    func parser(
        _ parser: XMLParser,
        didStartElement elementName: String,
        namespaceURI: String?,
        qualifiedName qName: String?,
        attributes attributeDict: [String: String]
    ) {
        // Check if we should filter by element name
        if let targetElementName = self.elementName {
            guard elementName == targetElementName else { return }
        }
        
        // Extract the attribute value if it exists
        if let value = attributeDict[self.attribute] {
            values.append(value)
        }
    }
}

