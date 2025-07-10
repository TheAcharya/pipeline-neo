//
//  ErrorHandler.swift
//  Pipeline Neo • https://github.com/TheAcharya/pipeline-neo
//  © 2025 • Licensed under MIT License
//

import Foundation

/// Implementation of error handling operations
@available(macOS 12.0, *)
public final class ErrorHandler: ErrorHandling, Sendable {
    
    public init() {}
    
    // MARK: - ErrorHandling Implementation
    
    public func handleParsingError(_ error: Error) -> String {
        if let fcpxmlError = error as? FCPXMLError {
            switch fcpxmlError {
            case .parsingFailed(let underlyingError):
                return "FCPXML parsing failed: \(underlyingError.localizedDescription)"
            case .invalidFormat:
                return "Invalid FCPXML format"
            case .unsupportedVersion:
                return "Unsupported FCPXML version"
            case .validationFailed(let message):
                return "Validation failed: \(message)"
            case .timecodeConversionFailed(let message):
                return "Timecode conversion failed: \(message)"
            case .documentOperationFailed(let message):
                return "Document operation failed: \(message)"
            }
        }
        return "Parsing error: \(error.localizedDescription)"
    }
    
    public func handleValidationError(_ error: Error) -> String {
        return "Validation error: \(error.localizedDescription)"
    }
    
    public func handleTimecodeError(_ error: Error) -> String {
        return "Timecode conversion error: \(error.localizedDescription)"
    }
} 