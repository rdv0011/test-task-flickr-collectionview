//
// Copyright © 2020 Dmitry Rybakov. All rights reserved. 
    

import SwiftUI

struct PhotoView: View {
    @ObservedObject var model: PhotoViewModel

    var body: some View {
        NavigationView {
            VStack {
                NavigationLink(destination: PhotoDetailView(imageTitle: $model.selectedImageTitle,
                                                            image: $model.selectedImage),
                               isActive: $model.showingDetailView) {
                    EmptyView()
                }
                SearchBar(text: $model.searchKeyword)
                PhotoCollectionView(snapshot: $model.snapshot,
                                    selectedPhotoMetadata: $model.selectedPhotoMetadata,
                                    photoProvider: model)
            }
            .navigationTitle("Search photo")
        }
    }
}

struct PhotoView_Previews: PreviewProvider {
    static var previews: some View {
        PhotoView(model: ViewModelFactory(apiKey: "").makePhotoViewModel())
    }
}
