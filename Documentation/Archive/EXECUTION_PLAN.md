---
feature_name: OPERATION MARKUP JAILBREAK
starting_point_commit: 1ba52f0b1d930ffb3670eed3a1a536dbdf31d7e4
mission_branch: mission/markup-jailbreak/01
iteration: 1
---

# EXECUTION_PLAN.md — Pipeline Neo iOS XML Abstraction

## Terminology

> **Mission** — A definable, testable scope of work. Defines scope, acceptance criteria, and dependency structure.

> **Sortie** — An atomic, testable unit of work executed by a single autonomous AI agent in one dispatch. One aircraft, one mission, one return.

> **Work Unit** — A grouping of sorties (package, component, phase).

---

## Source

- **Requirements**: `Documentation/MISSION-ios-xml-abstraction.md`
- **RFC**: `Documentation/RFC-ios-platform-support.md`

---

## Work Units

| Work Unit | Directory | Sorties | Layer | Dependencies |
|-----------|-----------|---------|-------|--------------|
| WU1: Dependency Audit | `Sources/PipelineNeo/` | 1 | 0 | none |
| WU2: XML Protocol Definitions | `Sources/PipelineNeo/XML/Protocols/` | 2 | 1 | WU1 |
| WU3: Foundation Backend | `Sources/PipelineNeo/XML/Foundation/` | 2 | 2 | WU2 |
| WU4: AEXML Backend | `Sources/PipelineNeo/XML/AEXML/` | 3 | 2 | WU2 |
| WU5: Code Migration | `Sources/PipelineNeo/` | 13 | 3 | WU3, WU4 |
| WU6: DTD Validation Strategy | `Sources/PipelineNeo/Validation/` | 2 | 4 | WU5 |
| WU7: Platform Expansion | project root | 2 | 5 | WU6 |

---

## WU1: Dependency Audit

> Gate check. Nothing ships until we know the supply lines are clear.

### Sortie 1: Audit All Dependencies for iOS Compatibility

**Priority**: 75.5 — All downstream work depends on this audit clearing. Highest dependency depth.

**Entry criteria**:
- [ ] First sortie — no prerequisites

**Tasks**:
1. Check `swift-timecode` (3.0.0+) for iOS platform support — inspect its Package.swift `platforms` array and any `#if os(macOS)` conditional compilation
2. Check `swift-extensions` (2.1.0+) for iOS platform support — same inspection
3. Check `swift-log` (1.0.0+) for iOS platform support
4. Verify `swift-argument-parser` is only linked to `PipelineNeoCLI` and `GenerateEmbeddedDTDs` targets, NOT to `PipelineNeo` library target (confirm in Package.swift)
5. Catalog all `CMTime` / `CoreMedia` APIs used across `Sources/PipelineNeo/` — confirm each is available on iOS (not macOS-only)
6. Search FCPXML sample files in `Tests/PipelineNeoTests/FCPXML Samples/` for XML namespace declarations (`xmlns:`) to assess namespace risk
7. Write findings to `Documentation/DEPENDENCY_AUDIT.md` with pass/fail per item and any blocking issues

**Exit criteria**:
- [ ] `Documentation/DEPENDENCY_AUDIT.md` exists with pass/fail for all 6 audit items
- [ ] Each blocking issue (if any) has a documented mitigation
- [ ] No false assumptions — each finding cites the specific file/line inspected

---

## WU2: XML Protocol Definitions

> The foundation of the entire mission. Get the contracts right, everything else follows.

### Sortie 2: Define Base XML Protocols (PNXMLNode + PNXMLElement)

**Priority**: 71 — Core contracts that every subsequent sortie depends on. Foundation score: maximum.

**Entry criteria**:
- [ ] WU1 Sortie 1 complete — no blocking dependency issues found (or mitigations documented)

**Tasks**:
1. Create directory `Sources/PipelineNeo/XML/Protocols/`
2. Define `PNXMLNode` protocol in `PNXMLNode.swift` — properties: `name: String?`, `stringValue: String?`, `xmlString: String`, `parent: (any PNXMLElement)?`, `children: [any PNXMLNode]?`
3. Define `PNXMLElement` protocol (conforming to `PNXMLNode`) in `PNXMLElement.swift` — attribute access (`attribute(forName:)`, `addAttribute(name:value:)`, `removeAttribute(forName:)`, `attributes`), child access (`children`, `elements(forName:)`, `addChild(_:)`, `removeChild(at:)`, `insertChild(_:at:)`), creation inits, serialization (`xmlString`, `xmlCompactString`), convenience (`childElements`, `firstChildElement(named:)`)
4. Define `PNXMLError` enum in `PNXMLError.swift` with cases for common XML errors (parsing failure, DTD validation unavailable, element not found, serialization failure)
5. Verify protocols compile — `xcodebuild build -scheme PipelineNeo -destination 'platform=macOS'` succeeds

**Exit criteria**:
- [ ] `Sources/PipelineNeo/XML/Protocols/PNXMLNode.swift` exists with all specified properties
- [ ] `Sources/PipelineNeo/XML/Protocols/PNXMLElement.swift` exists with all specified methods and properties
- [ ] `Sources/PipelineNeo/XML/Protocols/PNXMLError.swift` exists
- [ ] No `import AppKit` or direct Foundation XML type references in protocol files
- [ ] `xcodebuild build -scheme PipelineNeo -destination 'platform=macOS'` succeeds

### Sortie 3: Define Document and Factory Protocols (PNXMLDocument + PNXMLDTDProtocol + PNXMLFactory)

**Priority**: 65 — Completes the protocol surface. All backend and migration work depends on this.

**Entry criteria**:
- [ ] Sortie 2 complete — PNXMLNode and PNXMLElement protocols exist and compile

