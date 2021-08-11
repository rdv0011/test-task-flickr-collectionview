//
// Copyright © 2020 Dmitry Rybakov. All rights reserved. 

import Foundation

/// Represents networking related errors
enum NetworkRequestError: Error {
    case httpRequestFailed(statusCode: Int)
    case serverError(Error)
    /// Triggered when there is no HTTP status code available for some reason
    case unexpectedResponse
    case failedToParse(Error)
}
