//
// Copyright © 2020 Dmitry Rybakov. All rights reserved. 

import Foundation

/// Represents networking related errors
enum PhotoServiceError: Error {
    case httpRequestFailed(statusCode: Int)
    case serverError(Error)
    case unexpectedResponse
    case failedToParse(Error)
}
