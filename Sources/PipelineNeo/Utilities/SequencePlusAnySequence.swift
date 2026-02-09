//
//  SequencePlusAnySequence.swift
//  Pipeline Neo • https://github.com/TheAcharya/pipeline-neo
//  © 2026 • Licensed under MIT License


//
//	Sequence extension to wrap in AnySequence.
//

import Foundation

extension Sequence {
    /// Wraps the sequence in an `AnySequence` instance.
    var asAnySequence: AnySequence<Element> {
        AnySequence(self)
    }
}
