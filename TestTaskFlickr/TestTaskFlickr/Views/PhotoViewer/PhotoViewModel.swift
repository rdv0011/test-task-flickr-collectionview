//
// Copyright © 2020 Dmitry Rybakov. All rights reserved. 
    

import Foundation
import Combine
import UIKit

class PhotoViewModel: ObservableObject {
    typealias DataObject = PhotoMetadata
    typealias DataSection = Int

    @Published var snapshot : NSDiffableDataSourceSnapshot<DataSection, DataObject> = {
        // Setup one section only
        var snapshot = NSDiffableDataSourceSnapshot<DataSection, DataObject>()
        snapshot.appendSections([1])
        return snapshot
    }()

    private let photoService: PhotoServicable
    private var subscriptions = Set<AnyCancellable>()

    init(photoService: PhotoServicable) {
        self.photoService = photoService

        requestPhotos()
    }

    private func requestPhotos() {
        photoService.searchPhoto(by: "Electrolux", page: 1, perPage: 20)
            .receive(on: DispatchQueue.main)
            .collect()
            .sink { _ in
            } receiveValue: { [weak self] photoMetadata in
                print("\(photoMetadata)")
                self?.addItems(items: photoMetadata, to: 1)
            }
            .store(in: &subscriptions)
    }

    // MARK:- Helper function to add items
    private func addItems(items: [DataObject], to section: DataSection) {
        if snapshot.sectionIdentifiers.contains(section) {
            snapshot.appendItems(items, toSection: section)
        } else {
            snapshot.appendSections([section])
            snapshot.appendItems(items, toSection: section)
        }
    }
}
