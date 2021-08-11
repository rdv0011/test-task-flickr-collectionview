//
// Copyright © 2020 Dmitry Rybakov. All rights reserved.

import Foundation

/// Builds a specific API Url request based on arguments
protocol UrlBuilding {
    /// Returns Url request that represents HTTP request to search a photo
    func build() -> URLRequest
}

class PhotoServiceUrlBuilder: UrlBuilding {
    var urlComponents: URLComponents
    private let queryItemApiKey = "api_key"
    private let queryItemMethod = "method"

    init(urlString: String) {
        guard let urlComponents = URLComponents(string: urlString) else {

            fatalError("Failed to initialize Flickr base URL")
        }
        self.urlComponents = urlComponents
    }

    private func currentParameters() -> [URLQueryItem] {
        urlComponents.queryItems ?? []
    }

    func commonItemsAdded(apiKey: String) -> PhotoServiceUrlBuilder {
        urlComponents.queryItems = currentParameters() + [
            URLQueryItem(name: queryItemApiKey,
                         value: apiKey)
        ]

        return self
    }

    func methodAdded(using parametersBuilder: PhotoServiceRequestParametersBuilding) -> PhotoServiceUrlBuilder {
        urlComponents.queryItems = currentParameters() + [
            URLQueryItem(name: queryItemMethod,
                         value: parametersBuilder.methodName),
        ]

        return self
    }

    func parametersAdded(using parametersBuilder: PhotoServiceRequestParametersBuilding) -> PhotoServiceUrlBuilder {
        urlComponents.queryItems = currentParameters() + parametersBuilder.requestParameters

        return self
    }

    func build() -> URLRequest {
        // Normally it should be possible to return a Url
        guard let searchURL = urlComponents.url else {

            fatalError("Failed to build search URL")
        }

        return URLRequest(url: searchURL)
    }
}


struct PhotoServiceJsonRequestUrlBuilder {
    let serviceBaseUrl: PhotoServiceBaseUrl
    let apiKey: String
    let parametersBuilder: PhotoServiceRequestParametersBuilding
}

extension PhotoServiceJsonRequestUrlBuilder: UrlBuilding {

    func build() -> URLRequest {
        PhotoServiceUrlBuilder(urlString: serviceBaseUrl.rawValue)
            .commonItemsAdded(apiKey: apiKey)
            .methodAdded(using: parametersBuilder)
            .parametersAdded(using: parametersBuilder)
            .build()
    }
}


struct PhotoServiceDataRequestUrlBuilder {
    let downloadingUrl: URL
}

extension PhotoServiceDataRequestUrlBuilder: UrlBuilding {

    func build() -> URLRequest {
        PhotoServiceUrlBuilder(urlString: downloadingUrl.absoluteString)
            .build()
    }
}
