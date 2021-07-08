//
// Copyright © 2020 Dmitry Rybakov. All rights reserved. 
    

import Foundation
import UIKit

/// Create different types of view models
class ViewModelFactory {
    private let apiKey: String

    func makePhotoViewModel() -> PhotoViewModel {
        PhotoViewModel(photoService: PhotoService(urlBuilder: PhotoServiceURLBuilder(apiKey: apiKey)))
    }

    init(apiKey: String) {
        self.apiKey = apiKey
    }
}
