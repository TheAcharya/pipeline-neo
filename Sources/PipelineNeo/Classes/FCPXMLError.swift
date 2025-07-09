//
//  FCPXMLError.swift
//  Pipeline Neo • https://github.com/TheAcharya/pipeline-neo
//  © 2025 • Licensed under MIT License
//

import Foundation
import CoreMedia

/// Comprehensive error types for FCPXML operations.
///
/// This enum provides detailed error information for various failure scenarios
/// when working with FCPXML documents.
public enum FCPXMLError: LocalizedError, Sendable {
    
    // MARK: - Time-Related Errors
    
    /// The time format is invalid or cannot be parsed.
    case invalidTimeFormat(String)
    
    /// The time value is out of valid range.
    case timeOutOfRange(CMTime, String)
    
    /// The frame duration is invalid.
    case invalidFrameDuration(CMTime)
    
    // MARK: - XML Document Errors
    
    /// The XML document is invalid or corrupted.
    case invalidXMLDocument(String?)
    
    /// The XML document is missing required elements.
    case missingRequiredElement(String)
    
    /// The XML document has an unsupported version.
    case unsupportedFCPXMLVersion(String)
    
    // MARK: - Element Errors
    
    /// A required element is missing.
    case missingElement(String)
    
    /// A required attribute is missing.
    case missingAttribute(String, String)
    
    /// An element has an invalid value.
    case invalidElementValue(String, String)
    
    /// An attribute has an invalid value.
    case invalidAttributeValue(String, String, String)
    
    // MARK: - Resource Errors
    
    /// A resource with the specified ID was not found.
    case resourceNotFound(String)
    
    /// A resource ID is invalid or malformed.
    case invalidResourceID(String)
    
    /// A resource reference is broken.
    case brokenResourceReference(String, String)
    
    // MARK: - File I/O Errors
    
    /// Failed to read the FCPXML file.
    case fileReadError(URL, any Error)
    
    /// Failed to write the FCPXML file.
    case fileWriteError(URL, any Error)
    
    /// The file does not exist at the specified path.
    case fileNotFound(URL)
    
    /// Insufficient permissions to access the file.
    case insufficientPermissions(URL)
    
    // MARK: - Validation Errors
    
    /// The FCPXML document failed validation.
    case validationFailed([String])
    
    /// The document structure is invalid.
    case invalidDocumentStructure(String)
    
    // MARK: - Concurrency Errors
    
    /// A concurrency-related error occurred.
    case concurrencyError(String)
    
    /// An operation was cancelled.
    case cancelled
    
    // MARK: - LocalizedError Conformance
    
    public var errorDescription: String? {
        switch self {
        case .invalidTimeFormat(let timeString):
            return "Invalid time format: '\(timeString)'"
            
        case .timeOutOfRange(let time, let context):
            return "Time value \(time.fcpxmlString) is out of range for \(context)"
            
        case .invalidFrameDuration(let duration):
            return "Invalid frame duration: \(duration.fcpxmlString)"
            
        case .invalidXMLDocument(let details):
            if let details = details {
                return "Invalid XML document: \(details)"
            } else {
                return "Invalid XML document"
            }
            
        case .missingRequiredElement(let elementName):
            return "Missing required element: '\(elementName)'"
            
        case .unsupportedFCPXMLVersion(let version):
            return "Unsupported FCPXML version: '\(version)'"
            
        case .missingElement(let elementName):
            return "Missing element: '\(elementName)'"
            
        case .missingAttribute(let attributeName, let elementName):
            return "Missing attribute '\(attributeName)' in element '\(elementName)'"
            
        case .invalidElementValue(let elementName, let value):
            return "Invalid value '\(value)' for element '\(elementName)'"
            
        case .invalidAttributeValue(let attributeName, let value, let elementName):
            return "Invalid value '\(value)' for attribute '\(attributeName)' in element '\(elementName)'"
            
        case .resourceNotFound(let resourceID):
            return "Resource not found: '\(resourceID)'"
            
        case .invalidResourceID(let resourceID):
            return "Invalid resource ID: '\(resourceID)'"
            
        case .brokenResourceReference(let resourceID, let context):
            return "Broken resource reference '\(resourceID)' in \(context)"
            
        case .fileReadError(let url, let underlyingError):
            return "Failed to read file at \(url.path): \(underlyingError.localizedDescription)"
            
        case .fileWriteError(let url, let underlyingError):
            return "Failed to write file at \(url.path): \(underlyingError.localizedDescription)"
            
        case .fileNotFound(let url):
            return "File not found at \(url.path)"
            
        case .insufficientPermissions(let url):
            return "Insufficient permissions to access file at \(url.path)"
            
        case .validationFailed(let errors):
            return "Validation failed: \(errors.joined(separator: "; "))"
            
        case .invalidDocumentStructure(let details):
            return "Invalid document structure: \(details)"
            
        case .concurrencyError(let details):
            return "Concurrency error: \(details)"
            
        case .cancelled:
            return "Operation was cancelled"
        }
    }
    
