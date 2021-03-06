//
// Copyright © 2020 Dmitry Rybakov. All rights reserved. 
    

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    // TODO: Get it from a the cloud securely and store it locally to the secure store
    let flickrAPIKey = "9f878432bcb8c064dde833f03d07a33e" // Set Flickr API key here

    static var shared: AppDelegate {
        guard let appDelegate = (UIApplication.shared.delegate as? AppDelegate) else {
            fatalError("Failed to cast app delegate")
        }

        return appDelegate
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}
