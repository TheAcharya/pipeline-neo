# Mission: Cross-Platform XML Abstraction for iOS Support

**Goal:** Make Pipeline Neo compile and run on iOS by replacing direct Foundation `XMLDocument`/`XMLElement` usage with an abstract XML layer backed by AEXML on non-macOS platforms.

**Branch:** `feature/ios-xml-abstraction`

---

## Current State

- **146 source files** reference `XMLDocument`, `XMLElement`, `XMLNode`, or `XMLDTD` (~1,620 call sites)
- Package.swift declares `platforms: [.macOS(.v12)]` — iOS is excluded entirely
- Only **1 file** imports `AppKit` (`XMLElementExtension.swift`) — all others use Foundation
- Foundation's `XMLDocument`/`XMLElement` are macOS-only; `XMLParser` (SAX) is available on iOS but the codebase uses the DOM API exclusively
- Existing protocols (`XMLDocumentOperations`, `XMLElementOperations`) already exist but return **concrete** `XMLDocument`/`XMLElement` types — they don't abstract the XML layer, they wrap it
- DTD validation uses `XMLDocument.validate()` and `XMLDTD` — both macOS-only

---

## Architecture Decision

**Approach:** Protocol abstraction layer with swappable backends.

- Define platform-agnostic protocols (`PNXMLDocument`, `PNXMLElement`, `PNXMLNode`)
- Implement two backends: Foundation (macOS) and AEXML (cross-platform)
- Migrate all 146 consuming files to use protocols instead of concrete types
- DTD validation becomes optional/platform-conditional

**Why AEXML:** Lightweight, cross-platform (iOS/tvOS/watchOS/macOS/Linux), DOM-style API with create/modify/serialize capabilities, close API mapping to Foundation XML.

**Why not roll-back-to-zero:** The abstraction layer IS the architecture. Learnings are encoded in protocol definitions and adapter code, not thrown away.

---

## Phase 1: Define Abstract XML Protocols

**Objective:** Define the protocol contracts that replace all direct Foundation XML type references.

### Requirements

1.1. **`PNXMLNode` protocol** — Base node abstraction
  - Properties: `name: String?`, `stringValue: String?`, `xmlString: String`, `parent: (any PNXMLElement)?`, `children: [any PNXMLNode]?`
  - Must be usable as attribute, text, or element node

1.2. **`PNXMLElement` protocol** (conforms to `PNXMLNode`) — Element abstraction
  - **Attribute access:** `attribute(forName:) -> String?`, `addAttribute(name:value:)`, `removeAttribute(forName:)`, `attributes: [String: String]`
  - **Child access:** `children: [any PNXMLElement]`, `elements(forName:) -> [any PNXMLElement]`, `addChild(_:)`, `removeChild(at:)`, `insertChild(_:at:)`
  - **Creation:** `init(name:)`, `init(name:stringValue:)`, `init(name:attributes:)`
  - **Serialization:** `xmlString: String`, `xmlCompactString: String`
  - **Convenience (matching existing extension API):** `childElements: [any PNXMLElement]`, `firstChildElement(named:) -> (any PNXMLElement)?`

1.3. **`PNXMLDocument` protocol** (conforms to `PNXMLNode`) — Document abstraction
  - **Parsing:** `init(data:options:)`, `init(contentsOf:options:)`
  - **Structure:** `rootElement() -> (any PNXMLElement)?`, `setRootElement(_:)`
  - **Metadata:** `characterEncoding: String?`, `version: String?`, `isStandalone: Bool`
  - **Serialization:** `xmlData(options:) -> Data`, `xmlString: String`
  - **DTD (optional):** `dtd: (any PNXMLDTDProtocol)?`, `validate() throws` — behind `#if canImport(FoundationXML)` or platform check

1.4. **`PNXMLDTDProtocol`** (optional protocol) — DTD abstraction
  - Only required on macOS; iOS builds should compile without DTD validation
  - Properties: `name: String?`
  - Factory: `init()`, `init(contentsOf:options:)`

1.5. **`PNXMLFactory` protocol** — Factory for creating documents and elements without `init` on protocols
  - `makeDocument() -> any PNXMLDocument`
  - `makeDocument(data:) throws -> any PNXMLDocument`
  - `makeDocument(contentsOf:) throws -> any PNXMLDocument`
  - `makeElement(name:) -> any PNXMLElement`
  - `makeElement(name:attributes:) -> any PNXMLElement`
  - `makeElement(xmlString:) throws -> any PNXMLElement`

