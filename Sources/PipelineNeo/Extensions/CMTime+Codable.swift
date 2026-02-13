//
//  CMTime+Codable.swift
//  Pipeline Neo • https://github.com/TheAcharya/pipeline-neo
//  © 2026 • Licensed under MIT License
//

//
//	CMTime Codable extension for FCPXML time string encoding/decoding.
//

import Foundation
import CoreMedia

@available(macOS 12.0, *)
extension CMTime: Codable {
    
    /// Creates a CMTime from a decoder.
    /// - Parameter decoder: The decoder to read data from.
    /// - Throws: An error if decoding fails.
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let string = try container.decode(String.self)
        self = CMTime.fcpxmlTime(from: string)
    }
    
    /// Encodes the CMTime to an encoder.
    /// - Parameter encoder: The encoder to write data to.
    /// - Throws: An error if encoding fails.
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(fcpxmlString)
    }
}
