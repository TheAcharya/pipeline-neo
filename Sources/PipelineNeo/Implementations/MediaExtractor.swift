//
//  MediaExtractor.swift
//  Pipeline Neo • https://github.com/TheAcharya/pipeline-neo
//  © 2026 • Licensed under MIT License
//

//
//	Default implementation of MediaExtraction: extracts asset media-rep and locator URLs, copies files.
//

import Foundation
import SwiftExtensions

/// Default implementation of `MediaExtraction`.
@available(macOS 12.0, *)
public final class MediaExtractor: MediaExtraction, Sendable {

    public init() {}

    // MARK: - MediaExtraction (Sync)

    public func extractMediaReferences(from document: XMLDocument, baseURL: URL?) -> MediaExtractionResult {
        _extract(from: document, baseURL: baseURL)
    }

    public func copyReferencedMedia(from document: XMLDocument, to destinationURL: URL, baseURL: URL?, progress: (any ProgressReporter)? = nil) -> MediaCopyResult {
        _copy(from: document, to: destinationURL, baseURL: baseURL, progress: progress)
    }

    // MARK: - MediaExtraction (Async)

    public func extractMediaReferences(from document: XMLDocument, baseURL: URL?) async -> MediaExtractionResult {
        _extract(from: document, baseURL: baseURL)
    }

    public func copyReferencedMedia(from document: XMLDocument, to destinationURL: URL, baseURL: URL?, progress: (any ProgressReporter)? = nil) async -> MediaCopyResult {
        _copy(from: document, to: destinationURL, baseURL: baseURL, progress: progress)
    }

    // MARK: - Private

    private func _extract(from document: XMLDocument, baseURL: URL?) -> MediaExtractionResult {
        var refs: [MediaReference] = []
        let resources = document.fcpxResources

        for resource in resources {
            let elementType = resource.fcpxType
            if elementType == .assetResource {
                if let ref = _assetMediaReference(resource, baseURL: baseURL) {
                    refs.append(ref)
                }
            } else if elementType == .locator {
                if let ref = _locatorMediaReference(resource, baseURL: baseURL) {
                    refs.append(ref)
                }
            }
        }
        return MediaExtractionResult(references: refs, baseURL: baseURL)
    }

    private func _assetMediaReference(_ assetElement: XMLElement, baseURL: URL?) -> MediaReference? {
        guard let mediaRep = assetElement.firstChildElement(named: "media-rep") else { return nil }
        let srcString = mediaRep.getElementAttribute("src")
        guard let srcString = srcString, !srcString.isEmpty else { return nil }
        let url = _resolveURL(srcString, baseURL: baseURL)
        let resourceID = assetElement.fcpxID ?? assetElement.getElementAttribute("id") ?? ""
        let name = assetElement.fcpxName ?? assetElement.getElementAttribute("name")
        let suggestedFilename = mediaRep.getElementAttribute("suggestedFilename") ?? url?.lastPathComponent
        return MediaReference(
            resourceID: resourceID,
            url: url,
            name: name,
            suggestedFilename: suggestedFilename,
            isLocator: false
        )
    }

    private func _locatorMediaReference(_ locatorElement: XMLElement, baseURL: URL?) -> MediaReference? {
        let urlString = locatorElement.getElementAttribute("url")
        guard let urlString = urlString, !urlString.isEmpty else { return nil }
        let url = _resolveURL(urlString, baseURL: baseURL)
        let resourceID = locatorElement.fcpxID ?? locatorElement.getElementAttribute("id") ?? ""
        return MediaReference(
            resourceID: resourceID,
            url: url,
            name: nil,
            suggestedFilename: url?.lastPathComponent,
            isLocator: true
        )
    }

    private func _resolveURL(_ srcString: String, baseURL: URL?) -> URL? {
        if let u = URL(string: srcString), u.scheme != nil {
            return u
        }
        if let base = baseURL {
            return URL(string: srcString, relativeTo: base)?.absoluteURL
        }
        return URL(string: srcString)
    }

    private func _copy(from document: XMLDocument, to destinationURL: URL, baseURL: URL?, progress: (any ProgressReporter)?) -> MediaCopyResult {
        let result = _extract(from: document, baseURL: baseURL)
        let fileRefs = result.fileReferences
        var seenSourceURLs: Set<URL> = []
        var usedFilenames: Set<String> = []
        var entries: [MediaCopyEntry] = []
        var processed = 0

        let fm = FileManager.default
        for ref in fileRefs {
            guard let sourceURL = ref.url else {
                continue
            }
            guard sourceURL.isFileURL else {
                entries.append(.skipped(source: sourceURL, reason: "Not a file URL"))
                continue
            }
            if seenSourceURLs.contains(sourceURL) {
                entries.append(.skipped(source: sourceURL, reason: "Duplicate"))
                continue
            }
            seenSourceURLs.insert(sourceURL)
            let filename = _uniqueFilename(
                preferred: ref.suggestedFilename ?? sourceURL.lastPathComponent,
                existing: &usedFilenames
            )
            usedFilenames.insert(filename)
            let destURL = destinationURL.appendingPathComponent(filename)
            if !fm.fileExists(atPath: sourceURL.path) {
                entries.append(.skipped(source: sourceURL, reason: "File does not exist"))
                continue
            }
            do {
                if fm.fileExists(atPath: destURL.path) {
                    try fm.removeItem(at: destURL)
                }
                try fm.copyItem(at: sourceURL, to: destURL)
                entries.append(.copied(source: sourceURL, destination: destURL))
            } catch {
                entries.append(.failed(source: sourceURL, error: error.localizedDescription))
            }
            processed += 1
            progress?.advance(by: 1)
        }
        progress?.finish()
        return MediaCopyResult(entries: entries)
    }

    private func _uniqueFilename(preferred: String, existing: inout Set<String>) -> String {
        let base = preferred.isEmpty ? "media" : preferred
        if !existing.contains(base) {
            return base
        }
        let ext = (base as NSString).pathExtension
        let stem = (base as NSString).deletingPathExtension
        var n = 1
        while true {
            let candidate = ext.isEmpty ? "\(stem)_\(n)" : "\(stem)_\(n).\(ext)"
            if !existing.contains(candidate) {
                return candidate
            }
            n += 1
        }
    }
}
