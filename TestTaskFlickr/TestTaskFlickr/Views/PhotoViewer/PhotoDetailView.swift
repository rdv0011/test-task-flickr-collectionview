//
// Copyright © 2020 Dmitry Rybakov. All rights reserved.

import Foundation
import SwiftUI

struct PhotoDetailView: View {
    @Binding var imageTitle: String
    @Binding var image: UIImage

    var body: some View {
        VStack {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
        }
        .navigationTitle(imageTitle)
        .navigationBarTitleDisplayMode(.inline)
    }
}
