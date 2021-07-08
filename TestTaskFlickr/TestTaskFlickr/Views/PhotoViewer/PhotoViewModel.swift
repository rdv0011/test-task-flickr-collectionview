//
// Copyright © 2020 Dmitry Rybakov. All rights reserved. 
    

import Foundation
import Combine
import UIKit

/// Represents a view model for a photo view
/// Uses photo service to make a network requests and retrieve photo metadata
/// Keeps a data source snapshot to feed the UI with data
final class PhotoViewModel: ObservableObject {
    typealias DataObject = PhotoMetadata
    typealias DataSection = Int

    // MARK: - Constants
    private static let sectionIndex = 1
    private let pageNumber = 1
    private let perPage = 20
    private let searchKeyword = "Electrolux"
    private let cache = ImageCache()

    @Published var snapshot : NSDiffableDataSourceSnapshot<DataSection, DataObject> = {
        // Setup one section only
        var snapshot = NSDiffableDataSourceSnapshot<DataSection, DataObject>()
        snapshot.appendSections([PhotoViewModel.sectionIndex])
        return snapshot
    }()

    private let photoService: PhotoServicable
    private var subscriptions = Set<AnyCancellable>()

    init(photoService: PhotoServicable) {
        self.photoService = photoService
        // Send the initial request to get photos
        requestPhotos()
    }

    func imagePublisher(_ imageUrl: URL) -> AnyPublisher<UIImage?, Never> {
        Just(imageUrl)
            .flatMap { [unowned self] imageUrl -> AnyPublisher<UIImage?, Never> in
                guard let image = self.cache[imageUrl] else {
                    // Download image asynchronously and cache it
                    return UIImage.imagePublisher(from: imageUrl)
                        .handleEvents(receiveOutput: { [unowned self] image in
                            guard let image = image else {
                                return
                            }
                            self.cache[imageUrl] = image
                        })
                        .eraseToAnyPublisher()
                }
                // Return decompressed cached image to avoid UI stuttering
                return Just(image).eraseToAnyPublisher()
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    private func requestPhotos() {
        photoService.searchPhotos(by: searchKeyword, page: pageNumber, perPage: perPage)
            .receive(on: DispatchQueue.main)
            // Filter out metadata with empty urls
            .compactMap { photoMetadata in photoMetadata.imageURL != nil ? photoMetadata: nil }
            // Wait for all photo metadata to set it at one step to avoid too frequent UI updates
            .collect()
            .sink { _ in
            } receiveValue: { [unowned self] photoMetadata in
                // Add metadata to the data source snapshot
                self.addItems(items: photoMetadata, to: Self.sectionIndex)
            }
            .store(in: &subscriptions)
    }

    // Helper function to add items
    private func addItems(items: [DataObject], to section: DataSection) {
        if snapshot.sectionIdentifiers.contains(section) {
            snapshot.appendItems(items, toSection: section)
        } else {
            snapshot.appendSections([section])
            snapshot.appendItems(items, toSection: section)
        }
    }
}
