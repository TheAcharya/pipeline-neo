//
//  FCPXMLAttribute.swift
//  Pipeline Neo • https://github.com/TheAcharya/pipeline-neo
//  © 2026 • Licensed under MIT License


//
//	Protocol for FCPXML attributes with attribute name.
//

import Foundation
import SwiftTimecode

public protocol FCPXMLAttribute {
    /// The XML attribute name.
    static var attributeName: String { get }
}