**Tasks**:
1. Define `PNXMLDocument` protocol (conforming to `PNXMLNode`) in `PNXMLDocument.swift` — parsing inits (`init(data:options:)`, `init(contentsOf:options:)`), structure (`rootElement()`, `setRootElement(_:)`), metadata (`characterEncoding`, `version`, `isStandalone`), serialization (`xmlData(options:)`, `xmlString`), DTD (`dtd`, `validate()`) behind `#if canImport(FoundationXML) || os(macOS)`
2. Define `PNXMLDTDProtocol` in `PNXMLDTDProtocol.swift` — platform-conditional, properties: `name: String?`, factory inits. Wrap entire file in `#if canImport(FoundationXML) || os(macOS)`
3. Define `PNXMLFactory` protocol in `PNXMLFactory.swift` — `makeDocument()`, `makeDocument(data:)`, `makeDocument(contentsOf:)`, `makeElement(name:)`, `makeElement(name:attributes:)`, `makeElement(xmlString:)`
4. Ensure all protocols work within Swift 6 concurrency model — mirror existing Sendability approach (protocols not `Sendable`, operations protocols that wrap them are)
5. Cross-reference protocol surface against requirements doc §1.1–1.5: for each Foundation XML API found via `grep -r 'XMLDocument\|XMLElement\|XMLNode' Sources/PipelineNeo/ --include='*.swift'`, verify a protocol equivalent exists
6. Verify all protocol files compile — `xcodebuild build -scheme PipelineNeo -destination 'platform=macOS'` succeeds

**Exit criteria**:
- [ ] `Sources/PipelineNeo/XML/Protocols/PNXMLDocument.swift` exists with all specified methods
- [ ] `Sources/PipelineNeo/XML/Protocols/PNXMLDTDProtocol.swift` exists with conditional compilation
- [ ] `Sources/PipelineNeo/XML/Protocols/PNXMLFactory.swift` exists with all factory methods
- [ ] DTD-related surface is behind `#if canImport(FoundationXML) || os(macOS)`
- [ ] Cross-reference log in commit message confirms all Foundation XML APIs have protocol equivalents
- [ ] `xcodebuild build -scheme PipelineNeo -destination 'platform=macOS'` succeeds

---

## WU3: Foundation Backend

> Wrap what we already have. macOS behavior must be byte-identical.

### Sortie 4: Implement FoundationXMLElement + FoundationXMLNode

**Priority**: 58.75 — Establishes the Foundation adapter pattern reused by Sortie 5.

**Entry criteria**:
- [ ] WU2 complete — all XML protocols defined and compiling

**Tasks**:
1. Create directory `Sources/PipelineNeo/XML/Foundation/`
2. Implement `FoundationXMLElement` in `FoundationXMLElement.swift` — wraps `XMLElement`, conforms to `PNXMLElement`, delegates all calls to underlying `XMLElement`
3. Expose `underlyingElement: XMLElement` escape-hatch property for incremental migration
4. Wrap entire file in `#if canImport(FoundationXML) || os(macOS)` conditional compilation
5. Verify build succeeds — `xcodebuild build -scheme PipelineNeo -destination 'platform=macOS'`

**Exit criteria**:
- [ ] `Sources/PipelineNeo/XML/Foundation/FoundationXMLElement.swift` exists
- [ ] `FoundationXMLElement` conforms to `PNXMLElement` (compiler verifies)
- [ ] `underlyingElement` property exposes the wrapped `XMLElement`
- [ ] File is conditionally compiled for macOS/FoundationXML only
- [ ] `xcodebuild build -scheme PipelineNeo -destination 'platform=macOS'` succeeds

### Sortie 5: Implement FoundationXMLDocument + FoundationXMLDTD + FoundationXMLFactory

**Priority**: 53 — Completes Foundation backend. Gates all migration work.

**Entry criteria**:
- [ ] Sortie 4 complete — FoundationXMLElement exists and compiles

**Tasks**:
1. Implement `FoundationXMLDocument` in `FoundationXMLDocument.swift` — wraps `XMLDocument`, conforms to `PNXMLDocument`, preserves all init patterns (from URL, Data, empty), preserves DTD validation and serialization options (`nodePreserveWhitespace`, `nodePrettyPrint`, `nodeCompactEmptyElement`)
2. Expose `underlyingDocument: XMLDocument` escape-hatch property
3. Implement `FoundationXMLDTD` in `FoundationXMLDTD.swift` — wraps `XMLDTD`, conforms to `PNXMLDTDProtocol`
4. Implement `FoundationXMLFactory` in `FoundationXMLFactory.swift` — conforms to `PNXMLFactory`, creates `FoundationXMLDocument` and `FoundationXMLElement` instances
5. Run full existing test suite — `xcodebuild test -scheme PipelineNeo -destination 'platform=macOS'` — all tests pass with zero changes

**Exit criteria**:
- [ ] `Sources/PipelineNeo/XML/Foundation/FoundationXMLDocument.swift` exists with all init patterns
- [ ] `Sources/PipelineNeo/XML/Foundation/FoundationXMLDTD.swift` exists
- [ ] `Sources/PipelineNeo/XML/Foundation/FoundationXMLFactory.swift` exists
- [ ] `underlyingDocument` escape hatch is exposed
- [ ] All files conditionally compiled for macOS/FoundationXML
- [ ] `xcodebuild test -scheme PipelineNeo -destination 'platform=macOS'` — all existing tests pass unchanged

---

## WU4: AEXML Backend

> The cross-platform engine. AEXML gets us off macOS island.

### Sortie 6: Add AEXML Dependency + Implement AEXMLBackendElement

**Priority**: 54 — External dependency (risk: 3). Establishes cross-platform backend pattern.

**Entry criteria**:
- [ ] WU2 complete — all XML protocols defined and compiling

**Tasks**:
1. Add AEXML dependency to `Package.swift`: `.package(url: "https://github.com/tadija/AEXML", from: "4.0.0")`
2. Add AEXML to the `PipelineNeo` library target's dependencies (conditionally or universally — implementation decides)
3. Create directory `Sources/PipelineNeo/XML/AEXML/`
4. Implement `AEXMLBackendElement` in `AEXMLBackendElement.swift` — wraps `AEXMLElement`, conforms to `PNXMLElement`
5. Handle API mapping: `elements(forName:)` → filter children by name, `attribute(forName:)` → `attributes["name"]`, `addChild(_:)` → unwrap and delegate, `init(xmlString:)` → parse via `AEXMLDocument(xml:)` and extract root
6. Verify build succeeds — `xcodebuild build -scheme PipelineNeo -destination 'platform=macOS'`

