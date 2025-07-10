//
//  ModularUtilities.swift
//  Pipeline Neo • https://github.com/TheAcharya/pipeline-neo
//  © 2025 • Licensed under MIT License
//

import Foundation
import CoreMedia
import TimecodeKit

/// Utility functions for modular FCPXML operations
@available(macOS 12.0, *)
public struct ModularUtilities {
    
    /// Creates a complete FCPXML processing pipeline with all dependencies
    /// - Returns: Configured FCPXMLService
    public static func createPipeline() -> FCPXMLService {
        let parser = FCPXMLParser()
        let timecodeConverter = TimecodeConverter()
        let documentManager = XMLDocumentManager()
        let errorHandler = ErrorHandler()
        
        return FCPXMLService(
            parser: parser,
            timecodeConverter: timecodeConverter,
            documentManager: documentManager,
            errorHandler: errorHandler
        )
    }
    
    /// Creates a custom pipeline with specific implementations
    /// - Parameters:
    ///   - parser: Custom parser implementation
    ///   - timecodeConverter: Custom timecode converter
    ///   - documentManager: Custom document manager
    ///   - errorHandler: Custom error handler
    /// - Returns: Configured FCPXMLService
    public static func createCustomPipeline(
        parser: FCPXMLParsing & FCPXMLElementFiltering,
        timecodeConverter: TimecodeConversion & FCPXMLTimeStringConversion & TimeConforming,
        documentManager: XMLDocumentOperations & XMLElementOperations,
        errorHandler: ErrorHandling
    ) -> FCPXMLService {
        return FCPXMLService(
            parser: parser,
            timecodeConverter: timecodeConverter,
            documentManager: documentManager,
            errorHandler: errorHandler
        )
    }
    
    /// Validates FCPXML document structure
    /// - Parameters:
    ///   - document: Document to validate
    ///   - parser: Parser service for validation
    /// - Returns: Validation result with error messages
    public static func validateDocument(_ document: XMLDocument, using parser: FCPXMLParsing) -> (isValid: Bool, errors: [String]) {
        var errors: [String] = []
        
        if !parser.validate(document) {
            errors.append("Invalid FCPXML document structure")
        }
        
        guard let rootElement = document.rootElement() else {
            errors.append("Missing root element")
            return (false, errors)
        }
        
        if rootElement.name != "fcpxml" {
            errors.append("Root element must be 'fcpxml'")
        }
        
        return (errors.isEmpty, errors)
    }
    
    /// Processes FCPXML with error handling
    /// - Parameters:
    ///   - url: URL of FCPXML file
    ///   - service: FCPXML service
    ///   - errorHandler: Error handling service
    /// - Returns: Processed document or error
    public static func processFCPXML(
        from url: URL,
        using service: FCPXMLService,
        errorHandler: ErrorHandling
    ) -> Result<XMLDocument, FCPXMLError> {
        do {
            let document = try service.parseFCPXML(from: url)
            return .success(document)
        } catch {
            let errorMessage = errorHandler.handleParsingError(error)
            return .failure(FCPXMLError.parsingFailed(NSError(domain: "FCPXMLService", code: 1, userInfo: [NSLocalizedDescriptionKey: errorMessage])))
        }
    }
} 