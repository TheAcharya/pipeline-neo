# RFC: iOS Platform Support for Pipeline Neo

**Date:** 2026-03-09
**Status:** Proposed
**Author:** Tom Stovall

---

## Summary

Pipeline Neo currently compiles only for macOS 12+ because it depends on Foundation's `XMLDocument` and `XMLElement` classes, which Apple has never ported to iOS. This RFC proposes introducing an abstract XML layer with swappable backends — Foundation on macOS, AEXML on iOS — to enable cross-platform support while preserving all existing macOS functionality.

---

## Problem Statement

Pipeline Neo is a Swift 6 framework for parsing, creating, manipulating, and exporting Final Cut Pro FCPXML documents. Its value proposition — structured FCPXML operations with timecode awareness — applies equally to macOS and iOS use cases (iPad-based video editing, companion apps, metadata viewers, remote collaboration tools).

However, the library cannot be used on iOS at all. The blocking dependency is Foundation's XML DOM API:

- **`XMLDocument`**, **`XMLElement`**, **`XMLNode`**, and **`XMLDTD`** are macOS-only classes
- Apple has never ported these to iOS, tvOS, watchOS, or Linux
- iOS only has `XMLParser` (SAX-style), which is fundamentally different from the DOM API Pipeline Neo uses
- These types are referenced **1,620 times across 146 source files** — this is not a surface-level dependency

Any downstream project (app, framework, or tool) that depends on Pipeline Neo is automatically locked to macOS. This limits adoption and excludes the growing ecosystem of iOS/iPadOS video production tools.

---

## Impact of Doing Nothing

- Pipeline Neo remains macOS-only indefinitely
- Any iOS app needing FCPXML support must use a different library or build their own
- The library's addressable market shrinks as iPad-based editing grows
- SwiftUI apps targeting both macOS and iOS cannot use Pipeline Neo without bifurcating their FCPXML logic

---

## Proposed Solution

### Approach: Protocol Abstraction with Swappable Backends

Introduce a platform-agnostic XML protocol layer (`PNXMLDocument`, `PNXMLElement`, `PNXMLNode`) and two backend implementations:

