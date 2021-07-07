//
// Copyright © 2020 Dmitry Rybakov. All rights reserved.
    

import Foundation
import Combine

class PhotoService: PhotoServicable {
    private let urlBuilder: PhotoServiceURLBuilding
    private let urlSession: URLSession
    private let jsonDecoder: JSONDecoder

    init(urlBuilder: PhotoServiceURLBuilding,
         urlSession: URLSession = URLSession.shared,
         jsonDecoder: JSONDecoder = JSONDecoder()) {
        self.urlBuilder = urlBuilder
        self.urlSession = urlSession
        self.jsonDecoder = jsonDecoder
    }

    func searchPhoto(by tags: String, page: Int, perPage: Int) -> AnyPublisher<PhotoMetadata, Error> {
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

    func photo(for id: String) -> AnyPublisher<Data, Error> {
        fatalError("No implementation")
        Just(Data()).setFailureType(to: Error.self).eraseToAnyPublisher()
    }
}