**Exit criteria**:
- [ ] `Package.swift` includes AEXML dependency
- [ ] `Sources/PipelineNeo/XML/AEXML/AEXMLBackendElement.swift` exists
- [ ] `AEXMLBackendElement` conforms to `PNXMLElement` (compiler verifies)
- [ ] `xcodebuild build -scheme PipelineNeo -destination 'platform=macOS'` succeeds (AEXML resolves and compiles)

### Sortie 7: Implement AEXMLBackendDocument + AEXMLBackendFactory

**Priority**: 45 — Completes AEXML backend. Required before migration.

**Entry criteria**:
- [ ] Sortie 6 complete — AEXMLBackendElement exists, AEXML dependency resolves

**Tasks**:
1. Implement `AEXMLBackendDocument` in `AEXMLBackendDocument.swift` — wraps `AEXMLDocument`, conforms to `PNXMLDocument`
2. Map `xmlData(options:)` → `.xml.data(using: .utf8)` (pretty) or `.xmlCompact.data(using: .utf8)` (compact)
3. Map `rootElement()` → `.root` with AEXML error-element sentinel handling
4. Handle `characterEncoding`, `version`, `isStandalone` via `AEXMLOptions`
5. Implement `validate()` as Option B — throws `PNXMLError.dtdValidationUnavailable`
6. Implement `AEXMLBackendFactory` in `AEXMLBackendFactory.swift` — conforms to `PNXMLFactory`
7. Verify build succeeds — `xcodebuild build -scheme PipelineNeo -destination 'platform=macOS'`

**Exit criteria**:
- [ ] `Sources/PipelineNeo/XML/AEXML/AEXMLBackendDocument.swift` exists
- [ ] `Sources/PipelineNeo/XML/AEXML/AEXMLBackendFactory.swift` exists
- [ ] `AEXMLBackendDocument` conforms to `PNXMLDocument` (compiler verifies)
- [ ] `AEXMLBackendFactory` conforms to `PNXMLFactory` (compiler verifies)
- [ ] `validate()` throws `PNXMLError.dtdValidationUnavailable`
- [ ] `xcodebuild build -scheme PipelineNeo -destination 'platform=macOS'` succeeds

### Sortie 8: AEXML Serialization Parity Tests

**Priority**: 38.75 — Validates backend correctness before migration begins.

**Entry criteria**:
- [ ] Sortie 7 complete — AEXMLBackendDocument and AEXMLBackendFactory exist and compile

**Tasks**:
1. Create test file `Tests/PipelineNeoTests/AEXMLSerializationParityTests.swift`
2. Write round-trip test: parse FCPXML sample file → serialize via AEXML backend → parse result → compare document structure (element names, attributes, child counts) against original
3. Write comparison test: parse same FCPXML sample via both Foundation and AEXML backends → serialize both → diff outputs → document differences
4. Use at least 2 FCPXML sample files from `Tests/PipelineNeoTests/FCPXML Samples/FCPXML/`
5. Document known serialization differences (whitespace, attribute ordering, empty element style) in test file comments
6. Verify all parity tests pass — `xcodebuild test -scheme PipelineNeo -destination 'platform=macOS'`

**Exit criteria**:
- [ ] `Tests/PipelineNeoTests/AEXMLSerializationParityTests.swift` exists
- [ ] Round-trip test passes (parse → serialize → parse → structure matches)
- [ ] Known differences between Foundation and AEXML serialization are documented in test comments
- [ ] `xcodebuild test -scheme PipelineNeo -destination 'platform=macOS'` — all tests pass (existing + new parity tests)

---

## WU5: Code Migration

> The big push. 145 files with XML references, ~1,620 call sites. Methodical, directory-by-directory replacement.

### File Inventory (verified via codebase scan)

| Directory | Files | Sortie |
|-----------|-------|--------|
| `Model/ElementTypes/` | 8 | S9 |
| `Model/Animations/` | 5 | S9 |
| `Model/Attributes/` | 5 | S9 |
| `Model/Adjustments/` | 19 | S10 |
| `Model/Clips/` | 18 | S11 |
| `Model/Roles/` | 9 | S12 |
| `Model/Filters/` | 4 | S12 |
| `Model/Occlusion/` | 2 | S12 |
| `Model/Protocols/` | 24 | S13 + S14 |
| `Model/CommonElements/` | 11 | S15 |
| `Model/Resources/` | 9 | S15 |
| `Model/Structure/` | 10 | S16 |
| `Model/` (top-level) | 8 | S16 |
| `Parsing/` | 8 | S17 |
| `Extensions/` | 7 | S17 |
| `Implementations/` | 12 | S18 |
| `Export/` | 3 | S18 |
| `Services/` | 1 | S18 |
| `Delegates/` | 2 | S18 |
| `FileIO/` | 1 | S18 |
| `Extraction/` | 16 | S19 |
| `Classes/` | 9 | S20 |
| `Protocols/` (top-level) | 13 | S20 |
| `Utilities/` | 11 | S21 |
| `Annotations/`, `Timeline/`, `Timing/`, `Errors/`, `Analysis/`, `Format/`, `Media/`, `Logging/` | 29 | S21 |

**Note**: Not all files in every directory reference XML types. Agents should grep each directory for `XMLDocument\|XMLElement\|XMLNode\|XMLDTD` first, then modify only files with actual references. Files without XML references require no changes.

