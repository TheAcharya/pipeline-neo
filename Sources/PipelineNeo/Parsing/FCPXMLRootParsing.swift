//
//  FCPXMLRootParsing.swift
//  Pipeline Neo • https://github.com/TheAcharya/pipeline-neo
//  © 2026 • Licensed under MIT License
//

//
//	Root element parsing utilities.
//

import Foundation
import SwiftExtensions
import SwiftTimecode

extension XMLElement {
    /// FCPXML: Returns the root-level `fcpxml` element.
    /// This may be called on any element within a FCPXML.
    public var fcpRoot: XMLElement? {
        rootDocument?
            .rootElement() // `fcpxml` element
    }
}
