//
// Copyright © 2020 Dmitry Rybakov. All rights reserved. 
    

import Foundation

// Represents photo metadata
struct PhotoMetadata: Decodable {
    let imageURL: URL?

    enum CodingKeys: String, CodingKey {
        case imageUrl = "url_m"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        imageURL = URL(string: try container.decode(String.self, forKey: .imageUrl))
    }
}

extension PhotoMetadata: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(imageURL)
    }
}

// Represents a collection of photo metadata
struct PhotoCollectionMetadata: Decodable {
    let photo: [PhotoMetadata]
}

// A root object for a collection of photo metadata
struct PhotoRootObjectMetadata: Decodable {
    let photos: PhotoCollectionMetadata
}
