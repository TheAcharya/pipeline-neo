//
//  FCPXMLService.swift
//  Pipeline Neo • https://github.com/TheAcharya/pipeline-neo
//  © 2026 • Licensed under MIT License


//
//	Service orchestrating modular components for high-level FCPXML workflows.
//

import Foundation
import CoreMedia
import SwiftTimecode

/// Main service for FCPXML operations, orchestrating modular components
@available(macOS 12.0, *)
public final class FCPXMLService: Sendable {

    // MARK: - Dependencies

    private let parser: FCPXMLParsing & FCPXMLElementFiltering
    private let timecodeConverter: TimecodeConversion & FCPXMLTimeStringConversion & TimeConforming
    private let documentManager: XMLDocumentOperations & XMLElementOperations
    private let errorHandler: ErrorHandling
    private let logger: PipelineLogger
    private let cutDetector: CutDetection
    private let versionConverter: FCPXMLVersionConverting
    private let mediaExtractor: MediaExtraction

    // MARK: - Initialisation

    /// Creates a service with injected dependencies.
    ///
    /// All parameters have sensible defaults. Pass custom implementations
    /// to override parsing, timecode conversion, document management,
    /// error handling, cut detection, version conversion, or logging behaviour.
    ///
    /// - Parameters:
    ///   - parser: FCPXML parser and element filter (default: `FCPXMLParser()`).
    ///   - timecodeConverter: Timecode conversion, FCPXML time string parsing, and time conforming (default: `TimecodeConverter()`).
    ///   - documentManager: XML document and element operations (default: `XMLDocumentManager()`).
    ///   - errorHandler: Error formatting service (default: `ErrorHandler()`).
    ///   - cutDetector: Cut detection implementation (default: `CutDetector()`).
    ///   - versionConverter: FCPXML version conversion (default: `FCPXMLVersionConverter()`).
    ///   - mediaExtractor: Media reference extraction and copy (default: `MediaExtractor()`).
    ///   - logger: Pipeline logger (default: `NoOpPipelineLogger()`).
    public init(
        parser: FCPXMLParsing & FCPXMLElementFiltering = FCPXMLParser(),
        timecodeConverter: TimecodeConversion & FCPXMLTimeStringConversion & TimeConforming = TimecodeConverter(),
        documentManager: XMLDocumentOperations & XMLElementOperations = XMLDocumentManager(),
        errorHandler: ErrorHandling = ErrorHandler(),
        cutDetector: CutDetection = CutDetector(),
        versionConverter: FCPXMLVersionConverting = FCPXMLVersionConverter(),
        mediaExtractor: MediaExtraction = MediaExtractor(),
        logger: PipelineLogger = NoOpPipelineLogger()
    ) {
        self.parser = parser
        self.timecodeConverter = timecodeConverter
        self.documentManager = documentManager
        self.errorHandler = errorHandler
        self.cutDetector = cutDetector
        self.versionConverter = versionConverter
        self.mediaExtractor = mediaExtractor
        self.logger = logger
    }
    
    // MARK: - Public API (Sync)
    
    /// Parses FCPXML from data
    /// - Parameter data: FCPXML data
    /// - Returns: XMLDocument
    /// - Throws: FCPXMLError
    public func parseFCPXML(from data: Data) throws -> XMLDocument {
        logger.log(level: .debug, message: "Parsing FCPXML from data", metadata: ["bytes": "\(data.count)"])
        do {
            let doc = try parser.parse(data)
            logger.log(level: .debug, message: "Parsed FCPXML successfully", metadata: nil)
            return doc
        } catch {
            logger.log(level: .error, message: "Parse failed: \(errorHandler.handleParsingError(error))", metadata: nil)
            throw error
        }
    }

    /// Parses FCPXML from URL
    /// - Parameter url: URL containing FCPXML data
    /// - Returns: XMLDocument
    /// - Throws: FCPXMLError
    public func parseFCPXML(from url: URL) throws -> XMLDocument {
        logger.log(level: .debug, message: "Parsing FCPXML from URL", metadata: ["url": url.lastPathComponent])
        do {
            let doc = try parser.parse(from: url)
            logger.log(level: .debug, message: "Parsed FCPXML successfully", metadata: nil)
            return doc
        } catch {
            logger.log(level: .error, message: "Parse failed: \(errorHandler.handleParsingError(error))", metadata: nil)
            throw error
        }
    }
    
