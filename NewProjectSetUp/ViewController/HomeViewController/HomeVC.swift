//
//  HomeVC.swift
//  NewProjectSetUp
//
//  Created by IPS-153 on 15/07/22.
//

import UIKit

class HomeVC: ParentVC {
    
    @IBOutlet weak var lblUserName: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        lblUserName.text = _loggedUser.email
    }
}

//MARK: - Action Method
extension HomeVC {
    @IBAction func btnLogoutTapped(_ sender: UIButton) {
        _appDelegator.prepareToLogout()
    }
}
