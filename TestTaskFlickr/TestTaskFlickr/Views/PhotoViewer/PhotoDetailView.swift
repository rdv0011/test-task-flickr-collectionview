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
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") {
                    let imageSaver = ImageSaver() { error in
                        if let error = error {
                            print("Filed to save photo:\(String(describing: error))")
                            UIAlertController.alert(title: "Error",
                                                    msg: "Failed to save photo")
                        } else {
                            UIAlertController.alert(title: "Success",
                                                    msg: "Photo was successfully saved")
                        }
                    }
                    imageSaver.writeToPhotoAlbum(image: image)
                }
            }
        }
    }
}
