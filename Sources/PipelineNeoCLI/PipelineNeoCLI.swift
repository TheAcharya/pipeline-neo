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
        usage: "[<options>] [<fcpxml-path>] [<output-dir>]",
        discussion: "https://github.com/TheAcharya/pipeline-neo",
        version: packageVersion,
        helpNames: .shortAndLong
    )

    @OptionGroup(title: "GENERAL")
    var general: GeneralOptions

    @OptionGroup(title: "TIMELINE")
    var timeline: TimelineOptions

    @OptionGroup(title: "EXTRACTION")
    var extraction: ExtractionOptions

    @OptionGroup(title: "LOG")
    var logOptions: LogOptions

    @Argument(help: "Input FCPXML file / FCPXMLD bundle; or output directory when using --create-project.", transform: URL.init(fileURLWithPath:))
    var fcpxmlPath: URL?

    @Argument(help: "Output directory (for --convert-version, --media-copy, etc.).", transform: URL.init(fileURLWithPath:))
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
        if timeline.createProject {
            guard timeline.width != nil, timeline.height != nil, timeline.rate != nil else {
                throw ValidationError("--create-project requires --width, --height, and --rate (e.g. --create-project --width 1920 --height 1080 --rate 24 <output-dir>).")
            }
            if fcpxmlPath == nil {
                throw ValidationError("output-dir is required when using --create-project (pass the output directory as the positional argument).")
            }
            if let v = timeline.version, FCPXMLVersion(string: v) == nil {
                throw ValidationError("Invalid --version for --create-project: '\(v)'. Use a version between 1.5 and 1.14 (e.g. 1.10, 1.14).")
            }
            let modeCount = [general.checkVersion, general.convertVersion != nil, general.validate, extraction.mediaCopy].filter { $0 }.count
            if modeCount > 0 {
                throw ValidationError("Use only one of --check-version, --convert-version, --validate, --media-copy, or --create-project.")
            }
            return
        }
        let modeCount = [general.checkVersion, general.convertVersion != nil, general.validate, extraction.mediaCopy].filter { $0 }.count
        if modeCount > 1 {
            throw ValidationError("Use only one of --check-version, --convert-version, --validate, or --media-copy.")
        }
        if fcpxmlPath == nil {
            throw ValidationError("fcpxml-path is required when not using --create-project.")
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
        if timeline.createProject, let w = timeline.width, let h = timeline.height, let rateStr = timeline.rate, let outDir = fcpxmlPath {
            guard w > 0 else { throw CreateProjectError.invalidWidth("\(w)") }
            guard h > 0 else { throw CreateProjectError.invalidHeight("\(h)") }
            let rate = try guardRate(rateStr, error: CreateProjectError.invalidRate)
            let version = timeline.version.flatMap { FCPXMLVersion(string: $0) } ?? .default
            try CreateProject.run(width: w, height: h, rate: rate, outputDir: outDir, version: version, logger: logger)
            return
        }
        guard let fcpxmlPath = fcpxmlPath else {
            throw ValidationError("fcpxml-path is required.")
        }
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
            try ConvertVersion.run(fcpxmlPath: fcpxmlPath, targetVersionString: targetVersion, outputDir: outDir, extensionType: general.extensionType, logger: logger)
            return
        }
        if extraction.mediaCopy {
            try ExtractMedia.run(fcpxmlPath: fcpxmlPath, outputDir: outDir, logger: logger, showProgress: !logOptions.quiet)
            return
        }
        print("Input: \(fcpxmlPath.path)")
        print("Output: \(outDir.path)")
        logger.log(level: .info, message: "Input: \(fcpxmlPath.path)", metadata: nil)
        logger.log(level: .info, message: "Output: \(outDir.path)", metadata: nil)
    }
}

private func guardRate(_ s: String, error: (String) -> CreateProjectError) throws -> Double {
    guard let r = Double(s), r > 0 else { throw error(s) }
    return r
}