    /// Converts CMTime to SwiftTimecode Timecode
    /// - Parameters:
    ///   - time: CMTime to convert
    ///   - frameRate: Target frame rate
    /// - Returns: Timecode or nil
    public func timecode(from time: CMTime, frameRate: TimecodeFrameRate) -> Timecode? {
        return timecodeConverter.timecode(from: time, frameRate: frameRate)
    }
    
    /// Converts SwiftTimecode Timecode to CMTime
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
    
    /// Validates FCPXML document
    /// - Parameter document: Document to validate
    /// - Returns: True if valid, false otherwise
    public func validateDocument(_ document: XMLDocument) -> Bool {
        return parser.validate(document)
    }
    
    /// Converts FCPXML time string to CMTime
    /// - Parameter timeString: FCPXML time string
    /// - Returns: CMTime
    public func cmTime(fromFCPXMLTime timeString: String) -> CMTime {
        return timecodeConverter.cmTime(fromFCPXMLTime: timeString)
    }
    
    /// Converts CMTime to FCPXML time string
    /// - Parameter time: CMTime to convert
    /// - Returns: FCPXML time string
    public func fcpxmlTime(fromCMTime time: CMTime) -> String {
        return timecodeConverter.fcpxmlTime(fromCMTime: time)
    }
    
    /// Conforms time to frame boundary
    /// - Parameters:
    ///   - time: Time to conform
    ///   - frameDuration: Target frame duration
    /// - Returns: Conformed CMTime
    public func conform(time: CMTime, toFrameDuration frameDuration: CMTime) -> CMTime {
        return timecodeConverter.conform(time: time, toFrameDuration: frameDuration)
    }

    /// Detects edit points (cuts) in the first project spine of the document.
    /// - Parameter document: Parsed FCPXML document.
    /// - Returns: Result with edit points and counts (same-clip vs different-clips, hard cut / transition / gap).
    public func detectCuts(in document: XMLDocument) -> CutDetectionResult {
        cutDetector.detectCuts(in: document)
    }

    /// Detects edit points (cuts) in the given spine element.
    /// - Parameter spine: An FCPXML `spine` XMLElement.
    /// - Returns: Result with edit points and counts.
    public func detectCuts(inSpine spine: XMLElement) -> CutDetectionResult {
        cutDetector.detectCuts(inSpine: spine)
    }

    /// Converts the document to the target FCPXML version (e.g. 1.14 → 1.10).
    /// Returns a new document with root `version` set to the target; save as .fcpxml or .fcpxmld (bundle only for 1.10+).
    /// - Parameters:
    ///   - document: Parsed FCPXML document.
    ///   - targetVersion: Desired version (e.g. `.v1_10`).
    /// - Returns: New document with that version.
    /// - Throws: If conversion (copy/serialization) fails.
    public func convertToVersion(_ document: XMLDocument, targetVersion: FCPXMLVersion) throws -> XMLDocument {
        try versionConverter.convert(document, to: targetVersion)
    }

    /// Saves the document as a single .fcpxml file.
    /// - Parameters:
    ///   - document: FCPXML document (e.g. after convertToVersion).
    ///   - url: Destination URL (typically with .fcpxml extension).
    public func saveAsFCPXML(_ document: XMLDocument, to url: URL) throws {
        try documentManager.saveDocument(document, to: url)
    }

    /// Saves the document as a .fcpxmld bundle. Only supported when document version is 1.10 or higher.
    /// - Parameters:
    ///   - document: FCPXML document (e.g. after convertToVersion to .v1_10 or later).
    ///   - outputDirectory: Parent directory for the bundle.
    ///   - bundleName: Bundle name without extension (e.g. "My Project" → My Project.fcpxmld).
    /// - Returns: URL of the created bundle.
    /// - Throws: `FCPXMLBundleExportError.bundleRequiresVersion1_10OrHigher` if version < 1.10; or write errors.
    public func saveAsBundle(_ document: XMLDocument, to outputDirectory: URL, bundleName: String) throws -> URL {
        let exporter = FCPXMLBundleExporter(version: .v1_10)
        return try exporter.saveDocumentAsBundle(document, to: outputDirectory, bundleName: bundleName)
    }

    /// Extracts media references (asset media-rep src, locator url) from the document.
    /// - Parameters:
    ///   - document: Parsed FCPXML document.
    ///   - baseURL: Optional base URL to resolve relative src (e.g. URL of the .fcpxml or .fcpxmld).
    /// - Returns: Result with references; urls may be nil for relative src when baseURL is nil.
    public func extractMediaReferences(from document: XMLDocument, baseURL: URL? = nil) -> MediaExtractionResult {
        mediaExtractor.extractMediaReferences(from: document, baseURL: baseURL)
    }