1.6. **Sendability:** All protocols must work within the existing Swift 6 concurrency model. Mirror the current approach — protocols themselves are not `Sendable`, but operations protocols that wrap them are.

1.7. **Location:** New directory `Sources/PipelineNeo/XML/Protocols/`

### Acceptance Criteria
- [ ] Protocols compile on both macOS and iOS targets
- [ ] Every Foundation XML API used across the 146 files has a protocol equivalent
- [ ] No `import AppKit` or `import Foundation` XML types in protocol files
- [ ] DTD-related surface is conditionally compiled

---

## Phase 2: Foundation Backend (macOS)

**Objective:** Wrap Foundation's `XMLDocument`/`XMLElement` behind the new protocols so macOS behavior is unchanged.

### Requirements

2.1. **`FoundationXMLElement`** — Wraps `XMLElement`, conforms to `PNXMLElement`
  - Thin wrapper; delegates all calls to the underlying `XMLElement`
  - Exposes `underlyingElement: XMLElement` for escape-hatch/migration

2.2. **`FoundationXMLDocument`** — Wraps `XMLDocument`, conforms to `PNXMLDocument`
  - Preserves all existing initialization patterns (from URL, from Data, empty)
  - Preserves DTD creation, validation, and serialization options (`nodePreserveWhitespace`, `nodePrettyPrint`, `nodeCompactEmptyElement`)
  - Exposes `underlyingDocument: XMLDocument` for escape-hatch/migration

2.3. **`FoundationXMLFactory`** — Conforms to `PNXMLFactory`
  - Creates `FoundationXMLDocument` and `FoundationXMLElement` instances

2.4. **`FoundationXMLDTD`** — Wraps `XMLDTD`, conforms to `PNXMLDTDProtocol`

2.5. **Location:** `Sources/PipelineNeo/XML/Foundation/`

2.6. **Conditional compilation:** `#if canImport(FoundationXML) || os(macOS)` — this backend is only compiled on platforms where Foundation XML DOM is available

### Acceptance Criteria
- [ ] All existing tests pass with zero changes (swap is transparent)
- [ ] Foundation backend is default on macOS
- [ ] `underlyingElement`/`underlyingDocument` escape hatches exist for incremental migration
- [ ] Serialization output is byte-identical to current behavior

---

## Phase 3: AEXML Backend (Cross-Platform)

**Objective:** Implement the same protocols using AEXML as the backing library.

### Requirements

3.1. **Add AEXML dependency** to Package.swift
  - `.package(url: "https://github.com/tadija/AEXML", from: "4.0.0")`
  - Only linked for non-macOS targets (or universally, with backend selection at init)

