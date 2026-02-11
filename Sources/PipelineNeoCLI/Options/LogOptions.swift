//
//  LogOptions.swift
//  Pipeline Neo • https://github.com/TheAcharya/pipeline-neo
//  © 2026 • Licensed under MIT License
//

//
//	CLI options for logging: log file, level, and quiet.
//

import ArgumentParser
import Foundation
import PipelineNeo

struct LogOptions: ParsableArguments {
    @Option(
        name: .long,
        help: "Log file path.",
        transform: URL.init(fileURLWithPath:)
    )
    var log: URL?

    @Option(
        name: .long,
        help: "Log level. (values: trace, debug, info, notice, warning, error, critical; default: info)"
    )
    var logLevel: String = "info"

    @Flag(name: .long, help: "Disable log.")
    var quiet: Bool = false

    /// Builds a PipelineLogger from the current options. When quiet, returns NoOpPipelineLogger.
    /// When log level is invalid, defaults to .info.
    func makeLogger() -> PipelineLogger {
        if quiet {
            return NoOpPipelineLogger()
        }
        let level = PipelineLogLevel.from(string: logLevel) ?? .info
        if let fileURL = log {
            return FilePipelineLogger(
                minimumLevel: level,
                fileURL: fileURL,
                alsoPrint: true,
                quiet: false
            )
        }
        return PrintPipelineLogger(minimumLevel: level)
    }
}
