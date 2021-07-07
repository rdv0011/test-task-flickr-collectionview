//
// Copyright © 2020 Dmitry Rybakov. All rights reserved. 
    

import Foundation

// Represents photo metadata
struct PhotoMetadata: Decodable {
    let url_m: String
}

// Represents a collection of photo metadata
struct PhotoCollectionMetadata: Decodable {
    let photo: [PhotoMetadata]
}

// A root object for a collection of photo metadata
struct PhotoRootObjectMetadata: Decodable {
    let photos: PhotoCollectionMetadata
}
