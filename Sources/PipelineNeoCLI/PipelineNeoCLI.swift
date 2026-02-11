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

    @Argument(help: "Input FCPXML file / FCPXMLD bundle.", transform: URL.init(fileURLWithPath:))
    var fcpxmlPath: URL

    @Argument(help: "Output directory.", transform: URL.init(fileURLWithPath:))
    var outputDir: URL?

    mutating func validate() throws {
        let modeCount = [general.checkVersion, general.convertVersion != nil, general.extractMedia].filter { $0 }.count
        if modeCount > 1 {
            throw ValidationError("Use only one of --check-version, --convert-version, or --extract-media.")
        }
        if general.checkVersion {
            return
        }
        if general.convertVersion != nil || general.extractMedia {
            if outputDir == nil {
                throw ValidationError("output-dir is required when using --convert-version or --extract-media.")
            }
            return
        }
        if outputDir == nil {
            throw ValidationError("output-dir is required when not using --check-version, --convert-version, or --extract-media.")
        }
    }

    func run() throws {
        if general.checkVersion {
            try CheckVersion.run(fcpxmlPath: fcpxmlPath)
            return
        }
        guard let outDir = outputDir else {
            throw ValidationError("output-dir is required.")
        }
        if let targetVersion = general.convertVersion {
            try ConvertVersion.run(fcpxmlPath: fcpxmlPath, targetVersionString: targetVersion, outputDir: outDir)
            return
        }
        if general.extractMedia {
            try ExtractMedia.run(fcpxmlPath: fcpxmlPath, outputDir: outDir)
            return
        }
        print("Input: \(fcpxmlPath.path)")
        print("Output: \(outDir.path)")
    }
}
