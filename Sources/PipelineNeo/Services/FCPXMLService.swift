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
    
    // MARK: - Async Public API
    
    /// Asynchronously parses FCPXML from data
    /// - Parameter data: FCPXML data
    /// - Returns: XMLDocument
    /// - Throws: FCPXMLError
    public func parseFCPXML(from data: Data) async throws -> XMLDocument {
        do {
            return try await parser.parse(data)
        } catch {
            let errorMessage = errorHandler.handleParsingError(error)
            throw FCPXMLError.parsingFailed(NSError(domain: "FCPXMLService", code: 1, userInfo: [NSLocalizedDescriptionKey: errorMessage]))
        }
    }
    
    /// Asynchronously parses FCPXML from URL
    /// - Parameter url: URL containing FCPXML data
    /// - Returns: XMLDocument
    /// - Throws: FCPXMLError
    public func parseFCPXML(from url: URL) async throws -> XMLDocument {
        do {
            return try await parser.parse(from: url)
        } catch {
            let errorMessage = errorHandler.handleParsingError(error)
            throw FCPXMLError.parsingFailed(NSError(domain: "FCPXMLService", code: 1, userInfo: [NSLocalizedDescriptionKey: errorMessage]))
        }
    }
    
    /// Asynchronously converts CMTime to TimecodeKit Timecode
    /// - Parameters:
    ///   - time: CMTime to convert
    ///   - frameRate: Target frame rate
    /// - Returns: Timecode or nil
    public func timecode(from time: CMTime, frameRate: TimecodeFrameRate) async -> Timecode? {
        return await timecodeConverter.timecode(from: time, frameRate: frameRate)
    }
    
    /// Asynchronously converts TimecodeKit Timecode to CMTime
    /// - Parameter timecode: Timecode to convert
    /// - Returns: CMTime
    public func cmTime(from timecode: Timecode) async -> CMTime {
        return await timecodeConverter.cmTime(from: timecode)
    }
    
    /// Asynchronously creates a new FCPXML document
    /// - Parameter version: FCPXML version
    /// - Returns: New XMLDocument
    public func createFCPXMLDocument(version: String = "1.10") async -> XMLDocument {
        return await documentManager.createFCPXMLDocument(version: version)
    }
    
    /// Asynchronously filters elements by type
    /// - Parameters:
    ///   - elements: Elements to filter
    ///   - types: Types to match
    /// - Returns: Filtered elements
    public func filterElements(_ elements: [XMLElement], ofTypes types: [FCPXMLElementType]) async -> [XMLElement] {
        return await parser.filter(elements: elements, ofTypes: types)
    }
    
    /// Asynchronously saves document to URL
    /// - Parameters:
    ///   - document: Document to save
    ///   - url: Target URL
    /// - Throws: Error if saving fails
    public func saveDocument(_ document: XMLDocument, to url: URL) async throws {
        try await documentManager.saveDocument(document, to: url)
    }
    
    /// Asynchronously validates FCPXML document
    /// - Parameter document: Document to validate
    /// - Returns: True if valid, false otherwise
    public func validateDocument(_ document: XMLDocument) async -> Bool {
        return await parser.validate(document)
    }
    
    /// Asynchronously converts FCPXML time string to CMTime
    /// - Parameter timeString: FCPXML time string
    /// - Returns: CMTime
    public func cmTime(fromFCPXMLTime timeString: String) async -> CMTime {
        return await timecodeConverter.cmTime(fromFCPXMLTime: timeString)
    }
    
    /// Asynchronously converts CMTime to FCPXML time string
    /// - Parameter time: CMTime to convert
    /// - Returns: FCPXML time string
    public func fcpxmlTime(fromCMTime time: CMTime) async -> String {
        return await timecodeConverter.fcpxmlTime(fromCMTime: time)
    }
    
    /// Asynchronously conforms time to frame boundary
    /// - Parameters:
    ///   - time: Time to conform
    ///   - frameDuration: Target frame duration
    /// - Returns: Conformed CMTime
    public func conform(time: CMTime, toFrameDuration frameDuration: CMTime) async -> CMTime {
        return await timecodeConverter.conform(time: time, toFrameDuration: frameDuration)
    }
} 