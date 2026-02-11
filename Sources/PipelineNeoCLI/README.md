# Pipeline Neo CLI

Command-line interface for the Pipeline Neo library. Use it to inspect and process Final Cut Pro FCPXML files and `.fcpxmld` bundles.

---

## Overview

- **Executable name:** `pipeline-neo`
- **Entry point:** `PipelineNeoCLI.swift` (root command; no subcommands)
- **Arguments:** `<fcpxml-path>` (required), `<output-dir>` (optional for `--check-version` and `--validate`; required for `--convert-version`, `--media-copy`, and for default process)
- **Options:** Grouped under **GENERAL**, **EXTRACTION**, **LOG**, and standard **OPTIONS** (`--version`, `--help`)

---

## Usage

```bash
# Show help
pipeline-neo --help
pipeline-neo -h

# Show version
pipeline-neo --version

# Check and print FCPXML document version (output-dir not required)
pipeline-neo --check-version /path/to/project.fcpxml
pipeline-neo --check-version /path/to/project.fcpxmld

# Perform robust validation: semantic + DTD (progress indicator when not --quiet; output-dir not required)
pipeline-neo --validate /path/to/project.fcpxml
pipeline-neo --validate /path/to/project.fcpxmld

# Convert FCPXML to a target version (writes to output-dir; e.g. project_1.10.fcpxml)
pipeline-neo --convert-version 1.10 /path/to/project.fcpxml /path/to/output-dir
pipeline-neo --convert-version 1.14 /path/to/project.fcpxmld /path/to/output-dir

# Extract all media referenced in FCPXML/FCPXMLD to output-dir (progress bar when not --quiet; copied paths to stdout; summary to stderr)
pipeline-neo --media-copy /path/to/project.fcpxml /path/to/output-dir
pipeline-neo --media-copy /path/to/project.fcpxmld /path/to/output-dir

# Process: input + output (output-dir required)
pipeline-neo /path/to/project.fcpxml /path/to/output-dir

# Logging: write to file and console (default level: info)
pipeline-neo --log /tmp/pipeline.log --check-version /path/to/project.fcpxml
pipeline-neo --log-level debug --convert-version 1.10 /path/to/project.fcpxml /path/to/out

# Quiet: no log output
pipeline-neo --quiet --media-copy /path/to/project.fcpxml /path/to/media
```

**Validation:** Use only one of `--check-version`, `--convert-version`, `--validate`, or `--media-copy`. When using `--convert-version` or `--media-copy`, or when running the default process, you must provide `<output-dir>`. If `--log` is set and the file exists, it must be writable. Invalid `--log-level` values produce an error.

---

## LOG options

| Option | Description |
|--------|-------------|
| `--log <path>` | Append log output to this file. Also prints to the console unless `--quiet` is set. |
| `--log-level <level>` | Minimum log level: `trace`, `debug`, `info`, `notice`, `warning`, `error`, or `critical`. Default: `info`. |
| `--quiet` | Disable all log output (no file, no console). |

Log messages include parsing, version conversion, validation, save, and media extraction/copy. Use `--log-level debug` or `trace` for verbose output.

---

## Source layout

| Path | Purpose |
|------|--------|
| `PipelineNeoCLI.swift` | Root command: configuration, GENERAL and LOG option groups, arguments, validation, and `run()` dispatch. |
| `Options/` | Option groups for help sections. `GeneralOptions` supplies **GENERAL** flags; `LogOptions` supplies **LOG** options (`--log`, `--log-level`, `--quiet`). |
| `Commands/` | Feature modules. Each feature has its own subfolder and a `run(...)` entry point called from the root command (e.g. **CheckVersion** for `--check-version`). |
| `Commands/CheckVersion/` | Implements `--check-version`: loads FCPXML and prints the document version. |
| `Commands/ConvertVersion/` | Implements `--convert-version`: loads FCPXML, converts to target version (1.5–1.14), saves to output-dir. |
| `Commands/Validate/` | Implements `--validate`: loads FCPXML/FCPXMLD and runs robust validation (semantic + DTD). |
| `Commands/ExtractMedia/` | Implements `--media-copy`: loads FCPXML/FCPXMLD and copies all referenced media files to output-dir. |
| `Generated/` | Generated source; `EmbeddedDTDs.swift` contains hardcoded DTD data (from `GenerateEmbeddedDTDs`). |

All Swift in `Sources/PipelineNeoCLI/` is a single module; no extra imports are needed between these files.

---

## Extending the CLI

**Add a new flag (e.g. under GENERAL):**

1. Add a property to `GeneralOptions` in `Options/GeneralOptions.swift` (e.g. `@Flag` or `@Option`).
2. In `PipelineNeoCLI.run()`, branch on that property and call the appropriate logic (existing module or inline).

**Add a new feature module (like CheckVersion):**

1. Create a folder under `Commands/`, e.g. `Commands/ExtractMedia/`.
2. Add a Swift file with a type (struct or enum) that exposes a static `run(...)` taking the needed parameters.
3. Add a flag or option (in `GeneralOptions` or a new option group) and, in `PipelineNeoCLI.run()`, call the new module when that option is set.

**Add subcommands later (optional):**

1. Define a `ParsableCommand` type under `Commands/...`.
2. In `PipelineNeoCLI`, set `subcommands: [YourCommand.self, ...]` (and optionally `defaultSubcommand`) in `CommandConfiguration`.

---

## Building and running

- **Swift PM:** From the package root, `swift build --target PipelineNeoCLI`; run with `swift run pipeline-neo --help` or use the built binary in `.build/debug/` or `.build/release/`.
- **Xcode:** Open the package, choose the **PipelineNeoCLI** or **PipelineNeo-Package** scheme, then Run or use the Product executable.

**Distributing the CLI:** The CLI is a **single binary**: the FCPXML DTDs (1.5–1.14) are hardcoded into the executable. Copy only **`pipeline-neo`** to any directory on the Mac or external storage; no resource bundle is required. The binary is produced in `.build/<arch>-apple-macosx/debug/` (or `release/`).

**Scripts:** Invoke the CLI directly (e.g. `"$TOOL_PATH" "$FCPXML_PATH" --validate`). Use a path to the binary with no trailing slash.

**Regenerating embedded DTDs:** If the FCPXML DTDs in `Sources/PipelineNeo/FCPXML DTDs/` change, run `./Scripts/generate_embedded_dtds.sh` or `swift run GenerateEmbeddedDTDs` from the package root to regenerate `Sources/PipelineNeoCLI/Generated/EmbeddedDTDs.swift`, then rebuild.