    /// Copies referenced media files (file URLs only) to the destination directory; deduplicates by source URL.
    /// - Parameters:
    ///   - document: Parsed FCPXML document.
    ///   - destinationURL: Directory to copy files into.
    ///   - baseURL: Optional base URL to resolve relative src.
    /// - Returns: Result with copied, skipped, and failed entries.
    public func copyReferencedMedia(from document: XMLDocument, to destinationURL: URL, baseURL: URL? = nil) -> MediaCopyResult {
        mediaExtractor.copyReferencedMedia(from: document, to: destinationURL, baseURL: baseURL)
    }
    
    // MARK: - Async Public API
    
    /// Asynchronously parses FCPXML from data
    /// - Parameter data: FCPXML data
    /// - Returns: XMLDocument
    /// - Throws: FCPXMLError
    public func parseFCPXML(from data: Data) async throws -> XMLDocument {
        logger.log(level: .debug, message: "Parsing FCPXML from data (async)", metadata: ["bytes": "\(data.count)"])
        do {
            let doc = try await parser.parse(data)
            logger.log(level: .debug, message: "Parsed FCPXML successfully", metadata: nil)
            return doc
        } catch {
            logger.log(level: .error, message: "Parse failed: \(errorHandler.handleParsingError(error))", metadata: nil)
            throw error
        }
    }

    /// Asynchronously parses FCPXML from URL
    /// - Parameter url: URL containing FCPXML data
    /// - Returns: XMLDocument
    /// - Throws: FCPXMLError
    public func parseFCPXML(from url: URL) async throws -> XMLDocument {
        logger.log(level: .debug, message: "Parsing FCPXML from URL (async)", metadata: ["url": url.lastPathComponent])
        do {
            let doc = try await parser.parse(from: url)
            logger.log(level: .debug, message: "Parsed FCPXML successfully", metadata: nil)
            return doc
        } catch {
            logger.log(level: .error, message: "Parse failed: \(errorHandler.handleParsingError(error))", metadata: nil)
            throw error
        }
    }

    /// Asynchronously converts CMTime to SwiftTimecode Timecode
    /// - Parameters:
    ///   - time: CMTime to convert
    ///   - frameRate: Target frame rate
    /// - Returns: Timecode or nil
    public func timecode(from time: CMTime, frameRate: TimecodeFrameRate) async -> Timecode? {
        return await timecodeConverter.timecode(from: time, frameRate: frameRate)
    }
    
    /// Asynchronously converts SwiftTimecode Timecode to CMTime
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

    /// Asynchronously detects edit points (cuts) in the first project spine of the document.
    public func detectCuts(in document: XMLDocument) async -> CutDetectionResult {
        await cutDetector.detectCuts(in: document)
    }

    /// Asynchronously detects edit points (cuts) in the given spine element.
    public func detectCuts(inSpine spine: XMLElement) async -> CutDetectionResult {
        await cutDetector.detectCuts(inSpine: spine)
    }

    /// Asynchronously converts the document to the target FCPXML version.
    public func convertToVersion(_ document: XMLDocument, targetVersion: FCPXMLVersion) async throws -> XMLDocument {
        try await versionConverter.convert(document, to: targetVersion)
    }

    /// Asynchronously saves the document as a single .fcpxml file.
    public func saveAsFCPXML(_ document: XMLDocument, to url: URL) async throws {
        try await documentManager.saveDocument(document, to: url)
    }

    /// Asynchronously saves the document as a .fcpxmld bundle (document version must be 1.10 or higher).
    public func saveAsBundle(_ document: XMLDocument, to outputDirectory: URL, bundleName: String) async throws -> URL {
        let exporter = FCPXMLBundleExporter(version: .v1_10)
        return try exporter.saveDocumentAsBundle(document, to: outputDirectory, bundleName: bundleName)
    }

    /// Asynchronously extracts media references from the document.
    public func extractMediaReferences(from document: XMLDocument, baseURL: URL? = nil) async -> MediaExtractionResult {
        await mediaExtractor.extractMediaReferences(from: document, baseURL: baseURL)
    }

    /// Asynchronously copies referenced media files to the destination directory.
    public func copyReferencedMedia(from document: XMLDocument, to destinationURL: URL, baseURL: URL? = nil) async -> MediaCopyResult {
        await mediaExtractor.copyReferencedMedia(from: document, to: destinationURL, baseURL: baseURL)
    }
}
