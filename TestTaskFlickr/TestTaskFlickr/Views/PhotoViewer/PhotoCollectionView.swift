//
// Copyright © 2020 Dmitry Rybakov. All rights reserved.

import Foundation
import SwiftUI
import UIKit
import Combine

/// A wrapper around UICollectionView
struct PhotoCollectionView: UIViewRepresentable {
    typealias UIViewType = UICollectionView

    typealias DataSection = Int
    typealias DataObject = PhotoMetadata
    // MARK: - Layout constants
    private let itemSpacing = CGFloat(8) // 8pt grid
    private let itemsInOneLine = CGFloat(2)

    // Binding to update the UI.
    @Binding var snapshot: NSDiffableDataSourceSnapshot<DataSection, DataObject>
    @Binding var selectedPhotoMetadata: PhotoMetadata?
    weak var photoProvider: PhotoPublisherProviding?

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: UIViewRepresentableContext<PhotoCollectionView>) -> UICollectionView {
        // Create and configure a layout flow
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.sectionInset = UIEdgeInsets(top: itemSpacing,
                                               left: itemSpacing,
                                               bottom: itemSpacing,
                                               right: itemSpacing)
        let width = UIScreen.main.bounds.size.width - itemSpacing * CGFloat(itemsInOneLine - 1) - 2 * itemSpacing
        flowLayout.itemSize = CGSize(width: floor(width / itemsInOneLine),
                                     height: width / itemsInOneLine)
        flowLayout.minimumInteritemSpacing = itemSpacing
        flowLayout.minimumLineSpacing = itemSpacing

        // And create the UICollection View
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)

        // Register a cell
        collectionView.register(PhotoCollectionViewCell.self,
                                forCellWithReuseIdentifier: PhotoCollectionViewCell.reuseIdentifier)

        // Set a datasource
        context.coordinator.dataSource = collectionViewDataSource(for: collectionView)
        collectionView.delegate = context.coordinator

        return collectionView
    }

    private func collectionViewDataSource(for collectionView: UICollectionView) -> UICollectionViewDiffableDataSource<DataSection, DataObject> {
        UICollectionViewDiffableDataSource<DataSection, DataObject>(collectionView: collectionView) { (collectionView, indexPath, photoMetadata) -> UICollectionViewCell? in
            guard let photoCell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCollectionViewCell.reuseIdentifier, for: indexPath) as? PhotoCollectionViewCell else {

                return UICollectionViewCell()
            }
            if let photoUrl = photoMetadata.photoUrl {
                // Download an image asynchronously using an url from photo metadata
                photoCell.activityIndicator.startAnimating()
                photoCell.imageDownloadingSubscription = photoProvider?.publisher(for: photoUrl)
                    .prepend(nil)
                    // Remove previously set image
                    .handleEvents(receiveOutput: { _ in
                        photoCell.activityIndicator.stopAnimating()
                    })
                    .weakAssign(to: \.image, on: photoCell.imageView)
            } else {
                // Metadata with empty urls are filtered out in the view model
                // This branch must not be executed
                fatalError("imageUrl is empty")
            }
            return photoCell
        }
    }


    // This function is called automatically when the update is needed
    func updateUIView(_ uiView: UICollectionView, context: UIViewRepresentableContext<PhotoCollectionView>) {
        let dataSource = context.coordinator.dataSource
        dataSource?.apply(snapshot, animatingDifferences: true)
    }

    class Coordinator: NSObject, UICollectionViewDelegate {
        var parent: PhotoCollectionView
        var dataSource: UICollectionViewDiffableDataSource<DataSection, DataObject>?

        init(_ collectionView: PhotoCollectionView) {
            self.parent = collectionView
        }

        func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            parent.selectedPhotoMetadata = dataSource?.itemIdentifier(for: indexPath)
        }
    }
}