3.2. **`AEXMLBackendElement`** — Wraps `AEXMLElement`, conforms to `PNXMLElement`
  - Map `elements(forName:)` → filter `children` by name (AEXML's subscript returns a chainable wrapper, not an array — must convert)
  - Map `attribute(forName:)` → `attributes["name"]`
  - Map `addChild(_:)` → `addChild(AEXMLElement)` (unwrap wrapper)
  - Handle `init(xmlString:)` → parse fragment via `AEXMLDocument(xml:)` and extract root

3.3. **`AEXMLBackendDocument`** — Wraps `AEXMLDocument`, conforms to `PNXMLDocument`
  - Map `xmlData(options:)` → `.xml.data(using: .utf8)` (pretty-printed) or `.xmlCompact.data(using: .utf8)`
  - Map `rootElement()` → `.root` (but handle AEXML's error element sentinel)
  - Handle DTD: stub `validate()` to throw "not supported on this platform" or make it a no-op with a logged warning
  - Handle `characterEncoding`, `version`, `isStandalone` — AEXML supports these via `AEXMLOptions`

3.4. **`AEXMLBackendFactory`** — Conforms to `PNXMLFactory`

3.5. **DTD validation on AEXML:** Not supported. Two options (choose during implementation):
  - **Option A:** `validate()` is a no-op that logs a warning — documents are not validated on iOS
  - **Option B:** `validate()` throws `PNXMLError.dtdValidationUnavailable` — callers must handle
  - **Recommendation:** Option B — explicit failure is safer than silent skip

3.6. **Serialization parity testing:**
  - Round-trip test: parse FCPXML sample → serialize → parse again → compare structure
  - Compare AEXML serialization output against Foundation output for key FCPXML samples
  - Document known differences (whitespace, attribute ordering, etc.)

3.7. **Location:** `Sources/PipelineNeo/XML/AEXML/`

### Acceptance Criteria
- [ ] AEXML backend compiles on iOS, macOS, tvOS, watchOS, Linux
- [ ] AEXML backend passes all non-DTD tests
- [ ] Round-trip serialization preserves FCPXML structure
- [ ] Known serialization differences from Foundation backend are documented
- [ ] DTD-dependent tests are skipped on AEXML backend

---

## Phase 4: Migrate Consuming Code

**Objective:** Replace all 146 files' direct `XMLDocument`/`XMLElement` references with protocol types.

### Requirements

4.1. **Migration order** (by dependency, leaf nodes first):
  1. **Model layer** (~100 files) — `FCPXMLElement` subtypes that store/return `XMLElement`
  2. **Parsing layer** (~10 files) — `FCPXMLAttributes`, `FCPXMLClipParsing`, etc.
  3. **Extensions** (~4 files) — `XMLElementExtension`, `XMLDocumentExtension`, modular variants
  4. **Services/Implementations** (~7 files) — `XMLDocumentManager`, `FCPXMLParser`, `FCPXMLExporter`
  5. **Extraction/Utilities** (~25 files) — `FCPXMLExtraction`, context, presets
  6. **Protocols** — Update `XMLDocumentOperations`, `XMLElementOperations` to use abstract types
  7. **Top-level classes** — `FCPXML`, `FCPXMLUtility`, `FCPXMLService`

4.2. **Migration pattern per file:**
  - Replace `XMLElement` parameter/return types with `any PNXMLElement`
  - Replace `XMLDocument` parameter/return types with `any PNXMLDocument`
  - Replace `XMLNode.attribute(withName:stringValue:)` with `element.addAttribute(name:value:)`
  - Replace `element.stringValue(forAttributeNamed:)` with `element.attribute(forName:)`
  - Replace `XMLElement(name:)` with factory call or protocol init
  - Replace `XMLDocument(data:options:)` with factory call
  - Replace direct `XMLDTD` usage with conditional compilation

4.3. **`import AppKit` removal:** Replace `import AppKit` in `XMLElementExtension.swift` with `import Foundation` (AppKit is only there for `XMLElement` which is re-exported; no AppKit-specific APIs are used)

4.4. **Factory injection:** The `PNXMLFactory` must be injectable through existing dependency injection patterns (`FCPXMLUtility.defaultForExtensions`, `FCPXMLService` initializer, `using:` parameter pattern)

4.5. **Escape hatches during migration:** Use `underlyingElement`/`underlyingDocument` from Phase 2 as temporary bridges where a full migration is blocked. Track all escape-hatch usages — they must reach zero before Phase 4 is complete.

4.6. **Do NOT change test files yet.** Tests continue using Foundation types through the Foundation backend. Test migration happens separately.

### Acceptance Criteria
- [ ] Zero direct references to `XMLDocument`, `XMLElement`, `XMLNode`, or `XMLDTD` in library source (outside of backend implementations)
- [ ] Zero `underlyingElement`/`underlyingDocument` escape-hatch calls in library source
- [ ] All existing macOS tests pass unchanged
- [ ] `import AppKit` removed entirely from library source
- [ ] Factory is injectable at all existing injection points

---

## Phase 5: DTD Validation Strategy

**Objective:** Provide DTD validation on platforms where it's available, degrade gracefully elsewhere.

### Requirements

5.1. **Platform-conditional DTD validation:**
  ```swift
  #if os(macOS)
  // Full DTD validation via Foundation
  #else
  // Structural validation only (element names, required attributes)
  #endif
  ```

5.2. **Structural validator (cross-platform):** Implement a lightweight validator that checks:
  - Root element is `<fcpxml>` with a valid `version` attribute
  - Required child elements exist (`<resources>`, `<library>`/`<event>`/`<project>`)
  - Element names are in the FCPXML element allowlist (already generated by `FCPXMLDTDAllowlistGenerator`)
  - Required attributes are present on key elements
  - This is NOT full DTD validation — it catches obvious structural errors

5.3. **`FCPXMLDTDValidator` update:** Make it platform-conditional:
  - macOS: current behavior (Foundation DTD validation)
  - iOS: delegates to structural validator, returns `.warning` instead of `.error` for DTD-specific checks

5.4. **`FCPXMLValidator` update:** Semantic validation (non-DTD) must work cross-platform with no changes.

### Acceptance Criteria
- [ ] DTD validation works on macOS identically to current behavior
- [ ] Structural validation catches malformed FCPXML on iOS
- [ ] No runtime crashes on iOS when validation is invoked
- [ ] Validation result types are consistent across platforms

---

## Phase 6: Platform Expansion & Package.swift

**Objective:** Open up the package to iOS (and optionally other Apple platforms).

### Requirements

6.1. **Update Package.swift:**
  ```swift
  platforms: [
      .macOS(.v12),
      .iOS(.v15),
  ]
  ```

6.2. **Conditional dependency in Package.swift:**
  - AEXML added as a dependency
  - Backend selection via conditional compilation or target-level dependencies

6.3. **Exclude CLI targets from iOS:** `PipelineNeoCLI` and `GenerateEmbeddedDTDs` remain macOS-only.

6.4. **CoreMedia dependency audit:** `CMTime` is used throughout. Verify `CoreMedia` is available on iOS (it is) and that all `CMTime`-related APIs used are cross-platform.

6.5. **SwiftTimecode dependency audit:** Verify `swift-timecode` supports iOS. If not, this becomes a blocking dependency.

6.6. **swift-extensions dependency audit:** Verify `swift-extensions` supports iOS.

6.7. **CI/CD:** Add iOS build and test jobs to GitHub Actions workflow.
  - Build: `xcodebuild build -scheme PipelineNeo -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.1'`
  - Test: `xcodebuild test -scheme PipelineNeo -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.1'`
  - Runner: `macos-26`

6.8. **Update branch protection** to require iOS CI check to pass.

### Acceptance Criteria
- [ ] `PipelineNeo` library compiles for iOS Simulator and iOS device
- [ ] All non-DTD tests pass on iOS Simulator
- [ ] CLI targets remain macOS-only (no build errors)
- [ ] CI passes for both macOS and iOS
- [ ] All transitive dependencies resolve on iOS

---

## Risk Register

| Risk | Impact | Mitigation |
|------|--------|------------|
| AEXML serialization whitespace differs from Foundation | FCPXML files may not round-trip identically | Serialization parity tests in Phase 3; document acceptable differences |
| `swift-timecode` doesn't support iOS | Blocks Phase 6 entirely | Audit early (Phase 1); open issue/PR upstream if needed |
| Performance regression from protocol existentials (`any`) | Slower parsing of large FCPXML files | Benchmark before/after; consider generics over existentials for hot paths |
| AEXML doesn't handle XML namespaces | Some FCPXML elements may use namespaces | Audit FCPXML samples for namespace usage; likely not an issue |
| `XMLElement(xmlString:)` has no AEXML equivalent | Fragment parsing needed in several places | Implement via `AEXMLDocument(xml:)` + extract root; test edge cases |
| Escape-hatch accumulation in Phase 4 | Migration stalls with Foundation leaking through | Strict tracking; each escape hatch gets a tracking comment and resolution plan |

---

## Success Metrics

- **Zero** direct Foundation XML type references in library source (outside backend impls)
- **100%** existing macOS test pass rate (no regressions)
- **PipelineNeo** builds and passes non-DTD tests on iOS Simulator
- **Serialization parity** documented and acceptable for FCPXML interchange
- **No performance regression** > 10% on existing benchmarks

---

## Dependency Audit Checklist (Do Before Phase 1)

- [ ] Verify `swift-timecode` iOS platform support
- [ ] Verify `swift-extensions` iOS platform support
- [ ] Verify `swift-log` iOS platform support
- [ ] Verify `swift-argument-parser` is not linked to PipelineNeo library target (CLI only)
- [ ] Catalog all `CMTime` APIs used — confirm availability on iOS
- [ ] Check FCPXML samples for XML namespace usage
