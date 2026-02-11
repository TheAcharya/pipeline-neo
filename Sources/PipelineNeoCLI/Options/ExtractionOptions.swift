//
//  ExtractionOptions.swift
//  Pipeline Neo • https://github.com/TheAcharya/pipeline-neo
//  © 2026 • Licensed under MIT License
//

//
//	Options for media copy (--media-copy).
//

import ArgumentParser

struct ExtractionOptions: ParsableArguments {
    @Flag(name: .long, help: "Scan FCPXML/FCPXMLD and copy all referenced media files to output-dir.")
    var mediaCopy: Bool = false
}
