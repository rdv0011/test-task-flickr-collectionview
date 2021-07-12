//
// Copyright © 2020 Dmitry Rybakov. All rights reserved.

import UIKit

class ImageSaver: NSObject {
    private let onSave: ((Error?) -> ())

    init(onSave: @escaping ((Error?) -> ())) {
        self.onSave = onSave
    }

    func writeToPhotoAlbum(image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveError), nil)
    }

    @objc func saveError(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        onSave(error)
    }
}
