//
// Copyright © 2020 Dmitry Rybakov. All rights reserved. 
    

import Foundation
import UIKit

/// Create different types of view models
class ViewModelFactory {
    private let apiKey: String
    private let photoServiceConfiguration: PhotoService.Configuration

    private lazy var photoServiceUrlBuilder: PhotoServiceUrlBuilder = {
        PhotoServiceUrlBuilder(apiKey: apiKey, serviceBaseUrl: photoServiceConfiguration.baseUrl)
    }()

    private lazy var photoService: PhotoService = {
        PhotoService(urlBuilder: photoServiceUrlBuilder, configuration: photoServiceConfiguration)
    }()

    func makePhotoViewModel() -> PhotoViewModel {
        PhotoViewModel(photoService: photoService)
    }

    init(apiKey: String, photoServiceConfiguration: PhotoService.Configuration) {
        self.apiKey = apiKey
        self.photoServiceConfiguration = photoServiceConfiguration
    }
}
