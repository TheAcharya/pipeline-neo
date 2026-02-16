# 13 — XML Extensions

[← Manual Index](00-Index.md)

---

## XMLDocument extension API

**XMLDocument** gains FCPXML-specific properties and methods. Prefer modular overloads (e.g. `addResource(_:using: documentManager)`) when injecting dependencies.

| Property / method | Purpose |
|-------------------|--------|
| `fcpxmlString` | Serialised FCPXML string |
| `fcpxmlVersion` | Document version |
| `fcpxEventNames` | Event names |
| `fcpxEvents` | Event elements |
| `fcpxResources` | Resource elements |
| `fcpxLibraryElement` | Library element |
| `fcpxAllProjects` | All projects |
| `fcpxAllClips` | All clips |
| `add(events:)` | Add event elements |
| `add(resourceElements:)` | Add resource elements |
| `resource(matchingID:)` | Find resource by ID |
| `remove(resourceAtIndex:)` | Remove resource |
| `validateFCPXMLAgainst(version:)` | Validate against version |
| `init(contentsOfFCPXML:)` | Load from URL |

```swift
let document = try XMLDocument(contentsOfFCPXML: url)
let version = document.fcpxmlVersion
let eventNames = document.fcpxEventNames
document.add(events: [newEvent])
if let resource = document.resource(matchingID: "r1") { /* use */ }
document.remove(resourceAtIndex: 0)
try document.validateFCPXMLAgainst(version: .v1_14)
```

---

## XMLElement extension API

**XMLElement** gains `fcpx*` attribute accessors and structural helpers. Use `element.setAttribute(name:value:using: documentManager)` and `element.getAttribute(name:using: documentManager)` for modular attribute access.

| Property / method | Purpose |
|-------------------|--------|
| `fcpxType` | FCPXMLElementType |
| `fcpxName`, `fcpxDuration`, `fcpxOffset`, `fcpxStart` | Clip/timing |
| `fcpxRef`, `fcpxID`, `fcpxLane`, `fcpxRole`, `fcpxFormatRef` | Refs and metadata |
| `fcpxEvent(name:)` | Event by name |
| `fcpxProject(...)` | Project access |
| `eventClips`, `eventClips(forResourceID:)` | Clips in event |
| `addToEvent(items:)`, `removeFromEvent(items:)` | Modify event |
| `fcpxResource`, `fcpxParentEvent`, `fcpxSequenceClips` | Parent/children |
| `fcpxAnnotations` | Annotation elements (markers, keywords, hidden-clip-marker, etc.) |
| `createChild(name:attributes:using:)` | Create child (modular) |

```swift
let elementType = element.fcpxType
let name = element.fcpxName
let duration = element.fcpxDuration
let event = element.fcpxEvent(name: "My Event")
let clips = event.eventClips
let clipsForResource = event.eventClips(forResourceID: "r1")
event.addToEvent(items: [clip])
let annotations = element.fcpxAnnotations
```

---

## Next

- [14 — High-Level Model](14-High-Level-Model.md) — FinalCutPro.FCPXML wrapper.
