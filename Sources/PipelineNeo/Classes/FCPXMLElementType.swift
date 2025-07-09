//
//  FCPXMLElementType.swift
//  Pipeline Neo • https://github.com/TheAcharya/pipeline-neo
//  © 2025 • Licensed under MIT License
//

import Foundation

/// Defines the element types that can exist in FCPXML documents.
///
/// This enumeration provides type-safe access to FCPXML element types,
/// making it easier to work with FCPXML documents programmatically.
@frozen
public enum FCPXMLElementType: String, CaseIterable, Sendable {
    
    // MARK: - Special Cases
    
    /// This element is not from an FCPXML document.
    case none
    
    // MARK: - FCPXML Document Sections
    
    /// The `<resources>` element in an FCPXML document.
    case resourceList = "resources"
    
    /// The `<library>` element in an FCPXML document.
    case library = "library"
    
    // MARK: - Resource Elements
    
    /// Asset resource element.
    case assetResource = "asset"
    
    /// Format resource element.
    case formatResource = "format"
    
    /// Media resource element.
    case mediaResource = "media"
    
    /// Effect resource element.
    case effectResource = "effect"
    
    /// Multicam resource element.
    case multicamResource
    
    /// Compound resource element.
    case compoundResource
    
    // MARK: - Library-Level Elements
    
    /// Event element.
    case event = "event"
    
    /// Project element.
    case project = "project"
    
    /// Multicam clip element.
    case multicamClip = "mc-clip"
    
    /// Compound clip element.
    case compoundClip = "ref-clip"
    
    /// Synchronized clip element (FCPXML v1.6+).
    case synchronizedClip = "sync-clip"
    
    /// Asset clip element (FCPXML v1.6+).
    case assetClip = "asset-clip"
    
    // MARK: - Project-Level Elements
    
    /// Clip element.
    case clip = "clip"
    
    /// Audio element.
    case audio = "audio"
    
    /// Video element.
    case video = "video"
    
    /// Gap element.
    case gap = "gap"
    
    /// Transition element.
    case transition = "transition"
    
    /// Spine element.
    case spine = "spine"
    
    /// Audition element.
    case audition = "audition"
    
    /// Sequence element.
    case sequence = "sequence"
    
    /// Title element.
    case title = "title"
    
    /// Parameter element.
    case param = "param"
    
    /// Caption element (FCPXML v1.8+).
    case caption = "caption"
    
    // MARK: - Text Elements
    
    /// Text element.
    case text = "text"
    
    /// Text style definition element.
    case textStyleDef = "text-style-def"
    
    /// Text style element.
    case textStyle = "text-style"
    
    // MARK: - Clip Annotations
    
    /// Marker element.
    case marker = "marker"
    
    /// Keyword element.
    case keyword = "keyword"
    
    /// Rating element.
    case rating = "rating"
    
    /// Chapter marker element.
    case chapterMarker = "chapter-marker"
    
    /// Analysis marker element.
    case analysisMarker = "analysis-marker"
    
    /// Note element.
    case note = "note"
    
    // MARK: - Collections
    
    /// Folder collection element.
    case folder = "collection-folder"
    
    /// Keyword collection element.
    case keywordCollection = "keyword-collection"
    
    /// Smart collection element.
    case smartCollection = "smart-collection"
}

// MARK: - Convenience Methods

extension FCPXMLElementType {
    
    /// Returns whether this element type represents a resource.
    public var isResource: Bool {
        switch self {
        case .assetResource, .formatResource, .mediaResource, .effectResource, 
             .multicamResource, .compoundResource:
            return true
        default:
            return false
        }
    }
    
    /// Returns whether this element type represents a clip.
    public var isClip: Bool {
        switch self {
        case .clip, .audio, .video, .multicamClip, .compoundClip, 
             .synchronizedClip, .assetClip:
            return true
        default:
            return false
        }
    }
    
    /// Returns whether this element type represents a collection.
    public var isCollection: Bool {
        switch self {
        case .folder, .keywordCollection, .smartCollection:
            return true
        default:
            return false
        }
    }
    
    /// Returns whether this element type represents an annotation.
    public var isAnnotation: Bool {
        switch self {
        case .marker, .keyword, .rating, .chapterMarker, 
             .analysisMarker, .note:
            return true
        default:
            return false
        }
    }
}

