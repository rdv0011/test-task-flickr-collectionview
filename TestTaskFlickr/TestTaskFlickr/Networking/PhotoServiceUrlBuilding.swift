//
// Copyright © 2020 Dmitry Rybakov. All rights reserved. 
    

import Foundation

/// Builds a specific API Url request based on arguments
protocol PhotoServiceUrlBuilding {
    /// Returns Url request that represents HTTP request to search a photo
    /// - Parameters:
    ///   - serviceRequest: a type of the request
    func makeURLRequest(from serviceRequest: PhotoServiceRequest) -> URLRequest
}
