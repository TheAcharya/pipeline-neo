# 16 — CLI

[← Manual Index](00-Index.md)

---

## Overview

The package includes an experimental command-line tool **pipeline-neo**. It is a **single binary**: FCPXML DTDs (1.5–1.14) are embedded, so you can copy the executable and run it without a resource bundle.

- **Build:** `swift build` (or PipelineNeoCLI scheme in Xcode)
- **Run:** `swift run pipeline-neo --help`

---

## Commands and options

Use **one** of: `--check-version`, `--convert-version`, `--validate`, or `--media-copy`. For `--convert-version` and `--media-copy` (and default process), `<output-dir>` is required.

| Option | Description |
|--------|-------------|
| **--check-version** | Load FCPXML at path and print document version. No output-dir required. |
| **--convert-version &lt;VERSION&gt;** | Load, convert to target version (1.5–1.14) with element stripping and DTD validation, save to output-dir. Output format: **--extension-type** (default .fcpxmld for 1.10+; 1.5–1.9 always .fcpxml). |
| **--extension-type &lt;fcpxml\|fcpxmld&gt;** | Output format for convert: `fcpxmld` (bundle, default) or `fcpxml` (single file). |
| **--validate** | Robust validation: semantic + DTD against declared version. Progress indicator unless `--quiet`. No output-dir required. |
| **--media-copy** | Extract media refs and copy files to output-dir. Progress bar unless `--quiet`. Paths to stdout; summary to stderr. |
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
pipeline-neo --log /tmp/pipeline.log --log-level debug --check-version /path/to/project.fcpxml
```

---

## Full CLI reference

For source layout, extending the CLI, and regenerating embedded DTDs, see **[PipelineNeoCLI/README.md](../../Sources/PipelineNeoCLI/README.md)**.

---

## Next

- [17 — Examples](17-Examples.md) — End-to-end workflows and code examples.
