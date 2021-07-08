//
// Copyright © 2020 Rybakov Dmitry. All rights reserved.

import Foundation
import UIKit
import Combine

extension UIImage {
    static func imagePublisher(from imageURL: URL) -> AnyPublisher<UIImage?, Never> {
        Future<UIImage?, Never>() { promise in
            let task = URLSession.shared.dataTask(with: imageURL) { data, response, error in
                guard let data = data, error == nil else {
                    promise(.success(nil))
                    return
                }
                DispatchQueue.main.async() {
                    promise(.success(UIImage(data: data)))
                }
            }
            task.resume()
        }
        .eraseToAnyPublisher()
    }
}
