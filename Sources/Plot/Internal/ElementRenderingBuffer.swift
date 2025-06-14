/**
*  Plot
*  Copyright (c) John Sundell 2021
*  MIT license, see LICENSE file for details
*/

import Foundation
import Synchronization

internal final class ElementRenderingBuffer: @unchecked Sendable {
    var containsChildElements = false

    private let element: AnyElement
    private let indentation: Indentation?

    private struct State {
        var body = ""
        var attributes = [AnyAttribute]()
        var attributeIndexes = [String : Int]()
    }
    private let state: Mutex<State>

    init(element: AnyElement, indentation: Indentation?) {
        self.element = element
        self.indentation = indentation
        self.state = Mutex(State())
    }

    func add(_ attribute: AnyAttribute) {
        state.withLock { state in
            if let existingIndex = state.attributeIndexes[attribute.name] {
                if attribute.replaceExisting {
                    state.attributes[existingIndex].value = attribute.value
                } else if let newValue = attribute.nonEmptyValue {
                    if let existingValue = state.attributes[existingIndex].nonEmptyValue {
                        state.attributes[existingIndex].value = existingValue + " " + newValue
                    } else {
                        state.attributes[existingIndex].value = newValue
                    }
                }
            } else {
                state.attributeIndexes[attribute.name] = state.attributes.count
                state.attributes.append(attribute)
            }
        }
    }

    func add(_ text: String, isPlainText: Bool) {
        state.withLock { state in
            if !isPlainText, indentation != nil {
                state.body.append("\n")
            }

            state.body.append(text)
        }
    }

    func flush() -> String {
        state.withLock { state in
            guard !element.name.isEmpty else { return state.body }

            let whitespace = indentation?.string ?? ""
            let padding = element.paddingCharacter.map(String.init) ?? ""
            var openingTag = "\(whitespace)<\(padding)\(element.name)"

            for attribute in state.attributes {
                let string = attribute.render()

                if !string.isEmpty {
                    openingTag.append(" " + string)
                }
            }

            let openingTagSuffix = padding + ">"

            switch element.closingMode {
            case .standard,
                    .selfClosing where containsChildElements:
                var string = openingTag + openingTagSuffix + state.body

                if indentation != nil && containsChildElements {
                    string.append("\n\(whitespace)")
                }

                return string + "</\(element.name)>"
            case .neverClosed:
                return openingTag + openingTagSuffix + state.body
            case .selfClosing:
                return openingTag + "/" + openingTagSuffix
            }
        }
    }
}
