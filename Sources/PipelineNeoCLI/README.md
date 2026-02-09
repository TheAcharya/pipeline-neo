# Pipeline Neo CLI

Command-line interface for the Pipeline Neo library. Use it to inspect and process Final Cut Pro FCPXML files and `.fcpxmld` bundles.

---

## Overview

- **Executable name:** `pipeline-neo`
- **Entry point:** `PipelineNeoCLI.swift` (root command; no subcommands)
- **Arguments:** `<fcpxml-path>` (required), `<output-dir>` (optional when using `--check-version`)
- **Options:** Grouped under **GENERAL** and standard **OPTIONS** (`--version`, `--help`)

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

# Process: input + output (output-dir required)
pipeline-neo /path/to/project.fcpxml /path/to/output-dir
```

**Validation:** If you omit `--check-version`, you must provide both `<fcpxml-path>` and `<output-dir>`.

---

## Source layout

| Path | Purpose |
|------|--------|
| `PipelineNeoCLI.swift` | Root command: configuration, GENERAL option group, arguments, validation, and `run()` dispatch. |
| `Options/` | Option groups for help sections. `GeneralOptions` supplies the **GENERAL** flags (e.g. `--check-version`). |
| `Commands/` | Feature modules. Each feature has its own subfolder and a `run(...)` entry point called from the root command (e.g. **CheckVersion** for `--check-version`). |
| `Commands/CheckVersion/` | Implements `--check-version`: loads FCPXML and prints the document version. |

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
