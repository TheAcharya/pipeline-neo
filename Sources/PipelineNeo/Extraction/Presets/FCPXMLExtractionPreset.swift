//
//  FCPXMLExtractionPreset.swift
//  Pipeline Neo • https://github.com/TheAcharya/pipeline-neo
//  © 2026 • Licensed under MIT License
//

//
//	Protocol for element extraction presets.
//

import Foundation

/// Protocol describing an element extraction preset for FCPXML.
public protocol FCPXMLExtractionPreset<Result> where Self: Sendable {
    associatedtype Result
    
    func perform(
        on extractable: XMLElement,
        scope: FinalCutPro.FCPXML.ExtractionScope
    ) async -> Result
}
