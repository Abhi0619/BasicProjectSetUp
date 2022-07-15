//
//  ParentVC.swift
//  FitFin
//
//  Created by MAC OS 13 on 08/12/21.
//

import Foundation
import UIKit


class ParentVC: UIViewController {
    
    @IBOutlet var tableview: UITableView!
    @IBOutlet var collectionView: UICollectionView!
    
    var customHud : CustomHud?
    
    lazy var refreshControl: UIRefreshControl = {
        let refresh = UIRefreshControl()
        refresh.tintColor = AppColor.app_dark_green_004718.color()
        refresh.addTarget(self, action: #selector(refreshControlDidChanged(_:)), for: .valueChanged)
        return refresh
    }()
    
    override func viewDidLoad() {
//        NotificationCenter.default.addObserver(self, selector: #selector(updateLanguage), name: NSNotification.Name( UserdefaultKeyList.selectedLanguage.rawValue), object: nil)
        super.viewDidLoad()
    }
    
    deinit {
        _defaultCenter.removeObserver(self)
    }
    
}

//MARK: - Actions
extension ParentVC {
    
    @IBAction func btnBackTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnCloseTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}


// MARK: - Pull To Refresh
extension ParentVC {
    
    func prepareRefreshControlUI(_ tintColor: UIColor = AppColor.app_dark_green_004718.color() , tblView: UITableView? = nil, collView: UICollectionView? = nil){
        refreshControl.tintColor = tintColor
        if let tblView = tblView{
            tblView.refreshControl = refreshControl
        }else{
            tableview?.refreshControl = refreshControl
        }
        
        if let collView = collView{
            collView.refreshControl = refreshControl
        }else{
            collectionView?.refreshControl = refreshControl
        }
    }
    
    @objc func refreshControlDidChanged(_ sender: UIRefreshControl) {
        refreshControl.endRefreshing()
    }
}

//MARK:- Spinner
extension ParentVC {
    
    func showCentralSpinner(_ userEnabled: Bool = false,_ tabBarUserEnabled: Bool = true, name: String = "") {
        if let _ = customHud{
            customHud?.hide()
        }
        self.view.isUserInteractionEnabled = userEnabled
        self.tabBarController?.tabBar.isUserInteractionEnabled = tabBarUserEnabled
        customHud = CustomHud.intance()
        if let customHud = customHud{
            self.view?.addSubview(customHud)
            
            let top = NSLayoutConstraint(item: customHud, attribute: NSLayoutConstraint.Attribute.top, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.view, attribute: NSLayoutConstraint.Attribute.top, multiplier: 1, constant: 0)
            let buttom = NSLayoutConstraint(item: customHud, attribute: NSLayoutConstraint.Attribute.bottom, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.view, attribute: NSLayoutConstraint.Attribute.bottom, multiplier: 1, constant: 0)
            let trail = NSLayoutConstraint(item:customHud, attribute: NSLayoutConstraint.Attribute.trailing, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.view, attribute: NSLayoutConstraint.Attribute.trailing, multiplier: 1, constant: 0)
            let lead = NSLayoutConstraint(item: customHud, attribute: NSLayoutConstraint.Attribute.leading, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.view, attribute: NSLayoutConstraint.Attribute.leading, multiplier: 1, constant: 0)
            
            customHud.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([top,buttom,trail,lead])
        }
        customHud?.show(name)
    }
    
    func hideCentralSpinner() {
        self.view.isUserInteractionEnabled = true
        self.tabBarController?.tabBar.isUserInteractionEnabled = true
        customHud?.hide()
    }
}

//MARK: - Slide Menu
extension ParentVC {
    
    func revealViewController() -> MainTabBarVC? {
        var viewController: UIViewController? = self
        
        if viewController != nil && viewController is MainTabBarVC {
            return viewController! as? MainTabBarVC
        }
        while (!(viewController is MainTabBarVC) && viewController?.parent != nil) {
            viewController = viewController?.parent
        }
        if viewController is MainTabBarVC {
            return viewController as? MainTabBarVC
        }
        return nil
    }
    
}

extension ParentVC {
    @objc func updateLanguage() {
        
    }
}
