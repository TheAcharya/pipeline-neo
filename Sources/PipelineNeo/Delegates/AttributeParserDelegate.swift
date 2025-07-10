//
//  AttributeParserDelegate.swift
//  Pipeline Neo • https://github.com/TheAcharya/pipeline-neo
//  © 2025 • Licensed under MIT License
//

import Foundation

/// An XMLParser delegate for parsing attributes in XMLElement objects.
@available(macOS 12.0, *)
final class AttributeParserDelegate: NSObject, XMLParserDelegate, @unchecked Sendable {
    
    private let attribute: String
    private let elementName: String?
    	private var parsedValues: [String] = []
    
    	init(attribute: String, elementName: String? = nil) {
		self.attribute = attribute
		self.elementName = elementName
		super.init()
	}
	
	init(element: XMLElement, attribute: String, inElementsWithName elementName: String?) {
		self.attribute = attribute
		self.elementName = elementName
		super.init()
		
		let xmlDoc = XMLDocument(rootElement: element.copy() as? XMLElement)
		let parser = XMLParser(data: xmlDoc.xmlData)
		parser.delegate = self
		parser.parse()
	}
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        if let targetElementName = self.elementName, elementName != targetElementName {
            return
        }
        
        		if let value = attributeDict[attribute] {
			parsedValues.append(value)
		}
    }
    
    	func getValues() -> [String] {
		return parsedValues
	}
}

