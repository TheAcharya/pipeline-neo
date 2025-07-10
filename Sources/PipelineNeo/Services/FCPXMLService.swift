//
//  FCPXMLService.swift
//  Pipeline Neo • https://github.com/TheAcharya/pipeline-neo
//  © 2025 • Licensed under MIT License
//

import Foundation
import CoreMedia
import TimecodeKit

/// Main service for FCPXML operations, orchestrating modular components
@available(macOS 12.0, *)
public final class FCPXMLService: Sendable {
    
    // MARK: - Dependencies
    
    private let parser: FCPXMLParsing & FCPXMLElementFiltering
    private let timecodeConverter: TimecodeConversion & FCPXMLTimeStringConversion & TimeConforming
    private let documentManager: XMLDocumentOperations & XMLElementOperations
    private let errorHandler: ErrorHandling
    
    // MARK: - Initialisation
    
    public init(
        parser: FCPXMLParsing & FCPXMLElementFiltering = FCPXMLParser(),
        timecodeConverter: TimecodeConversion & FCPXMLTimeStringConversion & TimeConforming = TimecodeConverter(),
        documentManager: XMLDocumentOperations & XMLElementOperations = XMLDocumentManager(),
        errorHandler: ErrorHandling = ErrorHandler()
    ) {
        self.parser = parser
        self.timecodeConverter = timecodeConverter
        self.documentManager = documentManager
        self.errorHandler = errorHandler
    }
    
    // MARK: - Public API
    
    /// Parses FCPXML from data
    /// - Parameter data: FCPXML data
    /// - Returns: XMLDocument
    /// - Throws: FCPXMLError
    public func parseFCPXML(from data: Data) throws -> XMLDocument {
        do {
            return try parser.parse(data)
        } catch {
            let errorMessage = errorHandler.handleParsingError(error)
            throw FCPXMLError.parsingFailed(NSError(domain: "FCPXMLService", code: 1, userInfo: [NSLocalizedDescriptionKey: errorMessage]))
        }
    }
    
    /// Parses FCPXML from URL
    /// - Parameter url: URL containing FCPXML data
    /// - Returns: XMLDocument
    /// - Throws: FCPXMLError
    public func parseFCPXML(from url: URL) throws -> XMLDocument {
        do {
            return try parser.parse(from: url)
        } catch {
            let errorMessage = errorHandler.handleParsingError(error)
            throw FCPXMLError.parsingFailed(NSError(domain: "FCPXMLService", code: 1, userInfo: [NSLocalizedDescriptionKey: errorMessage]))
        }
    }
    
    /// Converts CMTime to TimecodeKit Timecode
    /// - Parameters:
    ///   - time: CMTime to convert
    ///   - frameRate: Target frame rate
    /// - Returns: Timecode or nil
    public func timecode(from time: CMTime, frameRate: TimecodeFrameRate) -> Timecode? {
        return timecodeConverter.timecode(from: time, frameRate: frameRate)
    }
    
    /// Converts TimecodeKit Timecode to CMTime
    /// - Parameter timecode: Timecode to convert
    /// - Returns: CMTime
    public func cmTime(from timecode: Timecode) -> CMTime {
        return timecodeConverter.cmTime(from: timecode)
    }
    
    /// Creates a new FCPXML document
    /// - Parameter version: FCPXML version
    /// - Returns: New XMLDocument
    public func createFCPXMLDocument(version: String = "1.10") -> XMLDocument {
        return documentManager.createFCPXMLDocument(version: version)
    }
    
    /// Filters elements by type
    /// - Parameters:
    ///   - elements: Elements to filter
    ///   - types: Types to match
    /// - Returns: Filtered elements
    public func filterElements(_ elements: [XMLElement], ofTypes types: [FCPXMLElementType]) -> [XMLElement] {
        return parser.filter(elements: elements, ofTypes: types)
    }
    
    /// Saves document to URL
    /// - Parameters:
    ///   - document: Document to save
    ///   - url: Target URL
    /// - Throws: Error if saving fails
    public func saveDocument(_ document: XMLDocument, to url: URL) throws {
        try documentManager.saveDocument(document, to: url)
    }
} 