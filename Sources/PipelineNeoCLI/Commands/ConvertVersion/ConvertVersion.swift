//
//  ConvertVersion.swift
//  Pipeline Neo • https://github.com/TheAcharya/pipeline-neo
//  © 2026 • Licensed under MIT License

//
//
//  Convert FCPXML document to a target version and save (used by --convert-version).
//

import Foundation
import PipelineNeo

enum ConvertVersion {
    /// Loads the FCPXML at the given URL, converts it to the target version, and writes to output-dir.
    static func run(fcpxmlPath: URL, targetVersionString: String, outputDir: URL) throws {
        guard let targetVersion = FCPXMLVersion(string: targetVersionString) else {
            throw ConvertVersionError.unsupportedVersion(targetVersionString)
        }

        let loader = FCPXMLFileLoader()
        let document = try loader.loadDocument(from: fcpxmlPath)

        let service = FCPXMLService()
        let converted = try service.convertToVersion(document, targetVersion: targetVersion)

        let validationResult = service.validateDocumentAgainstDTD(converted, version: targetVersion)
        if !validationResult.isValid {
            throw ConvertVersionError.dtdValidationFailed(
                version: targetVersion.rawValue,
                message: validationResult.detailedDescription
            )
        }

        let baseName = fcpxmlPath.deletingPathExtension().lastPathComponent
        let outputFileName = "\(baseName)_\(targetVersion.rawValue).fcpxml"
        let outputURL = outputDir.appendingPathComponent(outputFileName)

        try service.saveAsFCPXML(converted, to: outputURL)
        print(outputURL.path)
    }
}

enum ConvertVersionError: Error, LocalizedError {
    case unsupportedVersion(String)
    case dtdValidationFailed(version: String, message: String)

    var errorDescription: String? {
        switch self {
        case .unsupportedVersion(let v):
            return "Unsupported FCPXML version: '\(v)'. Use a version between 1.5 and 1.14 (e.g. 1.10, 1.14)."
        case .dtdValidationFailed(let version, let message):
            return "DTD validation failed for FCPXML version \(version). The converted document does not conform to the schema.\n\(message)"
        }
    }
}
