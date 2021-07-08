//
// Copyright © 2020 Dmitry Rybakov. All rights reserved.

import Foundation
import UIKit
import Combine

protocol ReuseIdentifiable {
    static var reuseIdentifier: String { get }
}

class PhotoCollectionViewCell: UICollectionViewCell {
    let imageView: UIImageView
    private var subscriptions = Set<AnyCancellable>()

    override init(frame: CGRect) {
        // Create subviews
        imageView = UIImageView()
        super.init(frame: frame)
        // Setup subviews
        setupSubviews()
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setImageURL(url: URL) {
        UIImage.imagePublisher(from: url)
            .weakAssign(to: \.image, on: imageView)
            .store(in: &subscriptions)
    }

    private func setupSubviews() {
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(imageView)
    }

    private func setupLayout() {
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: self.topAnchor),
            imageView.leftAnchor.constraint(equalTo: self.leftAnchor),
            imageView.rightAnchor.constraint(equalTo: self.rightAnchor),
            imageView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }
}

extension PhotoCollectionViewCell: ReuseIdentifiable {
    static let reuseIdentifier = String(describing: self)
}
