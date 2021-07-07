//
// Copyright © 2020 Dmitry Rybakov. All rights reserved. 
    

import Foundation
import Combine
import UIKit

class PhotoViewModel: ObservableObject {
    @Published var photos = [UIImage]()
    private let photoService: PhotoServicable
    private var subscriptions = Set<AnyCancellable>()

    init(photoService: PhotoServicable) {
        self.photoService = photoService

        // Test call
        photoService.searchPhoto(by: "Electrolux", page: 1, perPage: 20)
            .sink { completion in
            } receiveValue: { photoMetadata in
                print("\(photoMetadata)")
            }
            .store(in: &subscriptions)

    }
}
