# Scripts

Helper scripts for the Pipeline Neo package.

## generate_embedded_dtds.sh

Regenerates `Sources/PipelineNeoCLI/Generated/EmbeddedDTDs.swift` from the DTD files in `Sources/PipelineNeo/FCPXML DTDs/`. The CLI embeds these DTDs so it can run as a single binary without a resource bundle.

**When to run:** After adding or changing any `.dtd` file in `Sources/PipelineNeo/FCPXML DTDs/`. Then rebuild the package.

**Usage:** From the package root:

```bash
./Scripts/generate_embedded_dtds.sh
```

Or from anywhere (the script finds the package root):

```bash
bash /path/to/pipeline-neo/Scripts/generate_embedded_dtds.sh
```

The script invokes `swift run GenerateEmbeddedDTDs`. You can run that directly from the package root if you prefer.

**Xcode builds:** The shared schemes (PipelineNeoCLI, PipelineNeo-Package, GenerateEmbeddedDTDs) include a Build post-action that removes the `GenerateEmbeddedDTDs` binary from the products directory after each build.
