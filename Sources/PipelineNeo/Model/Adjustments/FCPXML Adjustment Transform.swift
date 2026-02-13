//
//  FCPXML Adjustment Transform.swift
//  Pipeline Neo • https://github.com/TheAcharya/pipeline-neo
//  © 2026 • Licensed under MIT License
//

//
//	Transform adjustment model for position, scale, rotation, and anchor.
//

import Foundation

extension FinalCutPro.FCPXML {
    /// A transform adjustment that modifies position, scale, rotation, and anchor point.
    ///
    /// - SeeAlso: [FCPXML Transform Adjustment Documentation](
    ///   https://developer.apple.com/documentation/professional_video_applications/fcpxml_reference/adjust-transform
    ///   )
    public struct TransformAdjustment: Sendable, Equatable, Hashable, Codable {
        /// The position of the transform adjustment.
        public var position: Point
        
        /// The scale of the transform adjustment.
        public var scale: Point
        
        /// The rotation of the transform adjustment.
        public var rotation: Double
        
        /// The anchor point of the transform adjustment.
        public var anchor: Point
        
        /// A Boolean value indicating whether the transform adjustment is enabled.
        public var isEnabled: Bool
        
        private enum CodingKeys: String, CodingKey {
            case position, scale, rotation, anchor
            case isEnabled = "enabled"
        }
        
        /// Initializes a new transform adjustment.
        /// - Parameters:
        ///   - position: The position of the transform adjustment (default: `.zero`).
        ///   - scale: The scale of the transform adjustment (default: `Point(x: 1, y: 1)`).
        ///   - rotation: The rotation of the transform adjustment (default: `0`).
        ///   - anchor: The anchor point of the transform adjustment (default: `.zero`).
        ///   - isEnabled: Whether the adjustment is enabled (default: `true`).
        public init(
            position: Point = .zero,
            scale: Point = Point(x: 1, y: 1),
            rotation: Double = 0,
            anchor: Point = .zero,
            isEnabled: Bool = true
        ) {
            self.position = position
            self.scale = scale
            self.rotation = rotation
            self.anchor = anchor
            self.isEnabled = isEnabled
        }
    }
}
