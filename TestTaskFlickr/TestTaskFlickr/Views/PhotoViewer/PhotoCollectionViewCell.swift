//
// Copyright © 2020 Dmitry Rybakov. All rights reserved.

import Foundation
import UIKit
import Combine

protocol ReuseIdentifiable {
    static var reuseIdentifier: String { get }
}

/// Represents a collection view cell
/// Contains one image view
/// Asynchronously downloads image by a provided url
final class PhotoCollectionViewCell: UICollectionViewCell {
    let imageView: UIImageView
    let activityIndicator: UIActivityIndicatorView
    var imageDownloadingSubscription: AnyCancellable?

    override init(frame: CGRect) {
        // Create subviews
        imageView = UIImageView()
        activityIndicator = UIActivityIndicatorView()
        super.init(frame: frame)
        // Setup subviews
        setupSubviews()
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupSubviews() {
        // Image view
        // Kepp aspect ratio
        imageView.contentMode = .scaleAspectFill
        // This may speed up rendering
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(imageView)
        // Activity view
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = .medium
        activityIndicator.color = .systemGray
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.startAnimating()
        addSubview(activityIndicator)
    }

    private func setupLayout() {
        NSLayoutConstraint.activate([
            // Image view
            imageView.topAnchor.constraint(equalTo: self.topAnchor),
            imageView.leftAnchor.constraint(equalTo: self.leftAnchor),
            imageView.rightAnchor.constraint(equalTo: self.rightAnchor),
            imageView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            // Activity indicator
            activityIndicator.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
    }
}

extension PhotoCollectionViewCell: ReuseIdentifiable {
    static let reuseIdentifier = String(describing: self)
}