**Migration pattern** (applies to all sorties S9–S21):
- Replace `XMLElement` parameter/return types with `any PNXMLElement`
- Replace `XMLDocument` parameter/return types with `any PNXMLDocument`
- Replace `XMLElement(name:)` and `XMLElement(name:stringValue:)` constructor calls with factory calls via injected `PNXMLFactory`
- Replace `XMLNode.attribute(withName:stringValue:)` with `element.addAttribute(name:value:)`
- Replace `element.stringValue(forAttributeNamed:)` with `element.attribute(forName:)`
- Replace direct `XMLDTD` usage with conditional compilation
- Replace `import AppKit` with `import Foundation` where applicable

### Sortie 9: Migrate Model — ElementTypes + Animations + Attributes

**Priority**: 30 — Foundation types that Model layer builds on. Must go first in migration.

**Entry criteria**:
- [ ] WU3 complete — Foundation backend exists and all existing tests pass
- [ ] WU4 complete — AEXML backend exists and compiles

**Tasks**:
1. Grep `Sources/PipelineNeo/Model/ElementTypes/` for XML type references — migrate all 8 files to use `any PNXMLElement` instead of `XMLElement`
2. Grep and migrate all 5 files in `Sources/PipelineNeo/Model/Animations/`
3. Grep and migrate all 5 files in `Sources/PipelineNeo/Model/Attributes/` (some may be enums with no XML references — skip those)
4. Replace `XMLElement(name:)` constructor calls with factory calls
5. Verify build succeeds — `xcodebuild build -scheme PipelineNeo -destination 'platform=macOS'`

**Exit criteria**:
- [ ] `grep -r 'XMLDocument\|XMLElement\|XMLNode' Sources/PipelineNeo/Model/ElementTypes/ Sources/PipelineNeo/Model/Animations/ Sources/PipelineNeo/Model/Attributes/ --include='*.swift'` returns zero hits
- [ ] `xcodebuild build -scheme PipelineNeo -destination 'platform=macOS'` succeeds

### Sortie 10: Migrate Model — Adjustments

**Priority**: 28 — 19 files with repetitive, mechanical changes. All follow the same Adjustment pattern.

**Entry criteria**:
- [ ] Sortie 9 complete — ElementTypes, Animations, Attributes migrated and building

**Tasks**:
1. Grep and migrate all 19 files in `Sources/PipelineNeo/Model/Adjustments/` — these are FCPXMLAdjustment* types (Blend, Cinematic, ColorConform, Conform, Crop, Equalization, HumReduction, Loudness, NoiseReduction, Orientation, Point, Reorient, RollingShutter, Stabilization, Stereo3D, Transform, Transform360, VoiceIsolation, Volume)
2. Each file follows the same pattern: replace `XMLElement` parameter/return types, replace constructor calls
3. Verify build succeeds — `xcodebuild build -scheme PipelineNeo -destination 'platform=macOS'`

**Exit criteria**:
- [ ] `grep -r 'XMLDocument\|XMLElement\|XMLNode' Sources/PipelineNeo/Model/Adjustments/ --include='*.swift'` returns zero hits
- [ ] `xcodebuild build -scheme PipelineNeo -destination 'platform=macOS'` succeeds

### Sortie 11: Migrate Model — Clips

**Priority**: 27 — 18 clip types. Core model layer with dense XML usage.

**Entry criteria**:
- [ ] Sortie 10 complete — Adjustments migrated and building

**Tasks**:
1. Grep and migrate all 18 files in `Sources/PipelineNeo/Model/Clips/` — AssetClip, Audio, Audition, Clip, Clip+Adjustments, Clip+Filters, Gap, LiveDrawing, MCClip, MulticamSource, RefClip, SyncClip, SyncSource, Title, Title+Typed, Transition, Transition+Filters, Video
2. Replace `XMLElement` parameter/return types and constructor calls
3. Verify build succeeds — `xcodebuild build -scheme PipelineNeo -destination 'platform=macOS'`

**Exit criteria**:
- [ ] `grep -r 'XMLDocument\|XMLElement\|XMLNode' Sources/PipelineNeo/Model/Clips/ --include='*.swift'` returns zero hits
- [ ] `xcodebuild build -scheme PipelineNeo -destination 'platform=macOS'` succeeds

### Sortie 12: Migrate Model — Roles + Filters + Occlusion

**Priority**: 26 — Smaller model subdirectories. Lower dependency depth.

**Entry criteria**:
- [ ] Sortie 11 complete — Clips migrated and building

**Tasks**:
1. Grep and migrate all 9 files in `Sources/PipelineNeo/Model/Roles/`
2. Grep and migrate all 4 files in `Sources/PipelineNeo/Model/Filters/`
3. Grep and migrate both files in `Sources/PipelineNeo/Model/Occlusion/`
4. Verify build succeeds — `xcodebuild build -scheme PipelineNeo -destination 'platform=macOS'`

**Exit criteria**:
- [ ] `grep -r 'XMLDocument\|XMLElement\|XMLNode' Sources/PipelineNeo/Model/Roles/ Sources/PipelineNeo/Model/Filters/ Sources/PipelineNeo/Model/Occlusion/ --include='*.swift'` returns zero hits
- [ ] `xcodebuild build -scheme PipelineNeo -destination 'platform=macOS'` succeeds

### Sortie 13: Migrate Model — Protocols (first 12)

**Priority**: 25 — Model/Protocols has 24 files. Split into two sorties for context budget.

**Entry criteria**:
- [ ] Sortie 12 complete — Roles, Filters, Occlusion migrated and building

**Tasks**:
1. Grep and migrate first 12 files in `Sources/PipelineNeo/Model/Protocols/`: FCPXMLAttribute, FCPXMLElement, FCPXMLElementAnchorableAttributes, FCPXMLElementAudioChannelSourceChildren, FCPXMLElementAudioRoleSourceChildren, FCPXMLElementAudioStartAndDuration, FCPXMLElementBookmarkChild, FCPXMLElementClipAttributes, FCPXMLElementClipAttributesOptionalDuration, FCPXMLElementDuration, FCPXMLElementExtensions, FCPXMLElementFrameSampling
2. Verify build succeeds — `xcodebuild build -scheme PipelineNeo -destination 'platform=macOS'`

