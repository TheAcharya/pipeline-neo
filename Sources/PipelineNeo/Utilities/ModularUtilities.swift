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
    
    // MARK: - Async Methods
    
    /// Asynchronously validates FCPXML document structure
    /// - Parameters:
    ///   - document: Document to validate
    ///   - parser: Parser service for validation
    /// - Returns: Validation result with error messages
    public static func validateDocument(_ document: XMLDocument, using parser: FCPXMLParsing) async -> (isValid: Bool, errors: [String]) {
        var errors: [String] = []
        
        let isValid = await parser.validate(document)
        if !isValid {
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
    
    /// Asynchronously processes FCPXML with error handling
    /// - Parameters:
    ///   - url: URL of FCPXML file
    ///   - service: FCPXML service
    ///   - errorHandler: Error handling service
    /// - Returns: Processed document or error
    public static func processFCPXML(
        from url: URL,
        using service: FCPXMLService,
        errorHandler: ErrorHandling
    ) async -> Result<XMLDocument, FCPXMLError> {
        do {
            let document = try await service.parseFCPXML(from: url)
            return .success(document)
        } catch {
            let errorMessage = errorHandler.handleParsingError(error)
            return .failure(FCPXMLError.parsingFailed(NSError(domain: "FCPXMLService", code: 1, userInfo: [NSLocalizedDescriptionKey: errorMessage])))
        }
    }
    
    /// Asynchronously processes multiple FCPXML files sequentially
    /// - Parameters:
    ///   - urls: Array of FCPXML file URLs
    ///   - service: FCPXML service
    ///   - errorHandler: Error handling service
    /// - Returns: Array of processed documents or errors
    public static func processMultipleFCPXML(
        from urls: [URL],
        using service: FCPXMLService,
        errorHandler: ErrorHandling
    ) async -> [Result<XMLDocument, FCPXMLError>] {
        var results: [Result<XMLDocument, FCPXMLError>] = []
        
        for url in urls {
            let result = await processFCPXML(from: url, using: service, errorHandler: errorHandler)
            results.append(result)
        }
        
        return results
    }
    
    /// Asynchronously converts timecodes for multiple elements sequentially
    /// - Parameters:
    ///   - elements: Array of XMLElements with time attributes
    ///   - timecodeConverter: Timecode converter service
    ///   - frameRate: Target frame rate
    /// - Returns: Array of converted timecodes
    public static func convertTimecodes(
        for elements: [XMLElement],
        using timecodeConverter: TimecodeConversion,
        frameRate: TimecodeFrameRate
    ) async -> [Timecode?] {
        var results: [Timecode?] = []
        
        for _ in elements {
            // Extract time from element (this would need to be implemented based on your XML structure)
            let time = CMTime.zero // Placeholder - implement actual time extraction
            let timecode = await timecodeConverter.timecode(from: time, frameRate: frameRate)
            results.append(timecode)
        }
        
        return results
    }
} 