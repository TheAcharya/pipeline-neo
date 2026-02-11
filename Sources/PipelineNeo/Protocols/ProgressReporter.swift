//
//  ProgressReporter.swift
//  Pipeline Neo • https://github.com/TheAcharya/pipeline-neo
//  © 2026 • Licensed under MIT License
//

//
//	Protocol for reporting progress of long-running operations (e.g. file copy).
//

import Foundation

/// Reports progress for long-running operations. Implementations (e.g. ``ProgressBar``) are typically used from a single thread (e.g. CLI).
public protocol ProgressReporter: AnyObject {
    /// Advance progress by the given number of steps.
    func advance(by n: Int)
    /// Mark progress as finished and finalize output.
    func finish()
}
