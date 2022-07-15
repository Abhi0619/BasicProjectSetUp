//
//  APSearchBar.swift
//  MaanMandir
//
//  Created by MAC OS 13 on 08/12/21.
//  Copyright © 2020 Akshay. All rights reserved.
//

import Foundation
import UIKit
import IQKeyboardManagerSwift

let searchAnimationTime: Double = 0.25

protocol APSearchDelegate: NSObjectProtocol {
    func searchTextChange(text: String)
    func searchCancel()
}

class APSearchBar: ConstrainedView {
    
    /// IBOutlets
    @IBOutlet weak var tfSearch: UITextField!
    
    /// Variables
    var leadConstraint: NSLayoutConstraint!
    var trailConstraint: NSLayoutConstraint!
    var fadeAnimateView: UIView!
    var isAnimated: Bool!
    weak var delegate: APSearchDelegate?
    
    class func initSearchView(view: UIView, isAnimated: Bool = true) -> APSearchBar {
        let obj = Bundle.main.loadNibNamed("APSearchBar", owner: nil, options: nil)?[1] as! APSearchBar
        obj.tfSearch.placeholder = "Search here...."
        obj.isAnimated = isAnimated
        obj.fadeAnimateView = view
        view.superview!.addSubview(obj)
        obj.addConstraint()
        return obj
    }
}

// MARK: - UI & Utility methods
extension APSearchBar {
    
    func addConstraint() {
        leadConstraint = NSLayoutConstraint.init(item: self, attribute: NSLayoutConstraint.Attribute.leading, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.superview, attribute: NSLayoutConstraint.Attribute.leading, multiplier: 1.0, constant: _screenSize.width)
        trailConstraint = NSLayoutConstraint.init(item: self, attribute: NSLayoutConstraint.Attribute.trailing, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.superview, attribute: NSLayoutConstraint.Attribute.trailing, multiplier: 1.0, constant: _screenSize.width)
        let top = NSLayoutConstraint.init(item: self, attribute: NSLayoutConstraint.Attribute.top, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.superview, attribute: NSLayoutConstraint.Attribute.top, multiplier: 1.0, constant: _statusBarHeight)
        let height = NSLayoutConstraint.init(item: self, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.height, multiplier: 1.0, constant: 44)
        self.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([leadConstraint, trailConstraint, top, height])
        fadeAnimateView.superview!.layoutIfNeeded()
        animateIn()
    }
    
    func animateIn()  {
        leadConstraint.constant = 0
        trailConstraint.constant = 0
        tfSearch.becomeFirstResponder()
        if isAnimated {
            UIView.animate(withDuration: searchAnimationTime) {
                self.superview!.layoutIfNeeded()
                self.fadeAnimateView.alpha = 0
            }
        } else {
            self.superview!.layoutIfNeeded()
            self.fadeAnimateView.alpha = 0
        }
    }
    
    func animateOut()  {
        leadConstraint.constant = _screenSize.width
        trailConstraint.constant = _screenSize.width
        tfSearch.resignFirstResponder()
        if isAnimated {
            UIView.animate(withDuration: searchAnimationTime, animations: {
                self.superview!.layoutIfNeeded()
                self.fadeAnimateView.alpha = 1
            }) { (comp) in
                self.delegate?.searchCancel()
                self.removeFromSuperview()
            }
        } else {
            self.superview!.layoutIfNeeded()
            self.fadeAnimateView.alpha = 1
            self.delegate?.searchCancel()
            self.removeFromSuperview()
        }
    }
}

// MARK: - Button actions
extension APSearchBar {
    
    @IBAction func btnCancelTap(_ sender: UIButton) {
        animateOut()
    }
    
    @IBAction func textChange(_ sender: UITextField) {
        delegate?.searchTextChange(text: sender.text!)
    }
    
}

//MARK: - Text Field delegate Method
extension APSearchBar: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == tfSearch{
            animateOut()
        }
     }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.returnKeyType == .next {
            if IQKeyboardManager.shared.canGoNext && IQKeyboardManager.shared.goNext() {
                return true
            }
        }else if textField.returnKeyType == .done {
            animateOut()
            textField.resignFirstResponder()
        }
        return true
    }
    
}
