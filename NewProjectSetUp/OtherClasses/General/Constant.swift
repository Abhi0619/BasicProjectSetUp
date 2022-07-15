//
//  Constant.swift
//  FitFin
//
//  Created by MAC OS 13 on 07/12/21.
//

import Foundation
import UIKit

let app_store_ID: String = { "" }()
let app_iTunes_URL: String  = { "https://itunes.apple.com/us/app/id\(app_store_ID)" }()
let backgroundIdentifier: String = { "\(_bundleIdentifier).uploadbackground" }()
let downloadManager = APDownloadManager.shared

let directoryName: String = "MaanMandirAudio"

let _appName: String = {
    let displayname = RawdataConverter.string(Bundle.main.object(forInfoDictionaryKey: RawdataConverter.string(kCFBundleNameKey)))
    return displayname
}()

let _bundleIdentifier: String = {
    let displayname = RawdataConverter.string(Bundle.main.bundleIdentifier)
    return displayname
}()

let _screenSize = { return UIScreen.main.bounds.size }()
let _screenFrame = { return UIScreen.main.bounds }()

let _defaultCenter = { return NotificationCenter.default }()
let _userDefault = { return UserDefaults.standard }()
let _appDelegator = { return UIApplication.shared.delegate! as! AppDelegate }()
let _application = { return UIApplication.shared }()
let _statusBarHeight: CGFloat = UIApplication.shared.statusBarFrame.height

//var _loggedUser: LoggedUser!

var _safeAreaInsets: UIEdgeInsets {
    get {
        if let window = _appDelegator.window{
            return window.safeAreaInsets
        }else if let vc = _appDelegator.window?.rootViewController{
            return vc.view.safeAreaInsets
        }
        return UIEdgeInsets.zero
    }
}

//var _statusBarOrientation: UIInterfaceOrientation {
//    get {
//        if #available(iOS 13.0, *) {
//            guard let orientation = UIApplication.shared.windows.first?.windowScene?.interfaceOrientation else {
//                return UIInterfaceOrientation.portrait
//            }
//            return orientation
//        }else {
//            // Fallback on earlier versions
//            return UIApplication.shared.statusBarOrientation
//        }
//    }
//}

var _statusBarOrientation: UIInterfaceOrientation {
    get {
        if #available(iOS 13.0, *) {
            guard let orientation = UIApplication.shared.windows.first?.windowScene?.interfaceOrientation else {
                return UIInterfaceOrientation.portrait
            }
            return orientation
        }else {
            // Fallback on earlier versions
            return UIApplication.shared.statusBarOrientation
        }
    }
}

var _statusBarFrame: CGRect {
    get {
        if #available(iOS 13.0, *) {
            guard let statusBarFrame = UIApplication.shared.windows.first?.windowScene?.statusBarManager?.statusBarFrame else {
                return CGRect.zero
             }
            return statusBarFrame
        }else{
            // Fallback on earlier versions
            return UIApplication.shared.statusBarFrame
        }
    }
}

var _widthRatio: CGFloat {
    let ratio = _screenSize.width/375
    return ratio
}

var _heightRatio: CGFloat {
    let ratio = _screenSize.height/812
    return ratio
}


// MARK: Media Placehodler
let profile_placeHolder: UIImage = {
    return UIImage(named: "img_placeholder_logo")!
}()

// MARK: Global Functions
func jprint(_ items: Any...) {
    // debug only code
    #if DEBUG
    for item in items {
        print(item)
    }
    #endif
}

// MARK: - Settings Version Maintenance
func setAppSettingsBundleInformation(){
    let standardUserDefaults = UserDefaults.standard
    standardUserDefaults.set(appVersion, forKey: "version_number")
    standardUserDefaults.set(buildNumber, forKey: "build_number")
}

let appVersion : String = {
    return RawdataConverter.string(Bundle.main.infoDictionary?["CFBundleShortVersionString"])
}()

let buildNumber : String = {
    return RawdataConverter.string(Bundle.main.object(forInfoDictionaryKey: RawdataConverter.string(kCFBundleVersionKey)))
}()

//let display_app_version : String = {
//    if WSAPIEnvironment.currentType == .production {
//        return "v\(appVersion)"
//    } else {
//        return "v\(appVersion) (\(buildNumber))"
//    }
//}()


extension UIViewController {
    var isDarkModeEnabled : Bool {
        get {
            if #available(iOS 12.0, *) {
                return traitCollection.userInterfaceStyle == .dark
            } else {
                return false
            }
        }
    }
    
    func addAnimationOnViewController(_ duration: Double, type: CATransitionType) {
        let transition: CATransition = CATransition()
        transition.duration = duration
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        transition.type = type
        view.window!.layer.add(transition, forKey: nil)
    }
}
