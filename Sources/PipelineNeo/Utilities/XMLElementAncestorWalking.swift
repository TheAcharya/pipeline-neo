//
//  XMLElementAncestorWalking.swift
//  Pipeline Neo • https://github.com/TheAcharya/pipeline-neo
//  © 2026 • Licensed under MIT License


//
//	XMLElement extension for walking ancestor elements.
//

import Foundation
import SwiftExtensions

extension XMLElement {
    /// Walk ancestors of the element.
    func walkAncestorElements(
        includingSelf: Bool,
        _ block: (_ element: XMLElement) -> Bool
    ) {
        let blockWithResult: (_ element: XMLElement) -> WalkAncestorsIntermediateResult<Void> = { element in
            if block(element) {
                return .continue
            } else {
                return .return(withValue: ())
            }
        }
        _ = Self.walkAncestorElements(
            startingWith: includingSelf ? self : parentElement,
            returning: Void.self,
            block: blockWithResult
        )
    }

    /// Walk ancestors of the element, returning a value from the block.
    func walkAncestorElements<T>(
        includingSelf: Bool,
        returning: T.Type,
        _ block: (_ element: XMLElement) -> WalkAncestorsIntermediateResult<T>
    ) -> WalkAncestorsResult<T> {
        Self.walkAncestorElements(
            startingWith: includingSelf ? self : parentElement,
            returning: returning,
            block: block
        )
    }

    private static func walkAncestorElements<T>(
        startingWith element: XMLElement?,
        returning: T.Type,
        block: (_ element: XMLElement) -> WalkAncestorsIntermediateResult<T>
    ) -> WalkAncestorsResult<T> {
        guard let element = element else { return .exhaustedAncestors }
        let blockResult = block(element)
        switch blockResult {
        case .continue:
            guard let parent = element.parentElement else { return .exhaustedAncestors }
            return walkAncestorElements(startingWith: parent, returning: returning, block: block)
        case .return(let value):
            return .value(value)
        case .failure:
            return .failure
        }
    }

    enum WalkAncestorsIntermediateResult<T> {
        case `continue`
        case `return`(withValue: T)
        case failure
    }

    enum WalkAncestorsResult<T> {
        case exhaustedAncestors
        case value(_ value: T)
        case failure
    }
}

extension XMLElement {
    /// Returns a sequence of ancestor elements (nearest first). Does not include self.
    func ancestorElements(includingSelf: Bool) -> AnySequence<XMLElement> {
        let current: XMLElement? = includingSelf ? self : parentElement
        return AnySequence(sequence(first: current) { el in
            el?.parentElement
        }.compactMap { $0 })
    }

    /// Returns ancestor elements; if `replacement` is non-nil, uses it instead of actual ancestors.
    func ancestorElements<S: Sequence<XMLElement>>(
        overrideWith replacement: S?,
        includingSelf: Bool
    ) -> AnySequence<XMLElement> {
        if let replacement = replacement {
            if includingSelf {
                return ([self] + replacement).asAnySequence
            } else {
                return replacement.asAnySequence
            }
        } else {
            return ancestorElements(includingSelf: includingSelf).asAnySequence
        }
    }
}
