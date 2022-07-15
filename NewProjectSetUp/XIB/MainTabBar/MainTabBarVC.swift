//
//  MainTabBarVC.swift
//  MaanMandir
//
//  Created by MAC OS 13 on 08/12/21.
//  Copyright © 2020 Akshay. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

class MainTabBarVC: UITabBarController {
    @IBOutlet var btns: [UIButton]!
    @IBOutlet var imgvTabs: [UIImageView]!
    @IBOutlet var lblName: [UILabel]!
    @IBOutlet var vTabBar: UIView!
    fileprivate lazy var defaultTabBarHeight = { tabBar.frame.size.height }()
    var selectedIdx = 0
//    var objNotification: APPayload?
    
    
    //SlideMenu Variable
   //  var sideMenuViewController: SideMenuVC!
     var sideMenuShadowView: UIView!
     var sideMenuRevealWidth: CGFloat = 320
     let paddingForRotation: CGFloat = 150
     var isExpanded: Bool = false
     var draggingIsEnabled: Bool = false
     var panBaseLocation: CGFloat = 0.0
    
    // Expand/Collapse the side menu by changing trailing's constant
     var sideMenuTrailingConstraint: NSLayoutConstraint!

     var revealSideMenuOnTop: Bool = true
    
    var gestureEnabled: Bool = true
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
     //   self.prepareSideMenu()
       // self.prepareUI()
       
    }

//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//        viewPlaySong.isHidden = playerController.player.currentItem == nil
//        var newTabBarHeight: CGFloat = .zero
//        if playerController.player.currentItem == nil {
//            newTabBarHeight = defaultTabBarHeight
//        }else{
//            newTabBarHeight = defaultTabBarHeight + 40
//        }
//        var newFrame = tabBar.frame
//        newFrame.size.height = newTabBarHeight
//        newFrame.origin.y = view.frame.size.height - newTabBarHeight
//        tabBar.frame = newFrame
//    }
    
    deinit {
        jprint("## Deallocated: \(self.classForCoder)")
        _defaultCenter.removeObserver(self)
    }
}

// MARK: - UI Mthods
extension MainTabBarVC {
    
    func prepareUI() {
    //    addControllers()
        addCustomTabbar()
        self.selectedIndex = selectedIdx
        selectTab(atIndex: selectedIdx)
        
    }
        
//    func addControllers() {
//        let nav1 = UINavigationController()
//        let nav2 = UINavigationController()
//        let nav3 = UINavigationController()
//        let nav4 = UINavigationController()
//        let nav5 = UINavigationController()
//        
//        nav1.navigationBar.isHidden = true
//        nav2.navigationBar.isHidden = true
//        nav3.navigationBar.isHidden = true
//        nav4.navigationBar.isHidden = true
//        nav5.navigationBar.isHidden = true
//        
////        let vc1 = UIStoryboard(name: "Home",bundle: nil).instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
////        let vc2 = UIStoryboard(name: "Receipt",bundle: nil).instantiateViewController(withIdentifier: "ReceiptVC") as! ReceiptVC
////        let vc3 = UIStoryboard(name: "FixedCosts",bundle: nil).instantiateViewController(withIdentifier: "ViewController") as! FixedCostVC
////        let vc4 = UIStoryboard(name: "MyItems",bundle: nil).instantiateViewController(withIdentifier: "MyItemVc") as! MyItemVc
////        let vc5 = UIStoryboard(name: "SearchReceipt",bundle: nil).instantiateViewController(withIdentifier: "SearchReceiptVC") as! SearchReceiptVC
//
//        nav1.viewControllers = [vc1]
//        nav2.viewControllers = [vc2]
//        nav3.viewControllers = [vc3]
//        nav4.viewControllers = [vc4]
//        nav5.viewControllers = [vc5]
////
//        self.viewControllers = [nav1,nav2,nav3,nav4,nav5]
//        tabBar.layoutIfNeeded()
//    }
//    
    func addCustomTabbar() {
        _ = Bundle.main.loadNibNamed("MainTabbarView", owner: self, options: nil)
        vTabBar.frame = CGRect(x: 0, y: 0, width: _screenSize.width, height: 73)
        self.tabBar.addSubview(vTabBar)
        tabBar.layoutIfNeeded()

        self.tabBar.isHidden = false
    }
    
    func selectTab(atIndex index: Int) {
        for (idx,imgv) in imgvTabs.enumerated() {
            if idx == index {
                imgv.tintColor = AppColor.app_white_ffffff.color()
                lblName[idx].textColor = AppColor.app_white_ffffff.color()
            }else{
                imgv.tintColor = AppColor.app_white_ffffff.color(0.5)
                lblName[idx].textColor = AppColor.app_white_ffffff.color(0.5)
            }
        }
        self.selectedIndex = index
    }
    
    
}
// MARK: - Navi Methods
extension MainTabBarVC {
    
    func naviToCreateEventScreen() {

    }
    
    
//    func popToRootViewController(navigations: [UINavigationController]) {
//        for navController in navigations {
//            for controller in navController.viewControllers as Array {
//                if controller.isKind(of: HomeVC.self) {
//                    navController.popToViewController(controller, animated: true)
//                    break
//                }
//                if controller.isKind(of: BrowseVC.self) {
//                    navController.popToViewController(controller, animated: true)
//                    break
//                }
//                if controller.isKind(of: SearchVC.self) {
//                    navController.popToViewController(controller, animated: true)
//                    break
//                }
//                if controller.isKind(of: MyMusicVC.self) {
//                    navController.popToViewController(controller, animated: true)
//                    break
//                }
//                if controller.isKind(of: SettingVC.self) {
//                    navController.popToViewController(controller, animated: true)
//                    break
//                }
//            }
//        }
//    }
}

// MARK: - Actions
extension MainTabBarVC {
    
    @IBAction func btnTapAction(_ sender: UIButton) {
        if sender.tag == 101 { // Camera Button
            
        }else{
            
            if sender.tag != self.selectedIndex {
                selectTab(atIndex: sender.tag)
            }
//            if let tabNav = self.navigationController {
//                for vc in tabNav.viewControllers {
//                    if let myVC = vc as? MainTabBarVC {
//                        if let firstVc = (myVC.navigationController?.viewControllers[1]) as? UITabBarController, let navigations = firstVc.viewControllers as? [UINavigationController] {
////                            self.popToRootViewController(navigations: navigations)
//                        }
//                    }
//                }
//            }
        }
    }
}
