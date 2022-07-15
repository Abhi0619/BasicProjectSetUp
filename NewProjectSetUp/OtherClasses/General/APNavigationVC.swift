//
//  APNavigationVC.swift
//  FitFin
//
//  Created by MAC OS 13 on 07/12/21.
//

import Foundation
import UIKit

/// AKNavigationVC
class YFNavigationVC: UINavigationController, UIGestureRecognizerDelegate, UINavigationControllerDelegate {
    
    // MARK: - View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        weak var weakSelf: YFNavigationVC? = self
        interactivePopGestureRecognizer?.delegate = weakSelf!
        delegate = weakSelf!
        isNavigationBarHidden = true
    }
 
    // MARK: - UIGestureRecognizerDelegate
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if viewControllers.count > 1 {
            return true
        } else {
            return false
        }
    }
    
    // MARK: - UINavigationControllerDelegate
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
//        if viewController is HomeVC {
//            interactivePopGestureRecognizer!.isEnabled = false
//        }else if viewController is BrowseVC {
//            interactivePopGestureRecognizer!.isEnabled = false
//        }else if viewController is SearchVC {
//            interactivePopGestureRecognizer!.isEnabled = false
//        }else if viewController is MyMusicVC {
//            interactivePopGestureRecognizer!.isEnabled = false
//        }else if viewController is SettingVC {
//            interactivePopGestureRecognizer!.isEnabled = false
//        }
    }
}
