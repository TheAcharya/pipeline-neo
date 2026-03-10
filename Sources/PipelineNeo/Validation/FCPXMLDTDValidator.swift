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
///
/// DTD validation is only available on platforms with Foundation XML support (macOS, Linux).
/// On other platforms, the validator returns a `.dtdValidation` error indicating unavailability.
@available(macOS 12.0, *)
public struct FCPXMLDTDValidator: Sendable {

    public init() {}

    /// Validates the document against the specified version's DTD.
    ///
    /// - Parameters:
    ///   - document: The FCPXML document to validate.
    ///   - version: The FCPXML version whose DTD to use.
    /// - Returns: `.success` if valid; otherwise a result with a single `dtdValidation` error.
    public func validate(_ document: any PNXMLDocument, version: FCPXMLVersion) -> ValidationResult {
        #if canImport(FoundationXML) || os(macOS)
        guard let foundationDoc = document as? FoundationXMLDocument else {
            return .error(ValidationError(
                type: .dtdValidation,
                message: "DTD validation requires a Foundation-backed document",
                context: ["version": version.stringValue]
            ))
        }
        do {
            try foundationDoc.validateFCPXMLAgainst(version: version)
            return .success
        } catch {
            return .error(ValidationError(
                type: .dtdValidation,
                message: error.localizedDescription,
                context: ["version": version.stringValue]
            ))
        }
        #else
        return .error(ValidationError(
            type: .dtdValidation,
            message: "DTD validation is not available on this platform",
            context: ["version": version.stringValue]
        ))
        #endif
    }
}
