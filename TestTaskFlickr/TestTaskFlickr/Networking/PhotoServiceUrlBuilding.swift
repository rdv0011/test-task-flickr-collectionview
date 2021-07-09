//
// Copyright © 2020 Dmitry Rybakov. All rights reserved. 
    

import Foundation

/// Builds a specific API Url request based on arguments
protocol PhotoServiceUrlBuilding {
    /// Returns Url request that represents HTTP request to search a photo
    /// - Parameters:
    ///   - tags: A string which is used as a search query
    ///   - page: Represents a page number of the photos group to return
    ///   - perPage: Represents a number of items on each page
    func searchPhotoUrlRequest(for tags: String, page: Int, perPage: Int) -> URLRequest
}
