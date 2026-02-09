//
//  TestResources.swift
//  Pipeline Neo • https://github.com/TheAcharya/pipeline-neo
//  © 2026 • Licensed under MIT License


//
//	Path resolution utilities for test sample files.
//

import Foundation
import XCTest

/// Resolves the package root (directory containing Package.swift) from a file URL (e.g. `#file`).
func packageRoot(relativeToFile fileURL: URL = URL(fileURLWithPath: #file)) -> URL {
    var url = fileURL
    for _ in 0..<6 {
        url = url.deletingLastPathComponent()
        if FileManager.default.fileExists(atPath: url.appendingPathComponent("Package.swift").path) {
            return url
        }
    }
    return url
}

/// Directory containing FCPXML sample files (Tests/FCPXML Samples/FCPXML).
func fcpxmlSamplesDirectory(relativeToFile fileURL: URL = URL(fileURLWithPath: #file)) -> URL {
    packageRoot(relativeToFile: fileURL)
        .appendingPathComponent("Tests", isDirectory: true)
        .appendingPathComponent("FCPXML Samples", isDirectory: true)
        .appendingPathComponent("FCPXML", isDirectory: true)
}

/// URL for a named FCPXML sample (e.g. "24", "Complex") with extension .fcpxml.
func urlForFCPXMLSample(named name: String, relativeToFile fileURL: URL = URL(fileURLWithPath: #file)) -> URL {
    fcpxmlSamplesDirectory(relativeToFile: fileURL).appendingPathComponent("\(name).fcpxml")
}

/// Names of sample FCPXML files available in Tests/FCPXML Samples/FCPXML.
enum FCPXMLSampleName: String, CaseIterable {
    case frameRate23_98 = "23.98"
    case frameRate24 = "24"
    case frameRate24With25Media = "24With25Media"
    case frameRate25i = "25i"
    case frameRate29_97 = "29.97"
    case frameRate29_97d = "29.97d"
    case frameRate30 = "30"
    case frameRate50 = "50"
    case frameRate59_94 = "59.94"
    case frameRate60 = "60"
    case annotations = "Annotations"
    case audioOnly = "AudioOnly"
    case auditionMarkers = "AuditionMarkers"
    case auditionMarkers2 = "AuditionMarkers2"
    case auditionMarkers3 = "AuditionMarkers3"
    case basicMarkers = "BasicMarkers"
    case basicMarkers_1HourProjectStart = "BasicMarkers_1HourProjectStart"
    case clipMetadata = "ClipMetadata"
    case complex = "Complex"
    case compoundClips = "CompoundClips"
    case disabledClips = "DisabledClips"
    case keywords = "Keywords"
    case multicamMarkers = "MulticamMarkers"
    case multicamMarkers2 = "MulticamMarkers2"
    case occlusion = "Occlusion"
    case occlusion2 = "Occlusion2"
    case occlusion3 = "Occlusion3"
    case rolesList = "RolesList"
    case standaloneAssetClip = "StandaloneAssetClip"
    case standaloneLibraryEventClip = "StandaloneLibraryEventClip"
    case standaloneRefClip = "StandaloneRefClip"
    case structure = "Structure"
    case syncClip = "SyncClip"
    case syncClipRoles = "SyncClipRoles"
    case syncClipRoles2 = "SyncClipRoles2"
    case titlesRoles = "TitlesRoles"
    case transitionMarkers1 = "TransitionMarkers1"
    case transitionMarkers2 = "TransitionMarkers2"
    case twoClipsMarkers = "TwoClipsMarkers"
}