    public var failureReason: String? {
        switch self {
        case .invalidTimeFormat:
            return "The time string format does not match the expected FCPXML time format"
            
        case .timeOutOfRange:
            return "The time value exceeds the valid range for the operation"
            
        case .invalidFrameDuration:
            return "The frame duration must be a positive, non-zero value"
            
        case .invalidXMLDocument:
            return "The XML document structure is malformed or corrupted"
            
        case .missingRequiredElement:
            return "A required element is missing from the document structure"
            
        case .unsupportedFCPXMLVersion:
            return "The FCPXML version is not supported by this framework"
            
        case .missingElement:
            return "An expected element is missing from the document"
            
        case .missingAttribute:
            return "A required attribute is missing from an element"
            
        case .invalidElementValue:
            return "An element contains an invalid value"
            
        case .invalidAttributeValue:
            return "An attribute contains an invalid value"
            
        case .resourceNotFound:
            return "A referenced resource could not be found in the document"
            
        case .invalidResourceID:
            return "The resource ID format is invalid"
            
        case .brokenResourceReference:
            return "A resource reference points to a non-existent resource"
            
        case .fileReadError:
            return "The file could not be read due to an I/O error"
            
        case .fileWriteError:
            return "The file could not be written due to an I/O error"
            
        case .fileNotFound:
            return "The specified file does not exist"
            
        case .insufficientPermissions:
            return "The application lacks sufficient permissions to access the file"
            
        case .validationFailed:
            return "The document failed one or more validation checks"
            
        case .invalidDocumentStructure:
            return "The document structure violates FCPXML specifications"
            
        case .concurrencyError:
            return "A concurrency-related issue occurred during the operation"
            
        case .cancelled:
            return "The operation was cancelled by the user or system"
        }
    }
    
    public var recoverySuggestion: String? {
        switch self {
        case .invalidTimeFormat:
            return "Ensure the time string follows the format 'value/timescale' or 'value'"
            
        case .timeOutOfRange:
            return "Check that the time value is within the valid range for your use case"
            
        case .invalidFrameDuration:
            return "Provide a valid frame duration greater than zero"
            
        case .invalidXMLDocument:
            return "Verify that the XML document is well-formed and follows FCPXML specifications"
            
        case .missingRequiredElement:
            return "Add the missing required element to the document structure"
            
        case .unsupportedFCPXMLVersion:
            return "Use a supported FCPXML version or update the framework"
            
        case .missingElement, .missingAttribute:
            return "Add the missing element or attribute to the document"
            
        case .invalidElementValue, .invalidAttributeValue:
            return "Provide a valid value for the element or attribute"
            
        case .resourceNotFound, .brokenResourceReference:
            return "Ensure all referenced resources exist in the document"
            
        case .invalidResourceID:
            return "Use a valid resource ID format (e.g., 'r1', 'r2', etc.)"
            
        case .fileReadError, .fileWriteError:
            return "Check file permissions and ensure the file is not corrupted"
            
        case .fileNotFound:
            return "Verify the file path and ensure the file exists"
            
        case .insufficientPermissions:
            return "Grant appropriate file access permissions to the application"
            
        case .validationFailed:
            return "Review the validation errors and correct the document structure"
            
        case .invalidDocumentStructure:
            return "Ensure the document follows the FCPXML specification"
            
        case .concurrencyError:
            return "Retry the operation or ensure proper concurrency handling"
            
        case .cancelled:
            return "The operation can be retried if needed"
        }
    }
}

// MARK: - Error Extensions

extension FCPXMLError {
    
    /// Returns whether this error is recoverable.
    public var isRecoverable: Bool {
        switch self {
        case .invalidTimeFormat, .timeOutOfRange, .invalidFrameDuration,
             .missingElement, .missingAttribute, .invalidElementValue, .invalidAttributeValue,
             .resourceNotFound, .invalidResourceID, .brokenResourceReference,
             .validationFailed, .invalidDocumentStructure:
            return true
            
        case .invalidXMLDocument, .missingRequiredElement, .unsupportedFCPXMLVersion,
             .fileReadError, .fileWriteError, .fileNotFound, .insufficientPermissions,
             .concurrencyError, .cancelled:
            return false
        }
    }
    
    /// Returns whether this error is related to file I/O operations.
    public var isFileIOError: Bool {
        switch self {
        case .fileReadError, .fileWriteError, .fileNotFound, .insufficientPermissions:
            return true
        default:
            return false
        }
    }
    
    /// Returns whether this error is related to validation.
    public var isValidationError: Bool {
        switch self {
        case .validationFailed, .invalidDocumentStructure, .missingRequiredElement,
             .unsupportedFCPXMLVersion:
            return true
        default:
            return false
        }
    }
} 