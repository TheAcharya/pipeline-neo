//
//  Validate.swift
//  Pipeline Neo • https://github.com/TheAcharya/pipeline-neo
//  © 2026 • Licensed under MIT License
//

//
//  Perform robust validation of FCPXML/FCPXMLD (used by --validate).
//

import Foundation
import PipelineNeo

enum Validate {
    /// Loads the FCPXML/FCPXMLD at the given URL, runs semantic and DTD validation, and prints the report.
    /// Throws `ValidateError.validationFailed` when the document is invalid (CLI exits non-zero).
    static func run(fcpxmlPath: URL, logger: PipelineLogger = NoOpPipelineLogger(), showProgress: Bool = true) throws {
        let bar: ProgressBar? = showProgress ? ProgressBar(total: 1, desc: "Validating") : nil
        let service = FCPXMLService(logger: logger)
        let document = try service.parseFCPXML(from: fcpxmlPath)
        let report = service.performValidation(document)
        bar?.update(1)
        bar?.close()
        print(report.summary)
        if !report.isValid {
            print(report.detailedDescription)
            throw ValidateError.validationFailed(report: report)
        }
    }
}

enum ValidateError: Error, LocalizedError {
    case validationFailed(report: DocumentValidationReport)

    var errorDescription: String? {
        switch self {
        case .validationFailed(let report):
            return report.summary
        }
    }
}
