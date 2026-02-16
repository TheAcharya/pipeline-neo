# 14 — High-Level Model

[← Manual Index](00-Index.md)

---

## FinalCutPro.FCPXML

For quick inspection and high-level access without walking the XML tree, use **FinalCutPro.FCPXML**. It wraps the document and exposes a **Root** and version, plus convenience accessors.

**Initialization:**

- `init(fileContent: Data)` — from raw FCPXML data
- `init(fileContent: XMLDocument)` — from an existing document

**Properties and methods:**

- **root** — Root wrapper
- **version** — Version (FinalCutPro.FCPXML.Version)
- **allEvents()** — Event names (or equivalent)
- **allProjects()** — Project names (or equivalent)

```swift
let data = try loader.loadData(from: url)
let fcpxml = try FinalCutPro.FCPXML(fileContent: data)

let eventNames = fcpxml.allEvents()
let projectNames = fcpxml.allProjects()
let root = fcpxml.root
let version = fcpxml.version
```

Bridging with **FCPXMLVersion** (DTD/validation): use `.fcpxmlVersion` and `.dtdVersion` and `init(from:)` converters where provided.

---

## Next

- [15 — Errors & Utilities](15-Errors-Utilities.md) — Error types, ProgressBar.
