//
// Copyright © 2020 Dmitry Rybakov. All rights reserved.

import Foundation
import Combine
import UIKit

protocol NetworkRequest {
    associatedtype Response
    associatedtype Error: Swift.Error

    func publisher() -> AnyPublisher<Response, Error>
}

/// Type erasure for ```NetworkRequest``` type
struct AnyNetworkRequest<Response, Error: Swift.Error> {

    var wrappedPublisher: () -> AnyPublisher<Response, Error>

    init<T: NetworkRequest>(_ wrappedRequest: T) where T.Response == Response,
                                                       T.Error == Error {
        self.wrappedPublisher = wrappedRequest.publisher
    }

    func publisher() -> AnyPublisher<Response, Error> {
        wrappedPublisher()
    }
}

struct DataNetworkRequest: NetworkRequest {
    typealias Response = Data
    typealias Error = NetworkRequestError

    let request: URLRequest
    let urlSession: URLSession

    func publisher() -> AnyPublisher<Response, Error> {
        urlSession.dataTaskPublisher(for: request)
            .tryMap { data, response -> Data in
                guard
                    let response = response as? HTTPURLResponse,  // is there HTTP response
                    200 ..< 300 ~= response.statusCode           // is statusCode 2XX
                else {
                    let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
                    if statusCode > 0 {
                        throw NetworkRequestError.httpRequestFailed(statusCode: statusCode)
                    } else {
                        throw NetworkRequestError.unexpectedResponse
                    }
                }
                return data
            }
            .mapError { error in
                error as? NetworkRequestError ?? NetworkRequestError.serverError(error)
            }
            .eraseToAnyPublisher()
    }
}


struct DecodableNetworkRequest<T: Decodable>: NetworkRequest {
    typealias Response = T
    typealias Error = NetworkRequestError

    let request: URLRequest
    let urlSession: URLSession
    let jsonDecoder: JSONDecoder

    func publisher() -> AnyPublisher<Response, Error> {
        DataNetworkRequest(request: request, urlSession: urlSession)
            .publisher()
            .decode(type: T.self, decoder: jsonDecoder)
            .mapError { error in
                if error is DecodingError {
                    return NetworkRequestError.failedToParse(error)
                } else {
                    return error as? NetworkRequestError ?? NetworkRequestError.serverError(error)
                }
            }
            .eraseToAnyPublisher()
    }
}

struct ImageCashableNetworkRequest: NetworkRequest {
    typealias Response = UIImage?
    typealias Error = NetworkRequestError

    let request: URLRequest
    let urlSession: URLSession
    let cache: ImageCache

    private func makeRequestPublisher(imageUrl: URL, request: URLRequest, urlSession: URLSession, imageCache: ImageCache) -> AnyPublisher<Response, NetworkRequestError> {
        return DataNetworkRequest(request: request,
                                  urlSession: urlSession)
            .publisher()
            .map { data -> Response in
                UIImage(data: data)
            }
            .handleEvents(receiveOutput: { image in
                guard let image = image else {
                    return
                }
                cache[imageUrl] = image
            })
            .eraseToAnyPublisher()
    }

    func publisher() -> AnyPublisher<Response, Error> {
        guard let imageUrl = request.url else {
            fatalError("Failed to get url from \(request)")
        }
        /// Send an asynchronous request. Once image is downloaded publish the result
        return Just(imageUrl)
            .map { photoUrl -> AnyPublisher<Response, NetworkRequestError> in
                guard let image = self.cache[photoUrl] else {
                    // Download image asynchronously and cache it
                    return makeRequestPublisher(imageUrl: imageUrl,
                                                request: request,
                                                urlSession: urlSession,
                                                imageCache: cache)
                }
                // Return decompressed cached image to avoid UI stuttering
                return Just(image)
                    .setFailureType(to: NetworkRequestError.self)
                    .eraseToAnyPublisher()
            }
            // Cancel previously made network requests
            .switchToLatest()
            .eraseToAnyPublisher()
    }
}
