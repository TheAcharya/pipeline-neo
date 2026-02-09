<p align="center">
  <a href="https://github.com/TheAcharya/pipeline-neo"><img src="Assets/Pipeline Neo_Icon.png" height="200">
  <h1 align="center">Pipeline Neo</h1>
</p>

<p align="center"><a href="https://github.com/TheAcharya/pipeline-neo/blob/main/LICENSE"><img src="http://img.shields.io/badge/license-MIT-lightgrey.svg?style=flat" alt="license"/></a>&nbsp;<a href="https://github.com/TheAcharya/pipeline-neo"><img src="https://img.shields.io/badge/platform-macOS-lightgrey.svg?style=flat" alt="platform"/></a>&nbsp;<a href="https://github.com/TheAcharya/pipeline-neo/actions/workflows/build.yml"><img src="https://github.com/TheAcharya/pipeline-neo/actions/workflows/build.yml/badge.svg" alt="build"/></a>&nbsp;<img src="https://img.shields.io/badge/Swift-6.0-orange.svg?style=flat" alt="Swift"/>&nbsp;<img src="https://img.shields.io/badge/Xcode-16+-blue.svg?style=flat" alt="Xcode"/></p>

A modern Swift 6 framework for working with Final Cut Pro's FCPXML with full concurrency support and SwiftTimecode integration. Pipeline Neo is a spiritual successor to the original [Pipeline](https://github.com/reuelk/pipeline), modernised for Swift 6.0 and contemporary development practices. 

Pipeline Neo provides a comprehensive API for parsing, creating, and manipulating FCPXML files with advanced timecode operations, async/await patterns, and robust error handling. Built with Swift 6.0 and targeting macOS 12+, it offers type-safe operations, comprehensive test coverage, and seamless integration with SwiftTimecode for professional video editing workflows.

Pipeline Neo is currently in an experimental stage and does not yet cover the full range of FCPXML attributes and parameters. It focuses on core functionality while providing a foundation for future expansion and feature completeness.

This codebase is developed using AI agents.

> [!IMPORTANT]
> Pipeline Neo has yet to be extensively tested in production environments, real-world workflows, or application integration. This library serves as a modernised foundation for AI-assisted development and experimentation with FCPXML processing capabilities. Additionally, this project would not be actively maintained, so please consider this when planning long-term integrations.

## Table of Contents

