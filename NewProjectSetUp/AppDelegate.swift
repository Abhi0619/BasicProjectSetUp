//
//  AppDelegate.swift
//  NewProjectSetUp
//
//  Created by MAC OS 16 on 31/01/22.
//

import UIKit
import CoreData
import IQKeyboardManagerSwift
@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
        if #available(iOS 13, *) {
        }else{
            prepareForDirectLogin()
        }
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

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "NewProjectSetUp")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}

// MARK: - User Methods
extension AppDelegate {
    
    func prepareForDirectLogin() {
        
//        WebService.shared.isInternetAvailable()
        
        if isUserLoggedIn() {
            // Set Access token in Http header
            jprint("Auth_token: \(_loggedUser.accessToken)")
            WebService.shared.storeAuthorizationToken(_loggedUser.accessToken)
//            UNUserNotificationCenter.current().delegate = self
            // Directly Login
            directLoginToHome()
         }
    }
    
    func isUserLoggedIn() -> Bool {
        let users = LoggedUser.fetch(predicate: nil, sortDescs: nil)
        if let user = users.first {
            _loggedUser = user
            return true
        }else{
            return false
        }
    }
    
    func directLoginToHome() {
        let vc1 = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ViewController")
        let vc2 = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "HomeVC")
        let nav = _appDelegator.window?.rootViewController as! YFNavigationVC
        nav.viewControllers = [vc1, vc2]
        _appDelegator.window?.rootViewController = nav
    }
        
    func prepareToLogout(sessionExpired expired: Bool = false) {
        self.window?.rootViewController?.dismiss(animated: false, completion: nil)
        if let navigationvc = _appDelegator.window?.rootViewController as? UINavigationController {
            navigationvc.presentingViewController?.dismiss(animated: false, completion: nil)
            navigationvc.presentingViewController?.presentingViewController?.dismiss(animated: false, completion: nil)
            navigationvc.popToRootViewController(animated: false)
        }
        self.removeAllRecordFromDBAndCache()
        
        // Clear all notifications
        UIApplication.shared.applicationIconBadgeNumber = 0 // For Clear Badge Counts
        let center = UNUserNotificationCenter.current()
        center.removeAllDeliveredNotifications() // To remove all delivered notifications
        center.removeAllPendingNotificationRequests() // To remove all pending notifications which are not delivered yet but scheduled.
 
        if expired {
            // if any required for expried action
        }
    }
    
    // Remove all record from DB and cCache
    func removeAllRecordFromDBAndCache(_ removeAccessToken: Bool = true) {
        let loggedUser = LoggedUser.fetch(predicate: nil, sortDescs: nil)
        LoggedUser.delete(removeObjects: loggedUser)
        _loggedUser = nil

        var deviceToken: String = ""
        if let token = APKeychainWrapper.shared.string(forKey: "deviceToken") {
            deviceToken = token
        }
        
//        _defaultCenter.setValue(deviceToken.hexString(), forKey: "deviceToken")
//            defDeviceToken = _userDefault.string(forKey: "deviceToken") ?? ""
        
//        if removeAccessToken {
            // Remove Access token form Header
            WebService.shared.removedAuthoriaztionToken()
//        }
        
        
        APKeychainWrapper.shared.set(deviceToken, forKey: "deviceToken")
//        _userDefault.setValue(defDeviceToken, forKey: "deviceToken")
//        unRegisterNotification()
    }
}
