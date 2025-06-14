/**
*  Plot
*  Copyright (c) John Sundell 2021
*  MIT license, see LICENSE file for details
*/

import Foundation
import Synchronization

internal struct Environment: Sendable {
    private var values = [String : Sendable]()

    subscript<T: Sendable>(key: EnvironmentKey<T>) -> T? {
        get { values["\(key.identifier)"] as? T }
        set { values["\(key.identifier)"] = newValue }
    }
}

extension Environment {
    final class Reference: @unchecked Sendable {
        private let value: Mutex<Environment?> = .init(nil)

        func withLock<R: Sendable>(_ body: @Sendable (inout Environment?) throws -> R) rethrows -> R {
            try value.withLock { try body(&$0) }
        }
    }

    struct Override: Sendable {
        private let closure: @Sendable (inout Environment) -> Void

        init<T: Sendable>(key: EnvironmentKey<T>, value: T) {
            closure = { $0[key] = value }
        }

        func apply(to environment: inout Environment) {
            closure(&environment)
        }
    }
}
