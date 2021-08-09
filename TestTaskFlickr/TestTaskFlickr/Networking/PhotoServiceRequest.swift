//
// Copyright © 2020 Dmitry Rybakov. All rights reserved.

import Foundation

/// Represents all types of requests to the photo service
enum PhotoServiceRequest {
    /// Represents Url request that represents HTTP request to search a photo
    /// - Parameters:
    ///   - tags: A string which is used as a search query
    ///   - page: Represents a page number of the photos group to return
    ///   - perPage: Represents a number of items on each page
    case searchPhoto(tags: String, page: Int, perPage: Int)
}
