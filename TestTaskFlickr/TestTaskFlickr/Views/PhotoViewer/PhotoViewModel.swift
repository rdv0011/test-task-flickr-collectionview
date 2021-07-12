//
// Copyright © 2020 Dmitry Rybakov. All rights reserved. 
    

import Foundation
import Combine
import UIKit

/// Represents a publisher for photos
protocol PhotoPublisherProviding: AnyObject {
    func publisher(for url: URL) -> AnyPublisher<UIImage?, Never>
}

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
    @Published var selectedPhotoMetadata: PhotoMetadata? = nil
    @Published var showingDetailView = false
    @Published var selectedImageTitle = ""
    @Published var selectedImage = UIImage()

    @Published var snapshot : NSDiffableDataSourceSnapshot<DataSection, DataObject> = {
        var snapshot = NSDiffableDataSourceSnapshot<DataSection, DataObject>()
        // Setup one section only
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

    /// Sends a request to the photo service based on the search text which comes from the search bar
    private func searchResultsPublisher() -> AnyPublisher<[PhotoMetadata], Error> {
        $searchKeyword
            .debounce(for: 0.3, scheduler: DispatchQueue.main)
            .removeDuplicates()
            .flatMap { [photoService, pageNumber, perPage] keyword in
                photoService.searchPhotos(by: keyword, page: pageNumber, perPage: perPage)
                // Filter out metadata with empty urls
                .filter { photoMetadata in photoMetadata.photoUrl != nil }
                // Wait for all photo metadata to set it at one step to avoid too frequent UI updates
                .collect()
                .catch { error -> AnyPublisher<[PhotoMetadata], Error> in
                    print("Failed to search: \(error)")
                    return Empty<[PhotoMetadata], Error>().eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }

    private func subscribe() {
        // Search result handling
        searchResultsPublisher()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                print("Search subscription finished: \(completion)")
            }, receiveValue: { photoMetadata in
                self.replaceItems(items: photoMetadata, to: Self.sectionIndex)
            })
            .store(in: &subscriptions)
        // Photo detail view triggering
        $selectedPhotoMetadata
            // Ignore nil metadata
            .compactMap { $0 }
            .flatMap { [unowned self] photoMetadata -> AnyPublisher<(PhotoMetadata, UIImage), Never> in
                guard let photoUrl = photoMetadata.photoUrl else {
                    // Since nil urls are filtered out earlier it should not happen
                    fatalError("Nothing no show in a detail view because url is empty")
                }

                // Try to get image by url
                // Since it was previously downloaded it should be in memory already
                return self.publisher(for: photoUrl)
                    // Ignore nil images
                    .compactMap { $0}
                    // Combine metadata and an image together
                    .map { image in
                        (photoMetadata, image)
                    }
                    .eraseToAnyPublisher()
            }
            .handleEvents(receiveOutput: { [unowned self] (photoMetadata, image) in
                // Set a title and an image to use it in a detail view
                self.selectedImageTitle = photoMetadata.title
                self.selectedImage = image
            })
            .map { _ in true }
            // Trigger a detail view
            .weakAssign(to: \.showingDetailView, on: self)
            .store(in: &subscriptions)
    }

    // Helper function to replace items
    private func replaceItems(items: [DataObject], to section: DataSection) {
        let identifiers = snapshot.itemIdentifiers
        // Remove items from previous search result
        if identifiers.count > 0 {
            snapshot.deleteItems(identifiers)
        }
        // Add items from the latest search result
        if snapshot.sectionIdentifiers.contains(section) {
            snapshot.appendItems(items, toSection: section)
        } else {
            snapshot.appendSections([section])
            snapshot.appendItems(items, toSection: section)
        }
    }
}

extension PhotoViewModel: PhotoPublisherProviding {
    func publisher(for photoUrl: URL) -> AnyPublisher<UIImage?, Never> {
        photoService.photo(from: photoUrl)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
