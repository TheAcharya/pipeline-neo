//
//  FCPXMLElementModelType.swift
//  Pipeline Neo • https://github.com/TheAcharya/pipeline-neo
//  © 2026 • Licensed under MIT License
//

//
//	Generic struct for element model types.
//

import Foundation

// MARK: - ElementModelType

extension FinalCutPro.FCPXML {
    public struct ElementModelType<ModelType: FCPXMLElement>: FCPXMLElementModelTypeProtocol {
        public var supportedElementTypes: Set<FinalCutPro.FCPXML.ElementType> {
            ModelType.supportedElementTypes
        }
        
        init() { }
    }
}
