//
//  GeneralOptions.swift
//  Pipeline Neo • https://github.com/TheAcharya/pipeline-neo
//  © 2026 • Licensed under MIT License
//

//
//  General-purpose flags and options for the CLI.
//

import ArgumentParser

struct GeneralOptions: ParsableArguments {
    @Flag(name: .long, help: "Check and print FCPXML document version.")
    var checkVersion: Bool = false

    @Option(name: .long, help: ArgumentHelp("Convert FCPXML to the given version (e.g. 1.10, 1.14) and write to output-dir.", valueName: "version"))
    var convertVersion: String?

    @Flag(name: .long, help: "Scan FCPXML/FCPXMLD and copy all referenced media files to output-dir.")
    var extractMedia: Bool = false
}
