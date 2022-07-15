//
//  CustomHud.swift
//  MaanMandir
//
//  Created by MAC OS 13 on 08/12/21.
//  Copyright © 2020 Akshay. All rights reserved.
//

import Foundation
import UIKit

class CustomHud: UIView {
    
    // MARK: Outlets
    @IBOutlet var lblMessage: UILabel!
    @IBOutlet var actv: UIActivityIndicatorView!
    @IBOutlet var containerView: UIView!
    @IBOutlet var progressV: UIProgressView!

    var percent: Float {
        get{
            return progressV.progress
        }set(new){
            progressV.progress = new
            self.updateProgress()
        }
    }
    
    // MARK: Init
    class func intance(_ name: String = "") -> CustomHud {
        let view = Bundle.main.loadNibNamed("CustomHud", owner: nil, options: nil)![0] as! CustomHud
        view.frame = CGRect(x: 0, y: 0, width: _screenSize.width, height: _screenSize.height)
        view.lblMessage.text = name
        view.layoutIfNeeded()
        return view
    }
    
    // MARK: Init
    class func intanceProgress(_ percent: Float = 0.0) -> CustomHud {
        let view = Bundle.main.loadNibNamed("CustomHud", owner: nil, options: nil)![1] as! CustomHud
        view.frame = CGRect(x: 0, y: 0, width: _screenSize.width, height: _screenSize.height)
        view.layoutIfNeeded()
        view.percent = percent
        return view
    }
    
    private func updateProgress() {
        let intProgress = Int(progressV.progress * 100)
        if intProgress <= 100 {
            self.lblMessage.text = "\(intProgress)%"
        }
    }
    
    func show(_ name: String = "") {
//        UIApplication.shared.isNetworkActivityIndicatorVisible = true
         self.lblMessage.text = name
        self.layoutIfNeeded()
        self.actv.startAnimating()
    }
    
    func hide() {
//        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        self.actv?.stopAnimating()
        UIView.animate(withDuration: 0.2, animations: {
            self.containerView.alpha = 0
        }) { (completed) in
            self.removeFromSuperview()
        }
    }
    
}
