//
//  FCPXMLParserDelegate.swift
//  Pipeline Neo • https://github.com/TheAcharya/pipeline-neo
//  © 2025 • Licensed under MIT License
//

import Foundation

/// An XMLParser delegate for parsing roles and IDs from FCPXML documents.
///
/// This delegate efficiently extracts roles, resource IDs, and text style IDs
/// from FCPXML documents during parsing.
final class FCPXMLParserDelegate: NSObject, XMLParserDelegate {
    
    // MARK: - Private Properties
    
    /// All roles found by the parser
    private var foundRoles: Set<String> = []
    
    /// All resource IDs found by the parser
    private var foundResourceIDs: Set<String> = []
    
    /// All text style IDs found by the parser
    private var foundTextStyleIDs: Set<String> = []
    
    // MARK: - Public Properties
    
    /// The unique role values found
    var roles: [String] {
        Array(foundRoles).sorted()
    }
    
    /// The unique resource ID strings found
    var resourceIDs: [String] {
        Array(foundResourceIDs).sorted()
    }
    
    /// The unique ID numbers from resource IDs that follow the convention "rN" where N is an integer.
    var resourceIDNumbers: [Int] {
        resourceIDs
            .compactMap { resourceID in
                guard resourceID.hasPrefix("r") else { return nil }
                let idSlice = String(resourceID.dropFirst())
                return Int(idSlice)
            }
            .sorted()
    }
    
    /// The largest resource ID number used in the document.
    var lastResourceIDNumber: Int {
        resourceIDNumbers.last ?? 0
    }
    
    /// The unique text style ID strings found
    var textStyleIDs: [String] {
        Array(foundTextStyleIDs).sorted()
    }
    
    /// The unique ID numbers from text style IDs that follow the convention "tsN" where N is an integer.
    var textStyleIDNumbers: [Int] {
        textStyleIDs
            .compactMap { textStyleID in
                guard textStyleID.hasPrefix("ts") else { return nil }
                let idSlice = String(textStyleID.dropFirst(2))
                return Int(idSlice)
            }
            .sorted()
    }
    
    /// The largest text style ID number used in the document.
    var lastTextStyleIDNumber: Int {
        textStyleIDNumbers.last ?? 0
    }
    
    // MARK: - XMLParserDelegate
    
    /// An XMLParserDelegate function that retrieves roles and resource IDs from an FCPXML file.
    ///
    /// This method should not be called explicitly. Call the method parseFCPXIDsAndRoles() instead.
    public func parser(
        _ parser: XMLParser,
        didStartElement elementName: String,
        namespaceURI: String?,
        qualifiedName qName: String?,
        attributes attributeDict: [String: String]
    ) {
        for (key, value) in attributeDict {
            switch key {
            case "id":
                if value.hasPrefix("ts") {
                    foundTextStyleIDs.insert(value)
                } else if value.hasPrefix("r") {
                    foundResourceIDs.insert(value)
                }
                
            case "role":
                foundRoles.insert(value)
                
            default:
                break
            }
        }
    }
}
