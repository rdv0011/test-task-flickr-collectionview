//
// Copyright © 2020 Dmitry Rybakov. All rights reserved.
    

import Foundation
import Combine
import UIKit

final class PhotoService: PhotoServicable {
    struct Configuration {
        let baseUrl: PhotoServiceBaseUrl
        let urlSession: URLSession
        let jsonDecoder: JSONDecoder
    }

    private let urlBuilder: PhotoServiceUrlBuilding
    private let cache = ImageCache()
    private let configuration: Configuration

    init(urlBuilder: PhotoServiceUrlBuilding, configuration: Configuration) {
        self.urlBuilder = urlBuilder
        self.configuration = configuration
    }

    private func makeSearchPhotosUrlRequest(by tags: String, page: Int, perPage: Int) -> DecodableNetworkRequest<PhotoRootObjectMetadata> {
        let searchUrlRequest = urlBuilder.makeURLRequest(from: .searchPhoto(tags: tags,
                                                                            page: page,
                                                                            perPage: perPage))
        return DecodableNetworkRequest<PhotoRootObjectMetadata>(request: searchUrlRequest,
                                                                urlSession: configuration.urlSession,
                                                                jsonDecoder: configuration.jsonDecoder)
    }

    func searchPhotos(by tags: String, page: Int, perPage: Int) -> AnyPublisher<PhotoMetadata, PhotoServiceError> {
        makeSearchPhotosUrlRequest(by: tags, page: page, perPage: perPage)
            .publisher
            .map { rootObject -> [PhotoMetadata] in
                rootObject.photos.photo
            }
            .flatMap { photoUrls -> AnyPublisher<PhotoMetadata, PhotoServiceError> in
                Publishers.Sequence(sequence: photoUrls).eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    func photo(from url: URL) -> AnyPublisher<UIImage?, Never> {
        /// Send an asynchronous request. Once image is downloaded publish the result
        Just(url)
            .map { photoUrl -> AnyPublisher<UIImage?, Never> in
                guard let image = self.cache[photoUrl] else {
                    // Download image asynchronously and cache it
                    return configuration.urlSession.dataTaskPublisher(for: photoUrl)
                        .map { output -> UIImage? in
                            UIImage(data: output.data)
                        }
                        .replaceError(with: nil)
                        .handleEvents(receiveOutput: { [weak self] image in
                            guard let image = image else {
                                return
                            }
                            self?.cache[photoUrl] = image
                        })
                        .eraseToAnyPublisher()
                }
                // Return decompressed cached image to avoid UI stuttering
                return Just(image).eraseToAnyPublisher()
            }
            // Cancel previously made network requests
            .switchToLatest()
            .eraseToAnyPublisher()
    }
}
