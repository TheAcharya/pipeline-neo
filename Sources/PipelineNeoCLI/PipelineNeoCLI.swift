//
//  PipelineNeoCLI.swift
//  Pipeline Neo • https://github.com/TheAcharya/pipeline-neo
//  © 2026 • Licensed under MIT License
//

//
//  CLI for Pipeline Neo.
//

import ArgumentParser
import Foundation
import PipelineNeo

@main
struct PipelineNeoCLI: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "pipeline-neo",
        abstract: "Experimental tool to read and validate Final Cut Pro FCPXML/FCPXMLD.",
        usage: "[<options>] <fcpxml-path> [<output-dir>]",
        discussion: "https://github.com/TheAcharya/pipeline-neo",
        version: packageVersion,
        helpNames: .shortAndLong
    )

    @OptionGroup(title: "GENERAL")
    var general: GeneralOptions

    @OptionGroup(title: "EXTRACTION")
    var extraction: ExtractionOptions

    @OptionGroup(title: "LOG")
    var logOptions: LogOptions

    @Argument(help: "Input FCPXML file / FCPXMLD bundle.", transform: URL.init(fileURLWithPath:))
    var fcpxmlPath: URL

    @Argument(help: "Output directory.", transform: URL.init(fileURLWithPath:))
    var outputDir: URL?

    mutating func validate() throws {
        if let logURL = logOptions.log, !logOptions.quiet {
            if FileManager.default.fileExists(atPath: logURL.path) {
                guard FileManager.default.isWritableFile(atPath: logURL.path) else {
                    throw ValidationError("Cannot write to log file: \(logURL.path)")
                }
            }
        }
        if PipelineLogLevel.from(string: logOptions.logLevel) == nil {
            throw ValidationError("Invalid log level: '\(logOptions.logLevel)'. Use one of: trace, debug, info, notice, warning, error, critical.")
        }
        let modeCount = [general.checkVersion, general.convertVersion != nil, general.validate, extraction.mediaCopy].filter { $0 }.count
        if modeCount > 1 {
            throw ValidationError("Use only one of --check-version, --convert-version, --validate, or --media-copy.")
        }
        if general.checkVersion || general.validate {
            return
        }
        if general.convertVersion != nil || extraction.mediaCopy {
            if outputDir == nil {
                throw ValidationError("output-dir is required when using --convert-version or --media-copy.")
            }
            return
        }
        if outputDir == nil {
            throw ValidationError("output-dir is required when not using --check-version, --convert-version, --validate, or --media-copy.")
        }
    }

    func run() throws {
        // Use hardcoded DTDs when no bundle is present (single-binary deployment).
        EmbeddedDTDProvider.provide = { EmbeddedDTDs.data(for: $0) }
        let logger = logOptions.makeLogger()
        if general.checkVersion {
            try CheckVersion.run(fcpxmlPath: fcpxmlPath, logger: logger)
            return
        }
        if general.validate {
            try Validate.run(fcpxmlPath: fcpxmlPath, logger: logger, showProgress: !logOptions.quiet)
            return
        }
        guard let outDir = outputDir else {
            throw ValidationError("output-dir is required.")
        }
        if let targetVersion = general.convertVersion {
            try ConvertVersion.run(fcpxmlPath: fcpxmlPath, targetVersionString: targetVersion, outputDir: outDir, logger: logger)
            return
        }
        if extraction.mediaCopy {
            try ExtractMedia.run(fcpxmlPath: fcpxmlPath, outputDir: outDir, logger: logger, showProgress: !logOptions.quiet)
            return
        }
        print("Input: \(fcpxmlPath.path)")
        print("Output: \(outDir.path)")
    }
}
