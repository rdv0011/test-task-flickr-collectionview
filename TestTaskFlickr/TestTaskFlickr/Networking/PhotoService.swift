//
// Copyright © 2020 Dmitry Rybakov. All rights reserved.
    

import Foundation
import Combine
import UIKit

final class PhotoService: PhotoServicable {
    private let urlBuilder: PhotoServiceURLBuilding
    private let urlSession: URLSession
    private let jsonDecoder: JSONDecoder
    private let cache = ImageCache()

    init(urlBuilder: PhotoServiceURLBuilding,
         urlSession: URLSession = URLSession.shared,
         jsonDecoder: JSONDecoder = JSONDecoder()) {
        self.urlBuilder = urlBuilder
        self.urlSession = urlSession
        self.jsonDecoder = jsonDecoder
    }

    func searchPhotos(by tags: String, page: Int, perPage: Int) -> AnyPublisher<PhotoMetadata, Error> {
        let searchUrlRequest = urlBuilder.searchPhotoURLRequest(for: tags, page: page, perPage: perPage)

        return Future<Data, Error>() { [weak self] promise in
            guard let self = self else { return }

            let dataTask = self.urlSession.dataTask(with: searchUrlRequest) { data, response, error in
                guard
                    let data = data,                              // is there data
                    let response = response as? HTTPURLResponse,  // is there HTTP response
                    200 ..< 300 ~= response.statusCode,           // is statusCode 2XX
                    error == nil                                  // was there no error
                else {
                    if let error = error {
                        promise(.failure(error))
                    } else {
                        // No error is provided. Use ```.unexpectedResponse``` as a default one.
                        promise(.failure(PhotoServiceError.unexpectedResponse))
                    }
                    return
                }
                promise(.success(data))
            }
            dataTask.resume()
        }
        .decode(type: PhotoRootObjectMetadata.self, decoder: jsonDecoder)
        .flatMap { rootObject -> AnyPublisher<PhotoMetadata, Error> in
            Publishers.Sequence(sequence: rootObject.photos.photo).eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()
    }

    func photo(from url: URL) -> AnyPublisher<UIImage?, Never> {
        /// Send an asynchronous request. Once image is downloaded publishes a result
        Just(url)
            .map { photoUrl -> AnyPublisher<UIImage?, Never> in
                guard let image = self.cache[photoUrl] else {
                    // Download image asynchronously and cache it
                    return urlSession.dataTaskPublisher(for: photoUrl)
                        .map { output -> UIImage? in
                            UIImage(data: output.data)
                        }
                        .replaceError(with: nil)
                        .handleEvents(receiveOutput: { [unowned self] image in
                            guard let image = image else {
                                return
                            }
                            self.cache[photoUrl] = image
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
