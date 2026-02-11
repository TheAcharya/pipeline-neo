# Pipeline Neo — Documentation

This folder contains the complete manual and usage guide for Pipeline Neo.

## Contents

- [Manual](Manual.md) — Full user manual covering the main API: loading (file/bundle), modular architecture, timecode conversion, logging, XML operations, error handling, async/await and task groups, file loader, FCPXML version and element types, validation, cut detection, version conversion and save, experimental CLI (GENERAL / EXTRACTION / LOG), element extraction (presets and scope), media extraction and copy, timeline and export, XMLDocument/XMLElement extensions, FinalCutPro.FCPXML model, error types, progress bar, and examples.
- [CLI](../Sources/PipelineNeoCLI/README.md) — Experimental command-line interface (`pipeline-neo`): single binary with embedded FCPXML DTDs; `--check-version`, `--convert-version`, `--validate`, `--media-copy`, and log options; building, extending, and regenerating embedded DTDs (`Scripts/generate_embedded_dtds.sh` or `swift run GenerateEmbeddedDTDs`).
