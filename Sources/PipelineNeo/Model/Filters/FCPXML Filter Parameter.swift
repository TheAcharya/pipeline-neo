//
//  FCPXML Filter Parameter.swift
//  Pipeline Neo • https://github.com/TheAcharya/pipeline-neo
//  © 2026 • Licensed under MIT License
//

//
//	Parameter model for effect and filter parameters.
//

import Foundation

extension FinalCutPro.FCPXML {
    /// A parameter for an effect or filter.
    ///
    /// Parameters can contain nested parameters, values, fade in/out effects, and keyframe animations.
    public struct FilterParameter: Sendable, Equatable, Hashable, Codable {
        /// The name of the parameter.
        public var name: String
        
        /// The key of the parameter.
        public var key: String?
        
        /// The value of the parameter.
        public var value: String?
        
        /// A Boolean value indicating whether the parameter is enabled.
        public var isEnabled: Bool
        
        /// The fade in effect for the parameter.
        public var fadeIn: FadeIn?
        
        /// The fade out effect for the parameter.
        public var fadeOut: FadeOut?
        
        /// The keyframe animation for the parameter.
        public var keyframeAnimation: KeyframeAnimation?
        
        /// The child parameters of the parameter.
        public var parameters: [FilterParameter]
        
        private enum CodingKeys: String, CodingKey {
            case name, key, value
            case isEnabled = "enabled"
            case fadeIn
            case fadeOut
            case keyframeAnimation
            case parameters = "param"
        }
        
        /// Initializes a new parameter.
        /// - Parameters:
        ///   - name: The name of the parameter.
        ///   - key: The key of the parameter (default: `nil`).
        ///   - value: The value of the parameter (default: `nil`).
        ///   - isEnabled: Whether the parameter is enabled (default: `true`).
        ///   - fadeIn: The fade in effect (default: `nil`).
        ///   - fadeOut: The fade out effect (default: `nil`).
        ///   - keyframeAnimation: The keyframe animation (default: `nil`).
        ///   - parameters: Child parameters (default: `[]`).
        public init(
            name: String,
            key: String? = nil,
            value: String? = nil,
            isEnabled: Bool = true,
            fadeIn: FadeIn? = nil,
            fadeOut: FadeOut? = nil,
            keyframeAnimation: KeyframeAnimation? = nil,
            parameters: [FilterParameter] = []
        ) {
            self.name = name
            self.key = key
            self.value = value
            self.isEnabled = isEnabled
            self.fadeIn = fadeIn
            self.fadeOut = fadeOut
            self.keyframeAnimation = keyframeAnimation
            self.parameters = parameters
        }
    }
    
    /// Keyed data associated with filters and effects.
    ///
    /// Used for storing effect configuration and data.
    public struct KeyedData: Sendable, Equatable, Hashable, Codable {
        /// The key of the data.
        public var key: String?
        
        /// The value of the data.
        public var value: String
        
        private enum CodingKeys: String, CodingKey {
            case key
            case value = ""
        }
        
        /// Initializes a new keyed data value.
        /// - Parameters:
        ///   - key: The key of the data (default: `nil`).
        ///   - value: The value of the data.
        public init(key: String? = nil, value: String) {
            self.key = key
            self.value = value
        }
    }
}
