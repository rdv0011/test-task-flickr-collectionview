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
    @Published var searchKeyword = "Electrolux"

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
        // Subscribe for publishers
        subscribe()
    }

    func photoPublisher(_ photoUrl: URL) -> AnyPublisher<UIImage?, Never> {
        photoService.photo(from: photoUrl)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    private func subscribe() {
        $searchKeyword
            .debounce(for: 0.3, scheduler: DispatchQueue.main)
            .removeDuplicates()
            .flatMap { [photoService, pageNumber, perPage] keyword in
                photoService.searchPhotos(by: keyword, page: pageNumber, perPage: perPage)
                // Filter out metadata with empty urls
                .filter { photoMetadata in photoMetadata.photoUrl != nil }
                // Wait for all photo metadata to set it at one step to avoid too frequent UI updates
                .collect()
            }
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in
            }, receiveValue: { photoMetadata in
                self.replaceItems(items: photoMetadata, to: Self.sectionIndex)
            })
            .store(in: &subscriptions)
    }

    // Helper function to add items
    private func replaceItems(items: [DataObject], to section: DataSection) {
        let identifiers = snapshot.itemIdentifiers
        if identifiers.count > 0 {
            snapshot.deleteItems(identifiers)
        }
        if snapshot.sectionIdentifiers.contains(section) {
            snapshot.appendItems(items, toSection: section)
        } else {
            snapshot.appendSections([section])
            snapshot.appendItems(items, toSection: section)
        }
    }
}
