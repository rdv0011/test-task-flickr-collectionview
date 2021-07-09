//
// Copyright © 2020 Dmitry Rybakov. All rights reserved. 
    

import SwiftUI

struct PhotoView: View {
    @ObservedObject var model: PhotoViewModel
    @State private var isEditing = false

    var body: some View {
        VStack {
            SearchBar(text: $model.searchKeyword)
            PhotoCollectionView(snapshot: $model.snapshot,
                                photoPublisher: model.photoPublisher)
        }
    }
}

struct PhotoView_Previews: PreviewProvider {
    static var previews: some View {
        PhotoView(model: ViewModelFactory(apiKey: "").makePhotoViewModel())
    }
}
