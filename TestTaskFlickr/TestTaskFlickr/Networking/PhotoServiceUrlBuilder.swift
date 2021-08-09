//
// Copyright © 2020 Dmitry Rybakov. All rights reserved.

import Foundation

struct PhotoServiceUrlBuilder {
    let serviceBaseUrl: PhotoServiceBaseUrl
    let apiKey: String

    init(apiKey: String, serviceBaseUrl: PhotoServiceBaseUrl) {
        self.serviceBaseUrl = serviceBaseUrl
        self.apiKey = apiKey
    }
}

extension PhotoServiceUrlBuilder: PhotoServiceUrlBuilding {

    func makeURLRequest(from serviceRequest: PhotoServiceRequest) -> URLRequest {
        switch serviceRequest {
        case .searchPhoto(let tags, let page, let perPage):
            return makeSearchPhotoUrlRequest(for: tags, page: page, perPage: perPage)
        }
    }

    private func makeSearchPhotoUrlRequest(for tags: String, page: Int, perPage: Int) -> URLRequest {
        guard var urlComponents = URLComponents(string: serviceBaseUrl.rawValue) else {

            fatalError("Failed to initialize Flickr base URL")
        }
        urlComponents.queryItems = [
            URLQueryItem(name: "api_key", value: apiKey),
            URLQueryItem(name: "method", value: "flickr.photos.search"),
            URLQueryItem(name: "tags", value: tags),
            URLQueryItem(name: "format", value: "json"),
            URLQueryItem(name: "nojsoncallback", value: "true"),
            URLQueryItem(name: "extras", value: "media"),
            URLQueryItem(name: "extras", value: "url_sq"),
            URLQueryItem(name: "extras", value: "url_m"),
            URLQueryItem(name: "per_page", value: "\(perPage)"),
            URLQueryItem(name: "page", value: "\(page)"),
        ]

        // Normally it should be possible to return a Url
        guard let searchURL = urlComponents.url else {

            fatalError("Failed to build search URL")
        }

        return URLRequest(url: searchURL)
    }
}
