//
// Copyright © 2020 Dmitry Rybakov. All rights reserved.

import Foundation

protocol PhotoServiceRequestParametersBuilding {
    var methodName: String { get }
    var requestParameters: [URLQueryItem] { get }
}

extension PhotoServiceRequest: PhotoServiceRequestParametersBuilding {
    var methodName: String {
        switch self {
        case .searchPhoto:
            return "flickr.photos.search"
        }
    }
    var requestParameters: [URLQueryItem] {
        switch self {
        case let .searchPhoto(tags, page, perPage):
            return [
                URLQueryItem(name: "tags", value: tags),
                URLQueryItem(name: "format", value: "json"),
                URLQueryItem(name: "nojsoncallback", value: "true"),
                URLQueryItem(name: "extras", value: "media"),
                URLQueryItem(name: "extras", value: "url_sq"),
                URLQueryItem(name: "extras", value: "url_m"),
                URLQueryItem(name: "per_page", value: "\(perPage)"),
                URLQueryItem(name: "page", value: "\(page)"),
            ]
        }
    }
}
