//
// Copyright © 2020 Dmitry Rybakov. All rights reserved.

import Foundation
import Combine

extension Publisher where Failure == Never {
    /// Helper function to avoid retain cycles
    func weakAssign<T: AnyObject>(
        to keyPath: ReferenceWritableKeyPath<T, Output>,
        on object: T
    ) -> AnyCancellable {
        sink { [weak object] value in
            object?[keyPath: keyPath] = value
        }
    }
}