**Exit criteria**:
- [ ] `grep -r 'XMLDocument\|XMLElement\|XMLNode' Sources/PipelineNeo/Model/Protocols/FCPXMLAttribute.swift Sources/PipelineNeo/Model/Protocols/FCPXMLElement.swift Sources/PipelineNeo/Model/Protocols/FCPXMLElementAnchorableAttributes.swift Sources/PipelineNeo/Model/Protocols/FCPXMLElementAudioChannelSourceChildren.swift Sources/PipelineNeo/Model/Protocols/FCPXMLElementAudioRoleSourceChildren.swift Sources/PipelineNeo/Model/Protocols/FCPXMLElementAudioStartAndDuration.swift Sources/PipelineNeo/Model/Protocols/FCPXMLElementBookmarkChild.swift Sources/PipelineNeo/Model/Protocols/FCPXMLElementClipAttributes.swift Sources/PipelineNeo/Model/Protocols/FCPXMLElementClipAttributesOptionalDuration.swift Sources/PipelineNeo/Model/Protocols/FCPXMLElementDuration.swift Sources/PipelineNeo/Model/Protocols/FCPXMLElementExtensions.swift Sources/PipelineNeo/Model/Protocols/FCPXMLElementFrameSampling.swift` returns zero hits
- [ ] `xcodebuild build -scheme PipelineNeo -destination 'platform=macOS'` succeeds

### Sortie 14: Migrate Model — Protocols (remaining 12)

**Priority**: 24 — Continuation of Model/Protocols migration.

**Entry criteria**:
- [ ] Sortie 13 complete — first 12 Model/Protocols files migrated and building

**Tasks**:
1. Grep and migrate remaining 12 files in `Sources/PipelineNeo/Model/Protocols/`: FCPXMLElementMediaAttributes, FCPXMLElementMetadataChild, FCPXMLElementMetaTimeline, FCPXMLElementModDate, FCPXMLElementNoteChild, FCPXMLElementOffset, FCPXMLElementStart, FCPXMLElementTCFormat, FCPXMLElementTCStart, FCPXMLElementTextChildren, FCPXMLElementTextStyleDefinitionChildren, FCPXMLElementTimingParams
2. Verify build succeeds — `xcodebuild build -scheme PipelineNeo -destination 'platform=macOS'`

**Exit criteria**:
- [ ] `grep -r 'XMLDocument\|XMLElement\|XMLNode' Sources/PipelineNeo/Model/Protocols/ --include='*.swift'` returns zero hits (entire directory now clean)
- [ ] `xcodebuild build -scheme PipelineNeo -destination 'platform=macOS'` succeeds

### Sortie 15: Migrate Model — CommonElements + Resources

**Priority**: 23 — Data types with moderate XML usage.

**Entry criteria**:
- [ ] Sortie 14 complete — all Model/Protocols migrated and building

**Tasks**:
1. Grep and migrate all 11 files in `Sources/PipelineNeo/Model/CommonElements/` — AudioChannelSource, AudioRoleSource, ConformRate, MediaRep, Metadata, MetadataMetadatum, Text, TextStyle, TextStyleDefinition, TimeMap, TimeMapTimePoint
2. Grep and migrate all 9 files in `Sources/PipelineNeo/Model/Resources/` — Asset, Effect, Format, Locator, Media, MediaMulticam, MediaMulticamAngle, ObjectTracker, ObjectTrackerTrackingShape
3. Verify build succeeds — `xcodebuild build -scheme PipelineNeo -destination 'platform=macOS'`

**Exit criteria**:
- [ ] `grep -r 'XMLDocument\|XMLElement\|XMLNode' Sources/PipelineNeo/Model/CommonElements/ Sources/PipelineNeo/Model/Resources/ --include='*.swift'` returns zero hits
- [ ] `xcodebuild build -scheme PipelineNeo -destination 'platform=macOS'` succeeds

### Sortie 16: Migrate Model — Structure + Top-Level Model Files

**Priority**: 22 — Completes the entire Model layer migration.

**Entry criteria**:
- [ ] Sortie 15 complete — CommonElements and Resources migrated and building

**Tasks**:
1. Grep and migrate all 10 files in `Sources/PipelineNeo/Model/Structure/` — CollectionFolder, Event, ImportOption, KeywordCollection, Library, Project, SmartCollection, SmartCollectionMatchTypes, SmartCollectionMatchTypesComplex, SmartCollectionRule
2. Grep and migrate all 8 top-level Model files in `Sources/PipelineNeo/Model/` — AnyTimeline, Caption, Caption+Typed, HiddenClipMarker, Keyword, Marker, Sequence, Spine
3. Verify build succeeds — `xcodebuild build -scheme PipelineNeo -destination 'platform=macOS'`
4. Run a full-Model grep verification: `grep -r 'XMLDocument\|XMLElement\|XMLNode' Sources/PipelineNeo/Model/ --include='*.swift'` — must return zero hits

**Exit criteria**:
- [ ] `grep -r 'XMLDocument\|XMLElement\|XMLNode' Sources/PipelineNeo/Model/ --include='*.swift'` returns zero hits (entire Model layer clean)
- [ ] `xcodebuild build -scheme PipelineNeo -destination 'platform=macOS'` succeeds

### Sortie 17: Migrate Parsing Layer + Extensions

**Priority**: 20 — Parsing consumes Model types; must migrate after Model is clean.

**Entry criteria**:
- [ ] Sortie 16 complete — entire Model layer migrated and building

