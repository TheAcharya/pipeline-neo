//
//  EmbeddedDTDProvider.swift
//  Pipeline Neo • https://github.com/TheAcharya/pipeline-neo
//  © 2026 • Licensed under MIT License
//

//
//	Optional provider for DTD content by resource name (e.g. from hardcoded CLI data).
//

import Foundation

/// Allows supplying DTD data from memory (e.g. embedded in the CLI binary).
/// When set, the library uses this to load a DTD by name when no bundle resource is found.
/// The name is the DTD resource name without extension (e.g. `Final_Cut_Pro_XML_DTD_version_1.13`).
public enum EmbeddedDTDProvider {

	/// When non-nil, called with a DTD resource name; return the DTD file data or nil.
	/// Set once at process startup (e.g. by the CLI); reads are synchronized by the caller.
	nonisolated(unsafe) public static var provide: (@Sendable (String) -> Data?)?
}
