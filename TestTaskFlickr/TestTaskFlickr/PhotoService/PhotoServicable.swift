//
// Copyright © 2020 Dmitry Rybakov. All rights reserved.

import Foundation
import Combine
import UIKit

/// Manages networking JSON requests
protocol PhotoServicable {
    /// Returns photo metadata from a photo service
    /// - Note: Assume that all photo objects are grouped by pages
    /// - Parameters:
    ///   - tags: A string which is used as a search query
    ///   - page: Represents a page number of the photos group to return
    ///   - perPage: Represents a number of items on each page
    func searchPhotos(for tags: String,at page: Int,max perPage: Int) -> AnyPublisher<PhotoMetadata, NetworkRequestError>
    /// Downloads photo by provided url
    /// - Parameters:
    ///   - url: Photo url
    /// - Returns: An image otherwise nil if error happens
    func photo(from url: URL) -> AnyPublisher<UIImage?, Never>
}
