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
    private let itemSpacing = CGFloat(8) // 8pt grid
    private let itemsInOneLine = CGFloat(2)

    // Binding to update the UI.
    @Binding var snapshot: NSDiffableDataSourceSnapshot<DataSection, DataObject>

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: UIViewRepresentableContext<PhotoCollectionView>) -> UICollectionView {
        // Create and configure a layout flow
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.sectionInset = .zero
        let width = UIScreen.main.bounds.size.width - itemSpacing * CGFloat(itemsInOneLine - 1)
        flowLayout.itemSize = CGSize(width: floor(width / itemsInOneLine), height: width / itemsInOneLine)
        flowLayout.minimumInteritemSpacing = itemSpacing
        flowLayout.minimumLineSpacing = itemSpacing

        // And create the UICollection View
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)

        // Register a cell
        collectionView.register(PhotoCollectionViewCell.self,
                                forCellWithReuseIdentifier: PhotoCollectionViewCell.reuseIdentifier)

        // Set a datasource
        let dataSource = UICollectionViewDiffableDataSource<DataSection, DataObject>(collectionView: collectionView) { (collectionView, indexPath, photoMetadata) -> UICollectionViewCell? in
            guard let photoCell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCollectionViewCell.reuseIdentifier, for: indexPath) as? PhotoCollectionViewCell else {

                return UICollectionViewCell()
            }
            if let imageURL = photoMetadata.imageURL {
                photoCell.setImageURL(url: imageURL)
            } else {
                print("imageUrl is empty")
            }
            return photoCell
        }
        

        context.coordinator.dataSource = dataSource

        return collectionView
    }


    func updateUIView(_ uiView: UICollectionView, context: UIViewRepresentableContext<PhotoCollectionView>) {
        let dataSource = context.coordinator.dataSource
        //This is where updates happen - when snapshot is changed, this function is called automatically.

        dataSource?.apply(snapshot, animatingDifferences: true, completion: {
            //Any other things you need to do here.
        })

    }

    class Coordinator: NSObject {
        var parent: PhotoCollectionView
        var dataSource: UICollectionViewDiffableDataSource<DataSection, DataObject>?
        var snapshot = NSDiffableDataSourceSnapshot<DataSection, DataObject>()

        init(_ collectionView: PhotoCollectionView) {
            self.parent = collectionView
        }
    }
}
