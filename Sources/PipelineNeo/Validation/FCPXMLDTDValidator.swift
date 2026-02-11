//
//  FCPXMLDTDValidator.swift
//  Pipeline Neo • https://github.com/TheAcharya/pipeline-neo
//  © 2026 • Licensed under MIT License
//

//
//	DTD schema validator for FCPXML documents.
//

import Foundation

/// Validates an FCPXML document against the DTD for a given FCPXML version.
@available(macOS 12.0, *)
public struct FCPXMLDTDValidator: Sendable {

    public init() {}

    /// Validates the document against the specified version's DTD.
    ///
    /// - Parameters:
    ///   - document: The FCPXML document to validate.
    ///   - version: The FCPXML version whose DTD to use.
    /// - Returns: `.success` if valid; otherwise a result with a single `dtdValidation` error.
    public func validate(_ document: XMLDocument, version: FCPXMLVersion) -> ValidationResult {
        do {
            try document.validateFCPXMLAgainst(version: version)
            return .success
        } catch {
            return .error(ValidationError(
                type: .dtdValidation,
                message: error.localizedDescription,
                context: ["version": version.stringValue]
            ))
        }
    }
}
