//
// Copyright © 2020 Dmitry Rybakov. All rights reserved.

import Foundation
import Combine

protocol NetworkRequest {
    associatedtype Response
    associatedtype Error: Swift.Error

    var publisher: AnyPublisher<Response, Error> { get }
}

/// Type erasure for ```NetworkRequest``` type
struct AnyNetworkRequest<Response, Error: Swift.Error> {

    var publisher: AnyPublisher<Response, Error>
}

struct DataNetworkRequest: NetworkRequest {
    typealias Response = Data
    typealias Error = PhotoServiceError

    let request: URLRequest
    let urlSession: URLSession

    var publisher: AnyPublisher<Response, Error> {
        urlSession.dataTaskPublisher(for: request)
            .tryMap { data, response -> Data in
                guard
                    let response = response as? HTTPURLResponse,  // is there HTTP response
                    200 ..< 300 ~= response.statusCode           // is statusCode 2XX
                else {
                    let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
                    if statusCode > 0 {
                        throw PhotoServiceError.httpRequestFailed(statusCode: statusCode)
                    } else {
                        throw PhotoServiceError.unexpectedResponse
                    }
                }
                return data
            }
            .mapError { error in
                error as? PhotoServiceError ?? PhotoServiceError.serverError(error)
            }
            .eraseToAnyPublisher()
    }
}


struct DecodableNetworkRequest<T: Decodable>: NetworkRequest {
    typealias Response = T
    typealias Error = PhotoServiceError

    let request: URLRequest
    let urlSession: URLSession
    let jsonDecoder: JSONDecoder

    var publisher: AnyPublisher<Response, Error> {
        DataNetworkRequest(request: request, urlSession: urlSession)
            .publisher
            .tryMap { data in
                do {
                    return try jsonDecoder.decode(T.self, from: data)
                } catch {
                    throw PhotoServiceError.failedToParse(error)
                }
            }
            .mapError { error in
                error as? PhotoServiceError ?? PhotoServiceError.serverError(error)
            }
            .eraseToAnyPublisher()
    }
}
