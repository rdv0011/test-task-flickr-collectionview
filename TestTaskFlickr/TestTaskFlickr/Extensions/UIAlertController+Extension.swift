//
// Copyright © 2020 Dmitry Rybakov. All rights reserved.

import UIKit

extension UIAlertController {
    class func alert(title:String, msg:String, target: UIViewController? = nil) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default) {
        (result: UIAlertAction) -> Void in
        })
        if let target = target {
            target.present(alert, animated: true, completion: nil)
        } else {
            guard let window = UIApplication.shared.windows.first,
            let rootViewController = window.rootViewController else {
                print("Failed to get root view controller")
                return
            }
            rootViewController.present(alert, animated: true, completion: nil)
        }
    }
}
