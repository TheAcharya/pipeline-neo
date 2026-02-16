# 07 — Timeline & Export

[← Manual Index](00-Index.md)

---

## Timeline and TimelineClip

Build a **Timeline** with **TimelineClip** instances and an optional **TimelineFormat**:

```swift
import PipelineNeo
import CoreMedia

let clip = TimelineClip(
    assetRef: "r2",
    offset: CMTime(value: 0, timescale: 1),
    duration: CMTime(value: 1001, timescale: 24000),
    start: .zero,
    lane: 0
)

let format = TimelineFormat.hd1080p(
    frameDuration: CMTime(value: 1001, timescale: 24000),
    colorSpace: .rec709
)

let timeline = Timeline(name: "My Timeline", format: format, clips: [clip])
```

**TimelineFormat** presets: `hd720p`, `dci4K`, `hd1080i`, `hd720i`, `hd1080p`; computed properties: `aspectRatio`, `isHD`, `isUHD`, `interlaced`.

---

## Export assets

**FCPXMLExportAsset** describes each asset referenced by clips. `id` must match `TimelineClip.assetRef`:

```swift
let asset = FCPXMLExportAsset(
    id: "r2",
    name: "Clip1",
    src: URL(fileURLWithPath: "/path/to/media.mov"),
    duration: CMTime(value: 1001, timescale: 24000),
    hasVideo: true,
    hasAudio: true
)
```

---

## Export to FCPXML string

**FCPXMLExporter** produces an FCPXML string:

```swift
let exporter = FCPXMLExporter(version: .default)
let xmlString = try exporter.export(timeline: timeline, assets: [asset])
```

---

## Export to .fcpxmld bundle

**FCPXMLBundleExporter** creates a `.fcpxmld` bundle on disk:

```swift
let bundleExporter = FCPXMLBundleExporter(version: .default, includeMedia: false)
let bundleURL = try bundleExporter.exportBundle(
    timeline: timeline,
    assets: [asset],
    to: outputDirectoryURL,
    bundleName: "My Project"
)
```

**FCPXMLExportError** and **FCPXMLBundleExportError** cover missing assets, invalid timeline, invalid format, and bundle version requirements.

---

## Next

- [08 — Timeline Manipulation](08-Timeline-Manipulation.md) — Ripple insert, auto lane, clip queries.
