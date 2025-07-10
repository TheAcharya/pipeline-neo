//
//  FCPXMLParserDelegate.swift
//  Pipeline Neo • https://github.com/TheAcharya/pipeline-neo
//  © 2025 • Licensed under MIT License
//


import Foundation

/// An XMLParser delegate for parsing roles and IDs from FCPXML documents.
@available(macOS 12.0, *)
final class FCPXMLParserDelegate: NSObject, XMLParserDelegate, @unchecked Sendable {
    
    /// All roles found by the parser
    private var foundRoles: [String] = []
    
    /// All resource IDs found by the parser
    private var foundResourceIDs: [String] = []
    
    /// All text style IDs found by the parser
    private var foundTextStyleIDs: [String] = []
    
    override init() {
        super.init()
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        
        // Parse roles
        if let role = attributeDict["role"] {
            if !foundRoles.contains(role) {
                foundRoles.append(role)
            }
        }
        
        // Parse resource IDs
        if let id = attributeDict["id"] {
            if !foundResourceIDs.contains(id) {
                foundResourceIDs.append(id)
            }
        }
        
        // Parse text style IDs
        if let textStyleID = attributeDict["textStyleID"] {
            if !foundTextStyleIDs.contains(textStyleID) {
                foundTextStyleIDs.append(textStyleID)
            }
        }
    }
    
    func getRoles() -> [String] {
        return foundRoles
    }
    
    func getResourceIDs() -> [String] {
        return foundResourceIDs
    }
    
    func getTextStyleIDs() -> [String] {
        return foundTextStyleIDs
    }
}