| Backend | Platform | Library | DTD Validation |
|---------|----------|---------|----------------|
| Foundation | macOS | Built-in | Full (via `XMLDTD`) |
| AEXML | iOS, tvOS, watchOS, Linux | [AEXML 4.x](https://github.com/tadija/AEXML) | Structural only |

**Why AEXML:**
- Cross-platform (iOS, tvOS, watchOS, macOS, Linux)
- DOM-style API: create elements, modify attributes, add/remove children, serialize to XML string
- Lightweight, zero dependencies, actively maintained
- API maps closely to Foundation's XML DOM — minimizes cognitive overhead

**Why not other options:**
- `marcprux/universal` — Read-only parser, no DOM manipulation or serialization
- `SwiftSoup` — HTML-first library with XML bolted on; not designed for XML creation/export
- `XMLCoder` — Codable-based; would require full model-layer redesign
- `FuziXML` — libxml2 wrapper; heavier than needed and C interop complexity

### Architecture

```
┌─────────────────────────────────────────────┐
│           Pipeline Neo Library               │
│  (146 files using PNXMLDocument/PNXMLElement) │
└─────────────────┬───────────────────────────┘
                  │
         ┌────────┴────────┐
         │  PNXMLFactory   │  ← injected at init
         └────────┬────────┘
                  │
     ┌────────────┼────────────┐
     │                         │
┌────┴─────┐           ┌──────┴──────┐
│Foundation│           │    AEXML    │
│ Backend  │           │   Backend   │
│(macOS)   │           │(iOS/Linux)  │
└──────────┘           └─────────────┘
```

This fits Pipeline Neo's existing protocol-oriented architecture. The library already uses `XMLDocumentOperations` and `XMLElementOperations` protocols with dependency injection — this proposal extends that pattern to the XML types themselves.

### DTD Validation Trade-off

Foundation's `XMLDocument.validate()` performs full DTD validation against FCPXML's published DTDs. AEXML has no DTD support.

**Mitigation:** On non-macOS platforms, a lightweight structural validator checks:
- Root element name and version attribute
- Required child elements
- Element name allowlist (derived from existing `FCPXMLDTDAllowlistGenerator`)
- Required attributes on key elements

This catches the most common structural errors. Full DTD validation remains available on macOS.

---

## Scope of Change

| Metric | Value |
|--------|-------|
| Files directly affected | 146 (Foundation XML references) |
| Call sites to migrate | ~1,620 |
| New dependency | AEXML 4.x (56 KB, zero transitive deps) |
| New source files | ~10-15 (protocols + two backends) |
| Removed dependencies | None |
| Breaking API changes | Minimal — public API types change from concrete to protocol |

### What Changes for Existing macOS Users

- Public APIs that currently accept/return `XMLElement` will accept/return `any PNXMLElement`
- The `underlyingElement`/`underlyingDocument` escape hatches provide access to Foundation types during transition
- Foundation backend is default on macOS — behavior and output are identical
- **Serialization output is unchanged** on macOS

### What Doesn't Change

- All existing tests continue to pass
- FCPXML parsing, creation, manipulation, and export logic is unchanged
- Timecode operations, extraction presets, and model types are unchanged
- CLI tool remains macOS-only

---

## Phased Delivery

| Phase | Description | Deliverable |
|-------|-------------|-------------|
| 0 | Dependency audit | Confirm swift-timecode, swift-extensions, CoreMedia work on iOS |
| 1 | Define abstract protocols | `PNXMLDocument`, `PNXMLElement`, `PNXMLNode`, `PNXMLFactory` |
| 2 | Foundation backend | Wrap existing XMLDocument/XMLElement — macOS tests pass unchanged |
| 3 | AEXML backend | Cross-platform implementation with serialization parity tests |
| 4 | Migrate 146 files | Replace all concrete Foundation XML types with protocols |
| 5 | DTD validation strategy | Platform-conditional DTD + structural validator |
| 6 | Platform expansion | Update Package.swift, add iOS CI |

Each phase is independently mergeable. Phases 1-2 are risk-free (no behavior change). Phase 3 is additive. Phase 4 is the largest effort. Phases 5-6 finalize.

---

## Risks and Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| AEXML serialization differs from Foundation | High | Medium | Parity tests; document acceptable differences |
| Performance regression from protocol existentials | Medium | Low | Benchmark hot paths; use generics where critical |
| `swift-timecode` doesn't support iOS | Low | Blocking | Audit before starting; upstream PR if needed |
| AEXML can't parse XML fragments (`XMLElement(xmlString:)`) | Medium | Medium | Wrap in document, parse, extract root |
| Breaking change for downstream consumers | Medium | Medium | Semver major bump; escape hatches during transition |

---

## Alternatives Considered

### 1. Fork Foundation XML for iOS
Apple's open-source [swift-corelibs-foundation](https://github.com/swiftlang/swift-corelibs-foundation) includes `XMLDocument`/`XMLElement` for Linux. Theoretically portable to iOS.

**Rejected:** Enormous maintenance burden, fragile coupling to Foundation internals, no guarantee of correctness on iOS.

### 2. Rewrite everything with XMLParser (SAX)
Replace DOM-based XML with SAX parsing throughout.

**Rejected:** Pipeline Neo's value is DOM manipulation — creating, modifying, and exporting FCPXML. SAX is read-only. This would require a complete redesign of the library's core abstraction.

### 3. Use Codable/XMLCoder
Model FCPXML as Codable structs, encode/decode via XMLCoder.

**Rejected:** FCPXML's deeply nested, variadic structure (clips contain clips, arbitrary metadata, mixed content) makes Codable cumbersome. The DOM approach is fundamentally better suited for FCPXML manipulation.

### 4. Do nothing
Accept macOS-only as a permanent limitation.

**Rejected:** Limits adoption and excludes a growing market segment.

---

## Version Impact

This is a **semver major version bump** (3.0.0) due to public API type changes (`XMLElement` → `any PNXMLElement`). The Foundation backend ensures behavioral compatibility, but the type signature change requires a major bump per semver rules.

---

## References

- [AEXML](https://github.com/tadija/AEXML) — Cross-platform XML library
- [Pipeline Neo Architecture](ARCHITECTURE.md) — Current architecture and conventions
- [Mission Plan](MISSION-ios-xml-abstraction.md) — Detailed implementation requirements
- [Apple XMLDocument docs](https://developer.apple.com/documentation/foundation/xmldocument) — macOS-only API
- [FCPXML Reference](https://fcp.cafe/developers/fcpxml/) — FCPXML format specification