- [Core Features](#core-features)
- [Requirements](#requirements)
- [Installation](#installation)
- [Documentation](#documentation)
- [FCPXML Version Support](#fcpxml-version-support)
- [Modularity & Safety](#modularity--safety)
- [Architecture Overview](#architecture-overview)
- [Credits](#credits)
- [License](#license)
- [Reporting Bugs](#reporting-bugs)
- [Contribution](#contribution)

## Core Features

- Read, create, and modify FCPXML documents through a protocol-oriented API; add resources, events, projects, and sequences via the document manager.
- Load single .fcpxml files or .fcpxmld bundles via FCPXMLFileLoader (resolves bundle Info.fcpxml; sync and async).
- Parse and validate against bundled DTDs (FCPXML 1.5–1.14); structural and reference validation (FCPXMLValidator), DTD schema validation (FCPXMLDTDValidator).
- Access and edit resources, events, clips, and projects via typed properties and helpers (fcpxEventNames, fcpxAssetResources, resource(matchingID:), event/project/clip APIs).
- Timecode and timing via SwiftTimecode: CMTime, Timecode, FCPXML time strings; all Final Cut Pro frame rates (23.976, 24, 25, 29.97, 30, 50, 59.94, 60); conform to frame boundaries.
- Typed element filtering via FCPXMLElementType (every DTD element; multicam vs compound media inferred from first child).
- Cut detection on project spines: edit points with boundary type (hard cut, transition, gap) and source relationship (same-clip vs different-clips); CutDetectionResult and EditPoint; sync and async.
- Version conversion: convert document to a target version (e.g. 1.14 → 1.10); save as single .fcpxml or .fcpxmld bundle (bundle only for version 1.10 or higher).
- Media extraction and copy: extract asset media-rep and locator URLs (optional baseURL); copy referenced file URLs to a directory with deduplication and unique filenames; MediaExtractionResult and MediaCopyResult; sync and async.
- Timeline and export: build Timeline with TimelineClip and TimelineFormat; export to FCPXML string (FCPXMLExporter) or .fcpxmld bundle (FCPXMLBundleExporter, optional media copy) with FCPXMLExportAsset per asset.
- Sync and async APIs (async/await) for all major operations; dependency-injected, concurrency-safe design for Swift 6.

## Requirements

- macOS 12.0+
- Xcode 16.0+
- Swift 6.0+ (strict concurrency compliant; protocols and public types are `Sendable` where appropriate; `@unchecked Sendable` only where required for Foundation/ObjC interop)

## Installation

### Swift Package Manager

Add Pipeline Neo to your project in Xcode:

1. File → Add Package Dependencies
2. Enter the repository URL: `https://github.com/TheAcharya/pipeline-neo`
3. Select the version you want to use
4. Click Add Package

Or add it to your `Package.swift`:

```swift
// swift-tools-version: 6.0
// Add Pipeline Neo as a dependency and link it to your target.
import PackageDescription

let package = Package(
    name: "MyPackage",
    platforms: [
        .macOS(.v12)
    ],
    dependencies: [
        .package(url: "https://github.com/TheAcharya/pipeline-neo", from: "1.1.0")
    ],
    targets: [
        .target(
            name: "MyTarget",
            dependencies: ["PipelineNeo"]
        )
    ]
)
```

## Documentation

Complete manual, usage guide, and examples are in the [Documentation](Documentation/) folder:

- [Manual](Documentation/Manual.md) — Full user manual: loading, modular operations, time conversions, logging, error handling, async/await, task groups, extensions, and step-by-step examples.

## FCPXML Version Support

Pipeline Neo supports FCPXML versions 1.5 through 1.14. All DTDs for these versions are included. You can validate a document against any version’s schema (e.g. `document.validateFCPXMLAgainst(version: "1.14")`).
- Parsing: Any well-formed FCPXML document parses successfully; the full XML tree is available via Foundation’s `XMLDocument`/`XMLElement` APIs.
- Typed element types: Every element from the FCPXML DTDs (1.5–1.14) is represented in `FCPXMLElementType`, so you can identify and filter by any element (e.g. `locator`, `import-options`, `live-drawing`, `filter-video`, all `adjust-*`, smart-collection match rules, etc.). Structural types like multicam vs compound `media` are inferred from the first child.
- Typed attributes and helpers: The framework also provides typed properties and helpers for a subset of elements (e.g. `fcpxDuration`, `fcpxOffset`, event/project/clip APIs). Other elements are fully accessible via `element.name`, `element.attribute(forName:)`, and the shared `getElementAttribute` / `setElementAttribute` helpers.

## Modularity & Safety

- Protocol-oriented and dependency-injected: core behaviour (parsing, timecode, document ops, error handling) is behind protocols with default implementations you can replace. Inject when creating FCPXMLService or FCPXMLUtility or when using modular extension overloads.
- Extension APIs that can’t take a parameter use a single shared instance (FCPXMLUtility.defaultForExtensions) for consistency and concurrency safety; use overloads with a `using:` parameter for custom pipelines.
- Built with Swift 6 and strict concurrency; Sendable where possible, no unsafe code. Dependencies ([SwiftTimecode](https://github.com/orchetect/swift-timecode) 3.0.0, [SwiftExtensions](https://github.com/orchetect/swift-extensions) 2.0.0+) are up to date.

## Architecture Overview

- Protocols define parsing, timecode conversion, document operations, and error handling; each has a default implementation you can swap. FCPXMLService (and FCPXMLUtility) composes these and exposes sync and async APIs. ModularUtilities provides createPipeline, processFCPXML, validateDocument, convertTimecodes, and similar helpers.
- FCPXMLFileLoader handles .fcpxml and .fcpxmld (including bundle Info.fcpxml). FCPXMLValidator and FCPXMLDTDValidator handle structural and schema validation; DTDs for 1.5–1.14 are bundled.
- Extensions on CMTime, XMLElement, and XMLDocument offer convenience APIs; use modular overloads with an explicit dependency to inject your own. Error types are explicit (FCPXMLError, FCPXMLLoadError, export and validation errors); you can inject a custom error handler.

See AGENT.md for a detailed breakdown for AI agents and contributors.

## Credits

Created by [Vigneswaran Rajkumar](https://bsky.app/profile/vigneswaranrajkumar.com)

Icon Design by [Bor Jen Goh](https://www.artstation.com/borjengoh)

## License

Licensed under the MIT license. See [LICENSE](https://github.com/TheAcharya/pipeline-neo/blob/main/LICENSE) for details.

## Reporting Bugs

For bug reports, feature requests and suggestions you can create a new [issue](https://github.com/TheAcharya/pipeline-neo/issues) to discuss.

## Contribution

Community contributions are welcome and appreciated. Developers are encouraged to fork the repository and submit pull requests to enhance functionality or introduce thoughtful improvements. However, a key requirement is that nothing should break—all existing features and behaviours and logic must remain fully functional and unchanged. Once reviewed and approved, updates will be merged into the main branch.

### AI Agent Development Collaboration

Pipeline Neo is developed using AI agents and we welcome developers who are interested in maintaining or contributing to the project using similar AI-assisted development approaches. If you're passionate about AI-driven development workflows and would like to collaborate on expanding Pipeline Neo's capabilities, we'd love to hear from you. 

Developers with experience in AI agent development and FCPXML processing are invited to get in touch. We can provide repository access and collaborate on advancing the framework's functionality.
