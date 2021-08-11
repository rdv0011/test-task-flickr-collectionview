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
    func makePhotoServiceConfiguration(apiKey: String) -> PhotoService.Configuration {
        switch self {
        case .dev:
            return makeDebugPhotoServiceConfiguration(apiKey: apiKey)
        }
    }

    private func makeDebugPhotoServiceConfiguration(apiKey: String) -> PhotoService.Configuration {
        PhotoService.Configuration(baseUrl: .dev,
                                   apiKey: apiKey,
                                   urlSession: URLSession.shared,
                                   jsonDecoder: JSONDecoder())
    }
}
