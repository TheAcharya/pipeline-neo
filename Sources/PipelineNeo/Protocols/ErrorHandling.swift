//
//  ErrorHandling.swift
//  Pipeline Neo • https://github.com/TheAcharya/pipeline-neo
//  © 2025 • Licensed under MIT License
//

import Foundation

/// Protocol defining error handling operations
@available(macOS 12.0, *)
public protocol ErrorHandling: Sendable {
    /// Handles parsing errors
    /// - Parameter error: The error to handle
    /// - Returns: Formatted error message
    func handleParsingError(_ error: Error) -> String
    
    /// Handles validation errors
    /// - Parameter error: The error to handle
    /// - Returns: Formatted error message
    func handleValidationError(_ error: Error) -> String
    
    /// Handles timecode conversion errors
    /// - Parameter error: The error to handle
    /// - Returns: Formatted error message
    func handleTimecodeError(_ error: Error) -> String
} 