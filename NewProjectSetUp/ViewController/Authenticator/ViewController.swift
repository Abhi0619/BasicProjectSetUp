//
//  ViewController.swift
//  NewProjectSetUp
//
//  Created by MAC OS 16 on 31/01/22.
//

import UIKit
import Alamofire

class ViewController: ParentVC {
    //Outlets
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }


}

//MARK: - Navigation Method
extension ViewController {
    func naviToHomeViewController() {
        let vc = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
        navigationController?.pushViewController(vc, animated: true)
    }
}

//MARK: - Action Method
extension ViewController {
    @IBAction func btnLoginTapped(_ sender : UIButton) {
        let Validation = isValid()
        if Validation.valid {
            loginWSCall()
        }else {
            ValidationToast.show(message: Validation.error, viewController: self, type: .error, presentType: .top, animationStlye: .slide, completion: nil)
        }
    }
}

//MARK: - API Calling
extension ViewController {
    func loginWSCall() {
        var param: [String:Any] = [:]
        param["UserName"] = txtEmail.text
        param["Password"] = txtPassword.text
        showCentralSpinner()
        WebService.shared.loginWScall(param: param) { json, statusCode in
            self.hideCentralSpinner()
            if statusCode == 200, let jsonData = RawdataConverter.dictionary(json) {
                if let distData = RawdataConverter.dictionary(jsonData["data"]) {
                    _loggedUser = LoggedUser.createNewEntity(key: "userId", value: RawdataConverter.string(distData["UserId"]))
                    _loggedUser.initWith(distData)
                    _appDelegator.saveContext()
                    self.naviToHomeViewController()
                }
            }
        }
    }
}

//MARK: - For Validation
extension ViewController {
    func isValid() -> (valid: Bool, error : String) {
        var result = (valid: true, error: "")
        if String.validate(value: txtEmail.text) {
            result.valid = false
            result.error = "Please Enter Email"
            return result
        }else if !txtEmail.text!.isEmailAddressValid {
            result.valid = false
            result.error = "Please Enter valid EmailAddress"
            return result
        }else if String.validate(value: txtPassword.text) {
            result.valid = false
            result.error = "Please Enter Password"
            return result
        }
        return result
    }
}
