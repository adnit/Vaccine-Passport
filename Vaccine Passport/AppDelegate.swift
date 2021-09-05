//
//  AppDelegate.swift
//  Vaccine Passport
//
//  Created by Adnit Kamberi on 8/27/21.
//

import UIKit


@main
class AppDelegate: UIResponder, UIApplicationDelegate {



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
    
//    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool)-> Void) {
//        let handledShortcutItem = handledShortcut(shortcutItem: shortcutItem)
//        completionHandler(handledShortcutItem)
//    }
//
//    func handledShortcut(shortcutItem: UIApplicationShortcutItem) -> Bool {
//        var handle = false
//        guard let shortCutType = shortcutItem.type as String? else {
//            return false
//        }
//        switch shortCutType {
//        case "SearchAction":
//            showView(screen: "scanView")
//            handle = true
//            break
//        case "AddAction":
//            let viewController = PassportViewController()
//            self.window?.rootViewController?.present(viewController, animated: true, completion: nil)
//            handle = true
//            break
//        default:
//            break
//        }
//        return handle
//    }
//
//    func showView(screen: String) {
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let navigationController = storyboard.instantiateInitialViewController() as! UINavigationController
//        let rootViewController = storyboard.instantiateViewController(withIdentifier: screen) as UIViewController
//            navigationController.viewControllers = [rootViewController]
//            self.window?.rootViewController = navigationController
//
//    }
}

