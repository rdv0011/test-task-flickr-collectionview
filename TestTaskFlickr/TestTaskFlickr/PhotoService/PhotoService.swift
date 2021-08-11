//
// Copyright © 2020 Dmitry Rybakov. All rights reserved.
    

import Foundation
import Combine
import UIKit

final class PhotoService: PhotoServicable {
    struct Configuration {
        let baseUrl: PhotoServiceBaseUrl
        let apiKey: String
        let urlSession: URLSession
        let jsonDecoder: JSONDecoder
    }

    private let cache = ImageCache()
    private let configuration: Configuration

    init(configuration: Configuration) {
        self.configuration = configuration
    }

    func searchPhotos(for tags: String,at page: Int,max perPage: Int) -> AnyPublisher<PhotoMetadata, NetworkRequestError> {
        makeSearchPhotosUrlRequest(by: tags, page: page, perPage: perPage)
            .publisher()
            .map { rootObject -> [PhotoMetadata] in
                rootObject.photos.photo
            }
            .flatMap { photoUrls -> AnyPublisher<PhotoMetadata, NetworkRequestError> in
                Publishers.Sequence(sequence: photoUrls).eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    func photo(from url: URL) -> AnyPublisher<UIImage?, Never> {
        /// Send an asynchronous request. Once image is downloaded publish the result
        let dataRequest =
            PhotoServiceDataRequestUrlBuilder(downloadingUrl: url)
            .build()
        return ImageCashableNetworkRequest(request: dataRequest,
                                    urlSession: configuration.urlSession,
                                    cache: cache)
            .publisher()
            // Replace failed requests with nil which will be interpreted somehow in the UI
            .replaceError(with: nil)
            .eraseToAnyPublisher()
    }

    private func makeUrlBuilder(using parametersBuilder: PhotoServiceRequestParametersBuilding) -> UrlBuilding {
        PhotoServiceJsonRequestUrlBuilder(serviceBaseUrl: configuration.baseUrl,
                                          apiKey: configuration.apiKey,
                                          parametersBuilder: parametersBuilder)
    }

    private func makeSearchPhotosUrlRequest(by tags: String, page: Int, perPage: Int) -> DecodableNetworkRequest<PhotoRootObjectMetadata> {
        let searchPhotoRequest = PhotoServiceRequest.searchPhoto(tags: tags,
                                                                 page: page,
                                                                 perPage: perPage)
        let searchUrlRequest = makeUrlBuilder(using: searchPhotoRequest).build()
        return DecodableNetworkRequest<PhotoRootObjectMetadata>(request: searchUrlRequest,
                                                                urlSession: configuration.urlSession,
                                                                jsonDecoder: configuration.jsonDecoder)
    }
}