**Tasks**:
1. Migrate all 8 files in `Sources/PipelineNeo/Parsing/` to use `any PNXMLElement` and `any PNXMLDocument` — FCPXMLAttributes, FCPXMLClipParsing, FCPXMLElementsParsing, FCPXMLMetadataParsing, FCPXMLResourcesParsing, FCPXMLRolesParsing, FCPXMLRootParsing, FCPXMLTimeAndFrameRateParsing
2. Migrate `Sources/PipelineNeo/Extensions/XMLElementExtension.swift` — replace `import AppKit` with `import Foundation`, replace `XMLElement` types with `any PNXMLElement`
3. Migrate `Sources/PipelineNeo/Extensions/XMLDocument+Modular.swift` — replace `XMLDocument` types with `any PNXMLDocument`
4. Migrate `Sources/PipelineNeo/Extensions/XMLElement+Modular.swift` — replace `XMLElement` types with `any PNXMLElement`
5. Migrate `Sources/PipelineNeo/Extensions/XMLDocumentExtension.swift` if it references Foundation XML types
6. Verify build succeeds — `xcodebuild build -scheme PipelineNeo -destination 'platform=macOS'`

**Exit criteria**:
- [ ] `grep -r 'XMLDocument\|XMLElement\|XMLNode' Sources/PipelineNeo/Parsing/ Sources/PipelineNeo/Extensions/ --include='*.swift'` returns zero hits
- [ ] `grep -r 'import AppKit' Sources/PipelineNeo/ --include='*.swift'` returns zero hits
- [ ] `xcodebuild build -scheme PipelineNeo -destination 'platform=macOS'` succeeds

### Sortie 18: Migrate Services Layer — Implementations + Export + Services + Delegates + FileIO

**Priority**: 18 — Service implementations wrap parsing and model. Must migrate after those layers.

**Entry criteria**:
- [ ] Sortie 17 complete — Parsing and Extensions migrated and building

**Tasks**:
1. Migrate `Sources/PipelineNeo/Implementations/XMLDocumentManager.swift` to use abstract types
2. Migrate remaining files in `Sources/PipelineNeo/Implementations/` — FCPXMLParser, FCPXMLVersionConverter, AssetDurationMeasurer, AssetValidator, CutDetector, ErrorHandler, MediaExtractor, MIMETypeDetector, ParallelFileIOExecutor, SilenceDetector, TimecodeConverter
3. Migrate all 3 files in `Sources/PipelineNeo/Export/` — FCPXMLBundleExporter, FCPXMLExportAsset, FCPXMLExporter
4. Migrate `Sources/PipelineNeo/Services/FCPXMLService.swift`
5. Migrate `Sources/PipelineNeo/Delegates/` — AttributeParserDelegate, FCPXMLParserDelegate
6. Migrate `Sources/PipelineNeo/FileIO/FCPXMLFileLoader.swift`
7. Inject `PNXMLFactory` through existing dependency injection points — `FCPXMLUtility.defaultForExtensions`, `FCPXMLService` initializer, `using:` parameter pattern
8. Verify build succeeds — `xcodebuild build -scheme PipelineNeo -destination 'platform=macOS'`

**Exit criteria**:
- [ ] `grep -r 'XMLDocument\|XMLElement\|XMLNode' Sources/PipelineNeo/Implementations/ Sources/PipelineNeo/Export/ Sources/PipelineNeo/Services/ Sources/PipelineNeo/Delegates/ Sources/PipelineNeo/FileIO/ --include='*.swift'` returns zero hits
- [ ] `PNXMLFactory` is injectable at `FCPXMLUtility.defaultForExtensions`, `FCPXMLService` initializer, and any `using:` parameter pattern (verify by reading these call sites)
- [ ] `xcodebuild build -scheme PipelineNeo -destination 'platform=macOS'` succeeds

### Sortie 19: Migrate Extraction

**Priority**: 17 — Extraction depends on Implementations and Model.

**Entry criteria**:
- [ ] Sortie 18 complete — Services layer migrated and building

**Tasks**:
1. Migrate all 16 files in `Sources/PipelineNeo/Extraction/` including subdirectories (`Context/`, `Presets/`) — FCPXMLExtract, FCPXMLExtractableChildren, FCPXMLExtractedElement, FCPXMLExtractedElementStruct, FCPXMLExtractedModelElement, FCPXMLExtraction, FCPXMLExtractionPreset, FCPXMLExtractionScope, FCPXMLFrameDataPreset, FCPXMLFrameRateSource, FCPXMLMarkersExtractionPreset, FCPXMLRolesExtractionPreset, FCPXMLCaptionsExtractionPreset, FCPXMLElementContext, FCPXMLElementContextItems, FCPXMLElementContextTools
2. Verify build succeeds — `xcodebuild build -scheme PipelineNeo -destination 'platform=macOS'`

**Exit criteria**:
- [ ] `grep -r 'XMLDocument\|XMLElement\|XMLNode' Sources/PipelineNeo/Extraction/ --include='*.swift'` returns zero hits
- [ ] `xcodebuild build -scheme PipelineNeo -destination 'platform=macOS'` succeeds

### Sortie 20: Migrate Top-Level Protocols + Classes

**Priority**: 16 — Top-level types that orchestrate the library.

**Entry criteria**:
- [ ] Sortie 19 complete — Extraction migrated and building

**Tasks**:
1. Update `Sources/PipelineNeo/Protocols/XMLDocumentOperations.swift` to use `any PNXMLDocument` and `any PNXMLElement` instead of concrete Foundation types
2. Grep and migrate any other files in `Sources/PipelineNeo/Protocols/` that reference Foundation XML types (most are service interfaces like CutDetection, SilenceDetection that likely have no XML references — skip those)
3. Migrate `Sources/PipelineNeo/Classes/FCPXML.swift`, `FCPXMLUtility.swift`, `FCPXMLService.swift` (or equivalent under `Classes/`)
4. Migrate remaining files in `Sources/PipelineNeo/Classes/` — FCPXMLInit, FCPXMLProperties, FCPXMLRoot, FCPXMLRootVersion, FCPXMLElementType, FCPXMLVersion, FinalCutPro
5. Verify build succeeds — `xcodebuild build -scheme PipelineNeo -destination 'platform=macOS'`

**Exit criteria**:
- [ ] `grep -r 'XMLDocument\|XMLElement\|XMLNode' Sources/PipelineNeo/Protocols/ Sources/PipelineNeo/Classes/ --include='*.swift'` returns zero hits
- [ ] `xcodebuild build -scheme PipelineNeo -destination 'platform=macOS'` succeeds

