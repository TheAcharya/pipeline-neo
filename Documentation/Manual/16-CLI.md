# 16 — CLI

[← Manual Index](00-Index.md)

---

## Overview

The package includes an experimental command-line tool **pipeline-neo**. It is a **single binary**: FCPXML DTDs (1.5–1.14) are embedded, so you can copy the executable and run it without a resource bundle.

- **Build:** `swift build` (or PipelineNeoCLI scheme in Xcode)
- **Run:** `swift run pipeline-neo --help`

---

## Commands and options

Use **one** of: `--check-version`, `--convert-version`, `--validate`, `--media-copy`, or `--create-project`. For `--convert-version` and `--media-copy` (and default process), `<output-dir>` is required. For `--create-project`, the single positional argument is `<output-dir>` (where the new project file is written).

### GENERAL

| Option | Description |
|--------|-------------|
| **--check-version** | Load FCPXML at path and print document version. No output-dir required. |
| **--convert-version &lt;VERSION&gt;** | Load, convert to target version (1.5–1.14) with element stripping and DTD validation, save to output-dir. Output format: **--extension-type** (default .fcpxmld for 1.10+; 1.5–1.9 always .fcpxml). |
| **--extension-type &lt;fcpxml\|fcpxmld&gt;** | Output format for convert: `fcpxmld` (bundle, default) or `fcpxml` (single file). |
| **--validate** | Robust validation: semantic + DTD against declared version. Progress indicator unless `--quiet`. No output-dir required. |
| **--media-copy** | Extract media refs and copy files to output-dir. Progress bar unless `--quiet`. Paths to stdout; summary to stderr. |

### TIMELINE

| Option | Description |
|--------|-------------|
| **--create-project** | Create a new empty FCPXML project. Requires **--width**, **--height**, **--rate**, and one positional argument (output directory). Project name is derived from dimensions and rate (e.g. `1920x1080@25p.fcpxml`). Output is validated against the DTD before writing. |
| **--width &lt;n&gt;** | Project width in pixels (used with `--create-project`). |
| **--height &lt;n&gt;** | Project height in pixels (used with `--create-project`). |
| **--rate &lt;fps&gt;** | Frame rate, e.g. 24, 25, 29.97 (used with `--create-project`). |
| **--version &lt;ver&gt;** | FCPXML version for the new project (e.g. 1.10, 1.14). Default: 1.14 (used with `--create-project`). |

### LOG

| Option | Description |
|--------|-------------|
| **--log &lt;path&gt;** | Append log to file. When set, CLI commands write user-visible messages to the log. Also console unless `--quiet`. |
| **--log-level &lt;level&gt;** | Minimum level: trace, debug, info, notice, warning, error, critical. Default: info. |
| **--quiet** | No log output. |

---

## Examples

```bash
pipeline-neo --check-version /path/to/project.fcpxml
pipeline-neo --validate /path/to/project.fcpxmld
pipeline-neo --convert-version 1.10 /path/to/project.fcpxml /path/to/output-dir
pipeline-neo --convert-version 1.14 --extension-type fcpxmld /path/to/project.fcpxmld /path/to/output-dir
pipeline-neo --media-copy /path/to/project.fcpxmld /path/to/media-folder

# Create a new empty project (e.g. 1920×1080 at 25 fps), write to output-dir; project file name is 1920x1080@25p.fcpxml
pipeline-neo --create-project --width 1920 --height 1080 --rate 25 /path/to/output-dir
pipeline-neo --create-project --width 640 --height 480 --rate 29.97 --version 1.13 /path/to/output-dir

pipeline-neo --log /tmp/pipeline.log --log-level debug --check-version /path/to/project.fcpxml
```

---

## Full CLI reference

For source layout, extending the CLI, and regenerating embedded DTDs, see **[PipelineNeoCLI/README.md](../../Sources/PipelineNeoCLI/README.md)**.

---

## Next

- [17 — Examples](17-Examples.md) — End-to-end workflows and code examples.
