//
// Copyright © 2020 Dmitry Rybakov. All rights reserved. 
    

import Foundation
import UIKit

/// Create different types of view models
class ViewModelFactory {
    private let photoServiceConfiguration: PhotoService.Configuration

    private lazy var photoService: PhotoService = {
        PhotoService(configuration: photoServiceConfiguration)
    }()

    func makePhotoViewModel() -> PhotoViewModel {
        PhotoViewModel(photoService: photoService)
    }

    init(photoServiceConfiguration: PhotoService.Configuration) {
        self.photoServiceConfiguration = photoServiceConfiguration
    }
}
