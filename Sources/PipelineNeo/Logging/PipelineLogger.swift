//
//  PipelineLogger.swift
//  Pipeline Neo • https://github.com/TheAcharya/pipeline-neo
//  © 2026 • Licensed under MIT License
//

//
//	Pluggable logging protocol with no-op and print implementations.
//

import Foundation

/// Log level for pipeline operations.
@available(macOS 12.0, *)
public enum PipelineLogLevel: Int, Sendable, Comparable, CaseIterable {
    case debug = 0
    case info = 1
    case warning = 2
    case error = 3
    
    public static func < (lhs: PipelineLogLevel, rhs: PipelineLogLevel) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

/// Protocol for optional logging in Pipeline Neo. Consumers can supply a custom implementation
/// (e.g. bridging to swift-log or OSLog); the default is no-op.
@available(macOS 12.0, *)
public protocol PipelineLogger: Sendable {
    /// Log a message with optional metadata.
    /// - Parameters:
    ///   - level: Severity level.
    ///   - message: Log message.
    ///   - metadata: Optional key-value metadata (e.g. "url", "duration").
    func log(level: PipelineLogLevel, message: String, metadata: [String: String]?)
}

/// Default no-op logger. Used when no logger is injected.
@available(macOS 12.0, *)
public struct NoOpPipelineLogger: PipelineLogger, Sendable {
    public init() {}
    public func log(level: PipelineLogLevel, message: String, metadata: [String: String]?) {}
}

/// Simple print-based logger for debugging. Logs to stdout with level prefix.
@available(macOS 12.0, *)
public struct PrintPipelineLogger: PipelineLogger, Sendable {
    public var minimumLevel: PipelineLogLevel

    public init(minimumLevel: PipelineLogLevel = .debug) {
        self.minimumLevel = minimumLevel
    }

    public func log(level: PipelineLogLevel, message: String, metadata: [String: String]?) {
        guard level >= minimumLevel else { return }
        let prefix: String
        switch level {
        case .debug: prefix = "[PipelineNeo Debug]"
        case .info: prefix = "[PipelineNeo Info]"
        case .warning: prefix = "[PipelineNeo Warning]"
        case .error: prefix = "[PipelineNeo Error]"
        }
        var line = "\(prefix) \(message)"
        if let metadata = metadata, !metadata.isEmpty {
            line += " " + metadata.map { "\($0.key)=\($0.value)" }.joined(separator: " ")
        }
        print(line)
    }
}
