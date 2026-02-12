# Pipeline Neo — Documentation

This folder contains the complete manual and usage guide for Pipeline Neo.

## Contents

- [Manual](Manual.md) — Comprehensive user manual covering all APIs:
  - **Core Operations**: Loading (file/bundle), parsing, modular architecture, timecode conversion, logging, XML operations, error handling
  - **Async/Await**: Modern Swift 6 async/await operations, concurrent operations with task groups, async component-level operations
  - **File Operations**: File loader API, media extraction and copy, parallel file I/O
  - **Validation**: FCPXML version and element types, validation API (semantic + DTD), cut detection
  - **Timeline**: Timeline creation and export, timeline manipulation (ripple insert, auto lane assignment), timeline metadata and timestamps
  - **Media Processing**: MIME type detection, asset validation, silence detection, asset duration measurement
  - **Advanced Features**: Version conversion and save, element extraction (presets and scope), experimental CLI
  - **Extensions**: XMLDocument/XMLElement extensions, FinalCutPro.FCPXML model
  - **Utilities**: Error types, progress bar (CLI), FCPXMLTimecode custom timecode type
  - **Examples**: Complete workflows, practical code examples for all major features

- [CLI](../Sources/PipelineNeoCLI/README.md) — Experimental command-line interface (`pipeline-neo`): single binary with embedded FCPXML DTDs; **GENERAL** options (`--check-version`, `--convert-version`, `--extension-type` fcpxml|fcpxmld, `--validate`), **EXTRACTION** (`--media-copy`), **LOG** options; output format for convert: .fcpxmld bundle (default for 1.10+) or .fcpxml (1.5–1.9 always .fcpxml); building, extending, and regenerating embedded DTDs (`Scripts/generate_embedded_dtds.sh` or `swift run GenerateEmbeddedDTDs`).
