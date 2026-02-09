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
}
