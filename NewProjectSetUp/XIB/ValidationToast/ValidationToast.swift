//
//  ValidationToast.swift
//  MaanMandir
//
//  Created by MAC OS 13 on 08/12/21.
//  Copyright © 2020 Akshay. All rights reserved.
//

import Foundation
import UIKit

// Toast Present stlye enum
enum ToastPosition : Int{
    case top = 0
    case center = 1
    case bottom = 2
    case belowNav = 3
    
    static var navHeight: CGFloat = 44
}
// Toast behaviour type enum
enum ToastType : Int{
    case normal
    case success
    case warning
    case error
    
    var gradient_colors: [UIColor] {
        switch self {
        case .error:
            return [AppColor.app_light_orange_F8BC69.color(), AppColor.app_dark_orange_EC9428.color()]
        case .success:
            return [AppColor.app_light_green_006622.color(), AppColor.app_dark_green_004718.color()]
        case .warning:
            return [AppColor.app_light_orange_F8BC69.color(), AppColor.app_dark_orange_EC9428.color()]
        default:
            return [AppColor.app_light_green_006622.color(), AppColor.app_dark_green_004718.color()]
        }
    }
}


// Toast View
class ValidationToast: UIView {
    
    // MARK: - Outlets
    @IBOutlet weak var lblMessage: UILabel!
    @IBOutlet weak var viewMessage: GradientView!
    
    var presentType: ToastPosition = .top
    var animationStlye: AnimationStlye = .fade
    var message: String = ""
    
 
    fileprivate var window_Appdelegate: UIWindow {
        let appDelegator   =   UIApplication.shared.delegate!
        return appDelegator.window!!
    }
    
    
    //  Toast animation stlye enum
    enum AnimationStlye: Int{
        case fade
        case slide
    }
    
