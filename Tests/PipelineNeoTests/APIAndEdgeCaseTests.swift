//
//  APIAndEdgeCaseTests.swift
//  Pipeline Neo • https://github.com/TheAcharya/pipeline-neo
//  © 2026 • Licensed under MIT License
//

//
//	API edge case tests for file loading, logging, and validation.
//

import XCTest
@testable import PipelineNeo

@available(macOS 12.0, *)
final class APIAndEdgeCaseTests: XCTestCase {

    // MARK: - FCPXMLFileLoader async load(from:)

    func testFCPXMLFileLoaderAsyncLoadFromURL() async throws {
        let temp = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".fcpxml")
        let xml = """
        <?xml version="1.0" encoding="UTF-8"?>
        <fcpxml version="1.14">
            <resources/>
        </fcpxml>
        """
        try xml.write(to: temp, atomically: true, encoding: .utf8)
        defer { try? FileManager.default.removeItem(at: temp) }
        let loader = FCPXMLFileLoader()
        let doc = try await loader.load(from: temp)
        XCTAssertNotNil(doc.rootElement())
        XCTAssertEqual(doc.rootElement()?.name, "fcpxml")
    }

    func testFCPXMLFileLoaderAsyncLoadThrowsForMissingFile() async {
        let url = URL(fileURLWithPath: "/nonexistent/\(UUID().uuidString).fcpxml")
        let loader = FCPXMLFileLoader()
        do {
            _ = try await loader.load(from: url)
            XCTFail("Expected FCPXMLLoadError")
        } catch let err as FCPXMLLoadError {
            switch err {
            case .notAFile: break
            case .readFailed: break
            }
        } catch is FCPXMLError {
            // Parse failures surface as FCPXMLError.parsingFailed
        } catch {
            XCTFail("Expected FCPXMLLoadError or FCPXMLError, got \(error)")
        }
    }

    // MARK: - PipelineLogger injection

    func testFCPXMLServiceWithNoOpLoggerParsesSuccessfully() throws {
        let logger = NoOpPipelineLogger()
        let service = FCPXMLService(logger: logger)
        let xml = """
        <?xml version="1.0" encoding="UTF-8"?>
        <fcpxml version="1.14"><resources/></fcpxml>
        """
        let data = xml.data(using: .utf8)!
        let doc = try service.parseFCPXML(from: data)
        XCTAssertEqual(doc.rootElement()?.name, "fcpxml")
    }

    func testFCPXMLServiceWithPrintLoggerParsesSuccessfully() throws {
        let logger = PrintPipelineLogger(minimumLevel: .error)
        let service = FCPXMLService(logger: logger)
        let xml = "<?xml version=\"1.0\"?><fcpxml version=\"1.14\"><resources/></fcpxml>"
        let data = xml.data(using: .utf8)!
        let doc = try service.parseFCPXML(from: data)
        XCTAssertEqual(doc.rootElement()?.name, "fcpxml")
    }

    func testCreateCustomPipelineWithLogger() throws {
        let logger = NoOpPipelineLogger()
        let service = ModularUtilities.createCustomPipeline(
            parser: FCPXMLParser(),
            timecodeConverter: TimecodeConverter(),
            documentManager: XMLDocumentManager(),
            errorHandler: ErrorHandler(),
            logger: logger
        )
        let data = "<fcpxml version=\"1.14\"><resources/></fcpxml>".data(using: .utf8)!
        let doc = try service.parseFCPXML(from: data)
        XCTAssertNotNil(doc.rootElement())
    }

    // MARK: - Edge cases: invalid / empty input

    func testParseEmptyDataThrows() {
        let service = FCPXMLService()
        let data = Data()
        XCTAssertThrowsError(try service.parseFCPXML(from: data))
    }

    func testParseInvalidXMLThrows() {
        let service = FCPXMLService()
        let data = "not xml at all".data(using: .utf8)!
        XCTAssertThrowsError(try service.parseFCPXML(from: data))
    }

    func testParseMalformedXMLThrows() {
        let service = FCPXMLService()
        let data = "<fcpxml version=\"1.14\"><resources".data(using: .utf8)!
        XCTAssertThrowsError(try service.parseFCPXML(from: data))
    }

    func testLoadDocumentFromInvalidPathThrowsCorrectError() {
        let loader = FCPXMLFileLoader()
        let url = URL(fileURLWithPath: "/nonexistent/file.fcpxml")
        XCTAssertThrowsError(try loader.loadDocument(from: url)) { err in
            guard err is FCPXMLLoadError else {
                XCTFail("Expected FCPXMLLoadError"); return
            }
        }
    }

    func testResolveFCPXMLFileURLForNonexistentPathThrows() {
        let loader = FCPXMLFileLoader()
        let url = URL(fileURLWithPath: "/does/not/exist.fcpxml")
        XCTAssertThrowsError(try loader.resolveFCPXMLFileURL(from: url)) { err in
            guard case FCPXMLLoadError.notAFile = err else {
                XCTFail("Expected notAFile"); return
            }
        }
    }

    // MARK: - FCPXML creation (smoke)

    func testCreateFCPXMLDocumentAllVersions() throws {
        let service = FCPXMLService()
        for v in ["1.5", "1.10", "1.14"] {
            let doc = service.createFCPXMLDocument(version: v)
            XCTAssertEqual(doc.fcpxmlVersion, v)
            XCTAssertNotNil(doc.rootElement())
        }
    }

    // MARK: - ValidationResult / ValidationError

    func testValidationResultWithErrors() {
        let err = ValidationError(type: .missingAssetReference, message: "Missing ref", context: ["id": "r1"])
        let result = ValidationResult(errors: [err], warnings: [])
        XCTAssertFalse(result.isValid)
        XCTAssertEqual(result.errors.count, 1)
        XCTAssertEqual(result.errors.first?.message, "Missing ref")
    }

    func testValidationWarning() {
        let warning = ValidationWarning(type: .missingMetadata, message: "Deprecated attribute")
        XCTAssertFalse(warning.message.isEmpty)
    }
}
