//
// Copyright © 2020 Dmitry Rybakov. All rights reserved. 
    

import SwiftUI

struct PhotoView: View {
    @ObservedObject var model: PhotoViewModel

    var body: some View {
        VStack {
            PhotoCollectionView(snapshot: $model.snapshot,
                                imagePublisher: model.imagePublisher)
        }
    }
}

struct PhotoView_Previews: PreviewProvider {
    static var previews: some View {
        PhotoView(model: ViewModelFactory(apiKey: "").makePhotoViewModel())
    }
}
