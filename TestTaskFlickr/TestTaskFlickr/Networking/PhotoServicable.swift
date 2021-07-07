//
// Copyright © Dmitry Rybakov. All rights reserved.

import Foundation
import Combine

/// Manages networking JSON requests
protocol PhotoServicable {
    /// Returns photo metadata from a photo service
    /// - Note: Assume that all photo objects are grouped by pages
    /// - Parameters:
    ///   - tags: A string which is used as a search query
    ///   - page: Represents a page number of the photos group to return
    ///   - perPage: Represents a number of items on each page
    func searchPhoto(by tags: String, page: Int, perPage: Int) -> AnyPublisher<PhotoMetadata, Error>
    /// Returns photo data
    /// - Parameters:
    ///   - id: The identifier of the photo on the service
    func photo(for id: String) -> AnyPublisher<Data, Error>
}
