//
// Copyright © 2020 Dmitry Rybakov. All rights reserved. 
    

import Foundation

/// Represents photo metadata
struct PhotoMetadata: Decodable {
    let photoUrl: URL?
    let title: String

    enum CodingKeys: String, CodingKey {
        case photoUrl = "url_m"
        case title
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        photoUrl = URL(string: try container.decode(String.self, forKey: .photoUrl))
        title = try container.decode(String.self, forKey: .title)
    }
}

extension PhotoMetadata: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(photoUrl)
    }
}

/// Represents a collection of photo metadata
struct PhotoCollectionMetadata: Decodable {
    let photo: [PhotoMetadata]
}

/// A root object for a collection of photo metadata
struct PhotoRootObjectMetadata: Decodable {
    let photos: PhotoCollectionMetadata
}
