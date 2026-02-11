//
//  FCPXMLElementTextStyleDefinitionChildren.swift
//  Pipeline Neo • https://github.com/TheAcharya/pipeline-neo
//  © 2026 • Licensed under MIT License
//

//
//	Protocol for elements with text-style-def children.
//

import Foundation
import SwiftTimecode
import SwiftExtensions

public protocol FCPXMLElementTextStyleDefinitionChildren: FCPXMLElement {
    /// Child `text-style-def` elements.
    var fcpTextStyleDefinitions: LazyFilteredCompactMapSequence<[XMLNode], XMLElement> { get nonmutating set }
}

extension FCPXMLElementTextStyleDefinitionChildren {
    public var fcpTextStyleDefinitions: LazyFilteredCompactMapSequence<[XMLNode], XMLElement> {
        get { element.fcpTextStyleDefinitions }
        nonmutating set { element.fcpTextStyleDefinitions = newValue }
    }
}

extension XMLElement {
    // Note: returns bare XML; model objects not yet implemented for this element.
    
    /// FCPXML: Returns child `text-style-def` elements.
    public var fcpTextStyleDefinitions: LazyFilteredCompactMapSequence<[XMLNode], XMLElement> {
        get {
            childElements
                .filter(whereFCPElementType: .textStyleDef)
        }
        set {
            _updateChildElements(ofType: .textStyleDef, with: newValue)
        }
    }
}