### Sortie 21: Migrate Remaining Directories + Final Verification

**Priority**: 15 — Final sweep and comprehensive verification.

**Entry criteria**:
- [ ] Sortie 20 complete — Protocols and Classes migrated and building

**Tasks**:
1. Grep and migrate files with XML references in `Sources/PipelineNeo/Utilities/` — likely: XMLElementAncestorWalking, XMLElementSequenceAttributes, EmbeddedDTDProvider, FCPXMLDTDAllowlistGenerator, FCPXMLTimeUtilities, ModularUtilities
2. Grep and migrate files with XML references in remaining directories: `Annotations/`, `Timeline/`, `Timing/`, `Errors/`, `Analysis/`, `Format/`, `Media/`, `Logging/` — many of these may have zero XML references
3. Run comprehensive grep across entire library: `grep -r 'XMLDocument\|XMLElement\|XMLNode\|XMLDTD' Sources/PipelineNeo/ --include='*.swift'` — must return ONLY hits in `XML/Foundation/` and `XML/AEXML/` directories
4. Run grep for escape-hatch leaks: `grep -r 'underlyingElement\|underlyingDocument' Sources/PipelineNeo/ --include='*.swift'` — must return ONLY hits in `XML/Foundation/` directory
5. Verify zero `import AppKit` statements: `grep -r 'import AppKit' Sources/PipelineNeo/ --include='*.swift'` — must return zero hits
6. Run full test suite — `xcodebuild test -scheme PipelineNeo -destination 'platform=macOS'` — ALL existing tests pass unchanged

**Exit criteria**:
- [ ] `grep -r 'XMLDocument\|XMLElement\|XMLNode\|XMLDTD' Sources/PipelineNeo/ --include='*.swift'` returns ONLY hits in `XML/Foundation/` and `XML/AEXML/` directories
- [ ] `grep -r 'underlyingElement\|underlyingDocument' Sources/PipelineNeo/ --include='*.swift'` returns ONLY hits in `XML/Foundation/` directory
- [ ] `grep -r 'import AppKit' Sources/PipelineNeo/ --include='*.swift'` returns zero hits
- [ ] `xcodebuild test -scheme PipelineNeo -destination 'platform=macOS'` — ALL existing tests pass unchanged

---

## WU6: DTD Validation Strategy

> Full DTD on macOS, structural checks on iOS. Nobody flies blind.

### Sortie 22: Implement Cross-Platform Structural Validator

**Priority**: 12 — New feature, moderate complexity. Depends on complete migration.

**Entry criteria**:
- [ ] WU5 complete — all code migrated to abstract types, all macOS tests pass

**Tasks**:
1. Create `Sources/PipelineNeo/Validation/FCPXMLStructuralValidator.swift` — lightweight cross-platform validator
2. Implement checks: root element is `<fcpxml>` with valid `version` attribute, required child elements exist (`<resources>`, `<library>`/`<event>`/`<project>`), element names in FCPXML allowlist (from `FCPXMLDTDAllowlistGenerator`), required attributes present on key elements
3. Add platform-conditional compilation: `#if os(macOS)` uses Foundation DTD, `#else` uses structural validator
4. Create test file `Tests/PipelineNeoTests/FCPXMLStructuralValidatorTests.swift` — valid FCPXML passes, malformed FCPXML fails with specific `PNXMLError` case
5. Verify build and tests pass — `xcodebuild test -scheme PipelineNeo -destination 'platform=macOS'`

**Exit criteria**:
- [ ] `Sources/PipelineNeo/Validation/FCPXMLStructuralValidator.swift` exists
- [ ] `Tests/PipelineNeoTests/FCPXMLStructuralValidatorTests.swift` exists
- [ ] Structural validator catches: missing root element, invalid version, missing required children, unknown element names (verified by specific test assertions)
- [ ] `xcodebuild test -scheme PipelineNeo -destination 'platform=macOS'` — all tests pass

### Sortie 23: Update DTD + Semantic Validators for Cross-Platform

**Priority**: 10 — Final validation layer before platform expansion.

**Entry criteria**:
- [ ] Sortie 22 complete — structural validator exists and tested

**Tasks**:
1. Update `Sources/PipelineNeo/Validation/FCPXMLDTDValidator.swift` — macOS: current behavior (Foundation DTD validation); non-macOS: delegates to structural validator, returns `.warning` instead of `.error` for DTD-specific checks
2. Update `Sources/PipelineNeo/Validation/FCPXMLValidator.swift` — ensure semantic validation (non-DTD) works cross-platform with no changes
3. Ensure validation result types are consistent across platforms (same enum, same cases)
4. Write platform-conditional tests — verify macOS DTD validation is unchanged, verify non-macOS path compiles and returns correct result types
5. Run full test suite — `xcodebuild test -scheme PipelineNeo -destination 'platform=macOS'`

**Exit criteria**:
- [ ] `FCPXMLDTDValidator` has platform-conditional behavior with `#if os(macOS)` / `#else`
- [ ] `FCPXMLValidator` semantic validation compiles and works without platform-specific code
- [ ] Validation result types are identical across platforms (verified by comparing enum cases)
- [ ] macOS DTD validation behavior is unchanged from pre-mission baseline
- [ ] `xcodebuild test -scheme PipelineNeo -destination 'platform=macOS'` — all tests pass

---

## WU7: Platform Expansion

> Open the gates. iOS gets to join the party.

### Sortie 24: Update Package.swift for iOS Platform Support

**Priority**: 8 — Final configuration change. Low risk, high visibility.

**Entry criteria**:
- [ ] WU6 complete — DTD validation strategy implemented and tested

