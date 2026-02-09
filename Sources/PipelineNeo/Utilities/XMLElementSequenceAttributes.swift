//
//  XMLElementSequenceAttributes.swift
//  Pipeline Neo • https://github.com/TheAcharya/pipeline-neo
//  © 2026 • Licensed under MIT License


//
//	Sequence extensions for finding elements by attributes.
//

import Foundation
import SwiftExtensions

extension Sequence where Element == XMLElement {
    /// Returns the first element that has the given attribute, and the attribute's string value.
    func first(withAttribute name: String) -> (XMLElement, String)? {
        for element in self {
            if let value = element.attribute(forName: name)?.stringValue {
                return (element, value)
            }
        }
        return nil
    }

    /// Returns the first element where the attribute has the given value.
    func first(whereAttribute name: String, hasValue value: String) -> XMLElement? {
        for element in self {
            if element.attribute(forName: name)?.stringValue == value {
                return element
            }
        }
        return nil
    }
}
