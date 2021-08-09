//
// Copyright © 2020 Dmitry Rybakov. All rights reserved.

import Foundation

enum ServiceEnvironment {
    case dev
}

enum PhotoServiceBaseUrl: String {
    case dev = "https://api.flickr.com/services/rest"
}

extension ServiceEnvironment {
    func makePhotoServiceConfiguration() -> PhotoService.Configuration {
        switch self {
        case .dev:
            return makeDebugPhotoServiceConfiguration()
        }
    }

    private func makeDebugPhotoServiceConfiguration() -> PhotoService.Configuration {
        PhotoService.Configuration(baseUrl: .dev, urlSession: URLSession.shared, jsonDecoder: JSONDecoder())
    }
}