**Tasks**:
1. Update `Package.swift` `platforms` array: add `.iOS(.v15)` alongside `.macOS(.v12)`
2. Configure AEXML dependency linking — conditional or universal with backend selection
3. Exclude `PipelineNeoCLI` and `GenerateEmbeddedDTDs` targets from iOS (macOS-only executables)
4. Verify `CoreMedia` / `CMTime` availability on iOS — confirm all used APIs are cross-platform
5. Verify `swift-timecode`, `swift-extensions`, `swift-log` resolve on iOS target
6. Build for iOS Simulator — `xcodebuild build -scheme PipelineNeo -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.1'` succeeds

**Exit criteria**:
- [ ] `Package.swift` declares `.iOS(.v15)` platform
- [ ] `PipelineNeoCLI` and `GenerateEmbeddedDTDs` remain macOS-only (no iOS build errors)
- [ ] All transitive dependencies resolve on iOS
- [ ] `xcodebuild build -scheme PipelineNeo -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.1'` succeeds

### Sortie 25: Add iOS CI/CD + Branch Protection

**Priority**: 6 — Infrastructure. Low complexity, low risk.

**Entry criteria**:
- [ ] Sortie 24 complete — PipelineNeo builds for iOS Simulator

**Tasks**:
1. Add iOS build job to `.github/workflows/build.yml` — runner: `macos-26`, destination: `platform=iOS Simulator,name=iPhone 17,OS=26.1`
2. Add iOS test job to `.github/workflows/build.yml` — same runner and destination
3. Update branch protection rules via `gh api` to require iOS CI check to pass alongside existing macOS checks
4. Verify CI workflow syntax is valid — `gh workflow view build.yml`
5. Run macOS tests locally one final time — `xcodebuild test -scheme PipelineNeo -destination 'platform=macOS'` — confirm no regressions

**Exit criteria**:
- [ ] `.github/workflows/build.yml` includes iOS Simulator build and test jobs on `macos-26` runner
- [ ] Branch protection rules require iOS CI check (verified via `gh api repos/{owner}/{repo}/branches/main/protection`)
- [ ] `xcodebuild test -scheme PipelineNeo -destination 'platform=macOS'` — all tests still pass
- [ ] `xcodebuild build -scheme PipelineNeo -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.1'` succeeds

---

## Parallelism Structure

**Critical Path**: S1 → S2 → S3 → S4 → S5 → S9 → S10 → ... → S21 → S22 → S23 → S24 → S25 (length: 25 sorties sequential)

**Parallel Execution Groups**:

- **Group 1** (Layer 0, sequential):
  - WU1: Sortie 1 (Agent 1)
- **Group 2** (Layer 1, sequential):
  - WU2: Sortie 2 → Sortie 3 (Agent 1)
- **Group 3** (Layer 2, parallel — **main parallelism opportunity**):
  - WU3: Sortie 4 → Sortie 5 (Agent 1) — **SUPERVISING AGENT** (has build+test steps)
  - WU4: Sortie 6 → Sortie 7 → Sortie 8 (Agent 2)
- **Group 4** (Layer 3 — WU5 migration, batched parallel):
  - **Batch A** (Model layer — can parallelize file modifications across sub-agents, with supervising agent running builds between batches):
    - S9 + S10 + S11 + S12 dispatched to sub-agents for file modifications
    - Supervising agent builds after each batch
  - **Batch B** (Model Protocols + remaining Model):
    - S13 + S14 + S15 + S16 dispatched to sub-agents
    - Supervising agent builds after batch
  - **Batch C** (Non-Model library code):
    - S17 + S18 + S19 dispatched to sub-agents
    - Supervising agent builds after batch
  - **Batch D** (Top-level + remaining + verification):
    - S20 + S21 — S21 must be last (final verification)
    - Supervising agent runs final build+test
- **Group 5** (Layer 4, sequential):
  - WU6: Sortie 22 → Sortie 23 (Agent 1) — **SUPERVISING AGENT** (has build+test)
- **Group 6** (Layer 5, sequential):
  - WU7: Sortie 24 → Sortie 25 (Agent 1) — **SUPERVISING AGENT** (has build+test)

**Agent Constraints**:
- **Supervising agent**: Handles all sorties with build/compile/test steps. Runs builds between parallel migration batches.
- **Sub-agents (up to 4)**: Handle file modifications within migration batches (WU5 S9–S20). Sub-agents do NOT run builds — only grep, read, and edit files.

**Parallelism Metrics**:
- Maximum parallelism: 4 agents (during WU5 migration batches)
- Layer 2 parallelism: 2 agents (WU3 + WU4 in parallel)
- Sequential bottleneck: WU5 S21 (final verification — must be last)

---

## Open Questions & Missing Documentation

*All issues auto-resolved during refinement. No blocking items remain.*

| Sortie | Issue Type | Resolution |
|--------|-----------|------------|
| S3 (was) | Vague criterion | "Every Foundation XML API has a protocol equivalent" → replaced with cross-reference task and commit-message log |
| S9–S21 (was S13) | Missing scope | "Migrate any remaining files" → replaced with explicit file inventory covering all 25 directories |
| S18 | Missing detail | "PNXMLFactory is injectable at all existing DI points" → now specifies exact injection points to verify |

---

## Summary

| Metric | Value |
|--------|-------|
| Work units | 7 |
| Total sorties | 25 |
| Dependency structure | 6 layers (0–5), WU3 and WU4 are parallel at Layer 2 |
| Migration sorties (WU5) | 13 (S9–S21) |
| Average migration sortie | ~18 files (budget: 50 turns) |
| Critical path length | 25 sorties |
| Maximum parallelism | 4 agents (WU5 migration batches) |

### Layer Diagram

```
Layer 0:  [WU1: Dependency Audit] (S1)
               │
Layer 1:  [WU2: XML Protocols] (S2–S3)
             ┌──┴──┐
Layer 2:  [WU3]  [WU4]          ← Foundation + AEXML backends (parallel)
          (S4–5) (S6–8)
             └──┬──┘
Layer 3:  [WU5: Code Migration] (S9–S21, 13 sorties in 4 batches)
               │
Layer 4:  [WU6: DTD Validation] (S22–S23)
               │
Layer 5:  [WU7: Platform Expansion] (S24–S25)
```
