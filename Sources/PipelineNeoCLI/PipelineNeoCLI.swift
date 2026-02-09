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
        abstract: "Tool to read and test Final Cut Pro FCPXML/FCPXMLD.",
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
        if !general.checkVersion && outputDir == nil {
            throw ValidationError("output-dir is required when not using --check-version.")
        }
    }

    func run() throws {
        if general.checkVersion {
            try CheckVersion.run(fcpxmlPath: fcpxmlPath)
            return
        }
        let out = outputDir!
        print("Input: \(fcpxmlPath.path)")
        print("Output: \(out.path)")
    }
}