    // MARK: - Initialisers
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layoutIfNeeded()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.deviceOrientationDidChange(_:)), name: UIDevice.orientationDidChangeNotification, object: nil )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    class func show(message msg: String, viewController: UIViewController? = nil, type: ToastType = ToastType.error, presentType: ToastPosition = .top, animationStlye: AnimationStlye = .slide, completion: (()->())? = nil) {
        if msg.isEmpty{
            completion?()
            return
        }
        let toast = Bundle.main.loadNibNamed("ValidationToast", owner: nil, options: nil)![0] as! ValidationToast
        toast.animationStlye = animationStlye
        toast.presentType = presentType
        toast.message = msg
        toast.lblMessage.text = msg
        toast.lblMessage.textColor = .white
        toast.clipsToBounds = true
         // Gradient colors
        let colors = type.gradient_colors
        toast.viewMessage.backgroundColor = UIColor.clear
        toast.viewMessage.firstColor = colors[0]
        toast.viewMessage.secondColor = colors[1]
        toast.viewMessage.start_Point = CGPoint(x: 0, y: 0)
        toast.viewMessage.end_Point = CGPoint(x: 1, y: 1)

        toast.viewMessage.alpha = toast.animationStlye  == .fade ? 0.0 : 1.0
        
        if let vc = viewController{
            vc.view.addSubview(toast)
            toast.prepareToAddConstraint(vc)
            toast.layoutIfNeeded()
            
            toast.animateIn(duration: 0.2, delay: 0.1) { (completed) in
                toast.animateOut(duration: 0.2, delay: 3.5, completion: { (completed) in
                    toast.removeFromSuperview()
                    completion?()
                })
            }
        }else if let vc = UIApplication.shared.delegate?.window??.rootViewController{
            vc.view.addSubview(toast)
            toast.prepareToAddConstraint(vc)
            toast.layoutIfNeeded()
            
            toast.animateIn(duration: 0.2, delay: 0.1) { (completed) in
                toast.animateOut(duration: 0.2, delay: 3.5, completion: { (completed) in
                    toast.removeFromSuperview()
                    completion?()
                })
            }
        }
        
    }

    
    // Update toast frame base on toast style
    fileprivate func prepareToAddConstraint(_ vc: UIViewController){
        
        let trail = NSLayoutConstraint(item: self, attribute: NSLayoutConstraint.Attribute.trailing, relatedBy: NSLayoutConstraint.Relation.equal, toItem: vc.view, attribute: NSLayoutConstraint.Attribute.trailing, multiplier: 1, constant: 0)
        let lead = NSLayoutConstraint(item: self, attribute: NSLayoutConstraint.Attribute.leading, relatedBy: NSLayoutConstraint.Relation.equal, toItem: vc.view, attribute: NSLayoutConstraint.Attribute.leading, multiplier: 1, constant: 0)
        
        switch presentType {
        case .bottom:
            let buttom = NSLayoutConstraint(item: self, attribute: NSLayoutConstraint.Attribute.bottom, relatedBy: NSLayoutConstraint.Relation.equal, toItem: vc.view, attribute: NSLayoutConstraint.Attribute.bottom, multiplier: 1, constant: 0)
            self.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([buttom,trail,lead])
            break
        case .center:
            let center = NSLayoutConstraint(item: self, attribute: NSLayoutConstraint.Attribute.centerY, relatedBy: NSLayoutConstraint.Relation.equal, toItem: vc.view, attribute: NSLayoutConstraint.Attribute.centerY, multiplier: 1, constant: 0)
            
            self.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([center,trail,lead])
            
            break
            
        case .belowNav:
            var top: NSLayoutConstraint!
            if #available(iOS 11.0, *) {
                let guide = vc.view.safeAreaLayoutGuide
                top =  self.topAnchor.constraint(equalTo: guide.topAnchor, constant: ToastPosition.navHeight)
            }else  {
                top =   self.topAnchor.constraint(equalTo: vc.topLayoutGuide.bottomAnchor, constant:ToastPosition.navHeight)
            }
            self.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([top,trail,lead])
            
            break
        default:
            let top = NSLayoutConstraint(item: self, attribute: NSLayoutConstraint.Attribute.top, relatedBy: NSLayoutConstraint.Relation.equal, toItem: vc.view, attribute: NSLayoutConstraint.Attribute.top, multiplier: 1, constant: 0)
            self.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([top,trail,lead])
            break
        }
    }
    
    fileprivate func getToastMsgFrame() -> (yPos: CGFloat, height: CGFloat, screenSize: CGSize) {
        var height = self.msgHeight()
        var statusBarHeight: CGFloat = 0.0
        let orientation = _statusBarOrientation
        
        if orientation.isPortrait{
            statusBarHeight = _statusBarFrame.height
        }
        var yPos : CGFloat = statusBarHeight
        let screenSize: CGSize = self.window_Appdelegate.frame.size
        
        switch presentType {
        case .bottom:
            yPos = 0.0
            if #available(iOS 11.0, *) {
                height += _safeAreaInsets.bottom
            }
            yPos = screenSize.height - height - yPos
            
            break
        case .center:
            yPos = screenSize.height/2 - height/2
            break
        case .belowNav:
            if #available(iOS 11.0, *) {
                yPos = _safeAreaInsets.top
            }
            yPos += ToastPosition.navHeight
            break
            
        default:
            yPos = 0.0
            //            self.clipsToBounds = false
            
            if #available(iOS 11.0, *) {
                height += _safeAreaInsets.top
            }else{
                height += statusBarHeight
            }
            break
            
        }
        
        return (yPos, height, screenSize)
    }
    
    
    // get message Height
    fileprivate func msgHeight() -> CGFloat{
        
        let screenSize: CGSize = self.window_Appdelegate.frame.size
        var panding: CGFloat = 20
        if #available(iOS 11.0, *) {
            let orientation = _statusBarOrientation
            if orientation.isLandscape{
                panding += _safeAreaInsets.left * 2
            }
        }
        let size = CGSize(width: screenSize.width - panding, height: .infinity)
        let estimatedSize = lblMessage.sizeThatFits(size)
        return max((ToastPosition.navHeight), (estimatedSize.height + 20))
    }
    
    fileprivate func prepareForAnimation(_ isShow: Bool = false){
        if self.animationStlye == .slide{
            self.viewMessage.alpha = 1.0
        }else{
            self.viewMessage.alpha = isShow ? 1.0 : 0.0
        }
    }
    // MARK: - Toast Animation Functions
    func animateIn(duration: TimeInterval, delay: TimeInterval, completion: ((_ completed: Bool) -> ())? = nil) {
        if self.animationStlye == .slide{
            let result = self.getToastMsgFrame()
            self.viewMessage.alpha = 1.0
            if self.presentType == .bottom{
                self.viewMessage.transform = CGAffineTransform(translationX: 0, y: (result.height + result.yPos))
            }else if self.presentType == .center{
                self.viewMessage.transform = CGAffineTransform(scaleX: 1, y: 0)
            } else{
                self.viewMessage.transform = CGAffineTransform(translationX: 0, y: -(result.height + result.yPos))
            }
        }
        UIView.animate(withDuration: duration, delay: delay, options: UIView.AnimationOptions.beginFromCurrentState, animations: { () -> Void in
            if self.animationStlye == .slide{
                self.viewMessage.transform = CGAffineTransform.identity
            }else{
                self.viewMessage.alpha = 1.0
            }
        }) { (completed) -> Void in
            completion?(completed)
        }
    }
    
    func animateOut(duration: TimeInterval, delay: TimeInterval, completion: ((_ completed: Bool) -> ())? = nil) {
        let result = self.getToastMsgFrame()
        UIView.animate(withDuration: duration, delay: delay, options: UIView.AnimationOptions.beginFromCurrentState, animations: { () -> Void in
            if self.animationStlye == .slide{
                if self.presentType == .bottom{
                    self.viewMessage.transform = CGAffineTransform(translationX: 0, y: (result.height + result.yPos))
                }else if self.presentType == .center{
                    self.viewMessage.transform = CGAffineTransform(scaleX: 1, y: -0.01)
                }else{
                    self.viewMessage.transform = CGAffineTransform(translationX: 0, y: -(result.height + result.yPos))
                }
            }
            self.viewMessage.alpha = 0.0
            
        }) { (completed) -> Void in
            completion?(completed)
        }
    }
    // MARK: Notifications
    @objc  func deviceOrientationDidChange(_ noti: Notification) {
        self.setNeedsLayout()
    }
 
    override open func hitTest(_ point: CGPoint, with event: UIEvent!) -> UIView? {
        if let superview = self.superview {
            let pointInWindow = self.convert(point, to: superview)
            let contains = self.frame.contains(pointInWindow)
            if contains && self.isUserInteractionEnabled {
                return self
            }
        }
        return nil
    }
}

// MARK: - Toast Controller
class VToastVC: UIViewController {
    var toast : ValidationToast?
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    override var preferredStatusBarUpdateAnimation : UIStatusBarAnimation {
        return  .none
    }
    
    // Toast dismiss controller
    func dismissToast(block :(( _ success:Bool) ->())? = nil){
        if let atoast = toast{
            atoast.animateOut(duration: 0.2, delay: 1.5, completion: { (completed) -> () in
                atoast.removeFromSuperview()
                block?(true)
                self.dismiss(animated: false, completion: nil)
            })
        }else{
            block?(true)
            self.dismiss(animated: false, completion: nil)
        }
    }
}
 
