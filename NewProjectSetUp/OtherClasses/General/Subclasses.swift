//
//  Subclasses.swift
//  FitFin
//
//  Created by MAC OS 13 on 07/12/21.
//

import Foundation
import UIKit

// MARK: -Device Ratio Enum

enum APDeviceRatio : Int {
    case width      = 1
    case height      = 2
    case `default`  = 0
}

// MARK:- GenericCollectionViewCell
class GenericCollectionViewCell: ConstrainedCollectionViewCell {
    
    @IBOutlet var lblTitle: UILabel!
    @IBOutlet var lblSubtitle: UILabel!
    @IBOutlet var imgv: UIImageView!
    @IBOutlet var imgBg: UIImageView!
    @IBOutlet var lblSeparatorLine: UILabel!
    @IBOutlet var bgView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}

// MARK:- GenericTableViewCell
class GenericTableViewCell: ConstrainedTableViewCell {
    
    @IBOutlet var lblTitle: UILabel!
    @IBOutlet var lblSubtitle: UILabel!
    @IBOutlet var lblSeparatorLine: UILabel!
    
    @IBOutlet var imgv: UIImageView!
    @IBOutlet var imgvBg: UIImageView!
    @IBOutlet var bgView: UIView!
    
    @IBInspectable var highlightedColor: UIColor = UIColor.clear
    @IBInspectable var normalColor: UIColor = UIColor.clear
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        if highlighted {
            backgroundColor = self.highlightedColor
        } else {
            backgroundColor = self.normalColor
        }
    }
}

// MARK:- GenericHeaderCollectionView
class GenericHeaderCollectionView: ConstrainedHeaderCollectionView {
    
    @IBOutlet var lblTitle: UILabel!
    @IBOutlet var lblSubtitle: UILabel!
    
}

// MARK:- APRoundedImageView
class APRoundedImageView: UIImageView {
    @IBInspectable var maskImage : UIImage?
    
    @IBInspectable var borderColor: UIColor = UIColor.clear{
        didSet {
            setNeedsLayout()
        }
    }
    @IBInspectable var cRadius: CGFloat = 0.0{
        didSet {
            setNeedsLayout()
        }
    }
    @IBInspectable var borderWidth: CGFloat = 0.0{
        didSet {
            setNeedsLayout()
        }
    }
    @IBInspectable var fullRounded: Bool = false{
        didSet {
            setNeedsLayout()
        }
    }
    @IBInspectable var mask_corners: String = "0,0,0,0"{
        didSet {
            setNeedsLayout()
        }
    }
    @IBInspectable var flip_maskImg: Bool = false
    @IBInspectable var flip_Img: Bool = false
    
    @IBInspectable var showShadow: Bool = false{
        didSet {
            setNeedsLayout()
        }
    }
    
    @IBInspectable var shColor: UIColor = UIColor.clear{
        didSet {
            setNeedsLayout()
        }
    }
    @IBInspectable var shOpacity: Float = 0.0{
        didSet {
            setNeedsLayout()
        }
    }
    @IBInspectable var shOffset: CGSize = CGSize.zero{
        didSet {
            setNeedsLayout()
        }
    }
    @IBInspectable var blur: CGFloat = 0{
        didSet {
            setNeedsLayout()
        }
    }
    
    var maskImgv : UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.image = self.flip_maskImg ? self.image?.withHorizontallyFlippedOrientation() : self.image
        self.prepareUI()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.prepareUI()
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        prepareUI()
    }
    //    override func setNeedsLayout() {
    //        super.setNeedsLayout()
    //        self.setNeedsDisplay()
    //    }
    
    
    func prepareUI() {
        //        self.layoutIfNeeded()
        self.prepareImageMaskingUI()
        self.layer.borderWidth = self.borderWidth
        self.layer.borderColor = self.borderColor.cgColor
        if self.showShadow{
            self.layer.shadowColor = self.shColor.cgColor
            self.layer.shadowOpacity = self.shOpacity
            self.layer.shadowOffset = self.shOffset
            self.layer.shadowRadius = self.blur
        }else{
            self.layer.shadowColor = UIColor.clear.cgColor
            self.layer.shadowOpacity = 0
        }
        
        // Corner Radius
        if (self.fullRounded || self.cRadius > 0 ) {
            let comp = mask_corners.components(separatedBy: ",")
            var corners: UIRectCorner = []
            var cornerMask: CACornerMask = []
            for (idx,str) in comp.enumerated(){
                if str >= "1" && idx == 0{
                    corners = [.topLeft]
                    cornerMask = [.layerMinXMinYCorner]
                }else if str >= "1" && idx == 1{
                    corners.insert(.topRight)
                    cornerMask.insert(.layerMaxXMinYCorner)
                }else if str >= "1" && idx == 2{
                    corners.insert(.bottomLeft)
                    cornerMask.insert(.layerMinXMaxYCorner)
                }else if str >= "1" && idx == 3{
                    corners.insert(.bottomRight)
                    cornerMask.insert(.layerMaxXMaxYCorner)
                    break
                }
            }
            if corners.isEmpty{
                corners = .allCorners
            }
            if cornerMask.isEmpty{
                cornerMask = [.layerMinXMinYCorner, .layerMinXMaxYCorner , .layerMaxXMinYCorner, .layerMaxXMaxYCorner]
            }
            self.roundCorners(corners,cornerMask, radius: self.fullRounded ? self.bounds.size.height/2 :self.cRadius)
        }
        
        
    }
    
    func prepareImageMaskingUI(){
        if let img = maskImage{
            if maskImgv == nil{
                maskImgv = UIImageView()
            }
            maskImgv.image = self.flip_maskImg ? img.withHorizontallyFlippedOrientation() : img
            maskImgv.frame = bounds
            mask = maskImgv
        }
    }
    
}

// MARK:- APRoundedButton
@IBDesignable
class APRoundedButton: UIButton {
    var deviceRatio: APDeviceRatio = APDeviceRatio.default
    @IBInspectable var deviceRatioType: Int {
        get {
            return self.deviceRatio.rawValue
        }
        set( new) {
            self.deviceRatio = APDeviceRatio(rawValue: new) ?? .default
        }
    }
    
    @IBInspectable var borderColor: UIColor = UIColor.clear{
        didSet {
            setNeedsLayout()
        }
    }
    @IBInspectable var cRadius: CGFloat = 0.0{
        didSet {
            setNeedsLayout()
        }
    }
    @IBInspectable var borderWidth: CGFloat = 0.0{
        didSet {
            setNeedsLayout()
        }
    }
    @IBInspectable var fullRounded: Bool = false{
        didSet {
            setNeedsLayout()
        }
    }
    @IBInspectable var mask_corners: String = "0,0,0,0"{
        didSet {
            setNeedsLayout()
        }
    }
    
    @IBInspectable var showShadow: Bool = false{
        didSet {
            setNeedsLayout()
        }
    }
    @IBInspectable var numberOfLines: Int = 0{
        didSet {
            setNeedsLayout()
        }
    }
    
    @IBInspectable var shColor: UIColor = UIColor.clear{
        didSet {
            setNeedsLayout()
        }
    }
    @IBInspectable var shOpacity: Float = 0.0{
        didSet {
            setNeedsLayout()
        }
    }
    @IBInspectable var shOffset: CGSize = CGSize.zero{
        didSet {
            setNeedsLayout()
        }
    }
    @IBInspectable var blur: CGFloat = 0{
        didSet {
            setNeedsLayout()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.prepareToDeviceRatioUI()
        self.prepareUI()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.prepareUI()
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        prepareUI()
    }
    
    //    override func setNeedsLayout() {
    //        super.setNeedsLayout()
    //        self.setNeedsDisplay()
    //    }
    
    
    func prepareUI(){
        self.layoutIfNeeded()
        
        self.layer.borderWidth = self.borderWidth
        self.layer.borderColor = self.borderColor.cgColor
        self.layer.cornerRadius = self.fullRounded ? self.bounds.size.height/2 :self.cRadius
        if self.showShadow{
            self.layer.shadowColor = self.shColor.cgColor
            self.layer.shadowOpacity = self.shOpacity
            self.layer.shadowOffset = self.shOffset
            self.layer.shadowRadius = self.blur
        }else{
            self.layer.shadowColor = UIColor.clear.cgColor
            self.layer.shadowOpacity = 0
            self.layer.masksToBounds = (self.fullRounded || self.cRadius > 0 )
        }
        
        // Corner Radius
        if (self.fullRounded || self.cRadius > 0 ) {
            let comp = mask_corners.components(separatedBy: ",")
            var corners: UIRectCorner = []
            var cornerMask: CACornerMask = []
            for (idx,str) in comp.enumerated(){
                if str >= "1" && idx == 0{
                    corners = [.topLeft]
                    cornerMask = [.layerMinXMinYCorner]
                }else if str >= "1" && idx == 1{
                    corners.insert(.topRight)
                    cornerMask.insert(.layerMaxXMinYCorner)
                }else if str >= "1" && idx == 2{
                    corners.insert(.bottomLeft)
                    cornerMask.insert(.layerMinXMaxYCorner)
                }else if str >= "1" && idx == 3{
                    corners.insert(.bottomRight)
                    cornerMask.insert(.layerMaxXMaxYCorner)
                    break
                }
            }
            if corners.isEmpty{
                corners = .allCorners
            }
            if cornerMask.isEmpty{
                cornerMask = [.layerMinXMinYCorner, .layerMinXMaxYCorner , .layerMaxXMinYCorner, .layerMaxXMaxYCorner]
            }
            self.roundCorners(corners,cornerMask, radius: self.fullRounded ? self.bounds.size.height/2 :self.cRadius)
        }
        
        // Corner Radius
        if (self.fullRounded || self.cRadius > 0 ) {
            let comp = mask_corners.components(separatedBy: ",")
            var corners: UIRectCorner = []
            var cornerMask: CACornerMask = []
            for (idx,str) in comp.enumerated(){
                if str >= "1" && idx == 0{
                    corners = [.topLeft]
                    cornerMask = [.layerMinXMinYCorner]
                }else if str >= "1" && idx == 1{
                    corners.insert(.topRight)
                    cornerMask.insert(.layerMaxXMinYCorner)
                }else if str >= "1" && idx == 2{
                    corners.insert(.bottomLeft)
                    cornerMask.insert(.layerMinXMaxYCorner)
                }else if str >= "1" && idx == 3{
                    corners.insert(.bottomRight)
                    cornerMask.insert(.layerMaxXMaxYCorner)
                    break
                }
            }
            if corners.isEmpty{
                corners = .allCorners
            }
            if cornerMask.isEmpty{
                cornerMask = [.layerMinXMinYCorner, .layerMinXMaxYCorner , .layerMaxXMinYCorner, .layerMaxXMaxYCorner]
            }
            self.roundCorners(corners,cornerMask, radius: self.fullRounded ? self.bounds.size.height/2 :self.cRadius)
        }
    }
    
    func prepareToDeviceRatioUI(){
        
        if numberOfLines != 1{
            switch self.contentHorizontalAlignment {
            case .left:
                self.titleLabel?.textAlignment = .left
                break
            case .right:
                self.titleLabel?.textAlignment = .right
                break
            default:
                self.titleLabel?.textAlignment = .center
                break
            }
            self.titleLabel?.numberOfLines = numberOfLines
            self.titleLabel?.adjustsFontSizeToFitWidth = true
        }
        
        if deviceRatio == .width{
            if let afont  = self.titleLabel?.font{
                self.titleLabel?.font = afont.withSize(afont.pointSize * _widthRatio)
            }
        }
        
        if let imgv = self.imageView, deviceRatio != .default{
            let btnsize = self.frame.size
            let imgsize = imgv.frame.size
            let verPad = (deviceRatio == .width) ? (((btnsize.height * _widthRatio) - (imgsize.height * _widthRatio)) / 2) : (((btnsize.height * _heightRatio) - (imgsize.height * _heightRatio)) / 2)
            self.imageEdgeInsets = UIEdgeInsets.init(top: verPad, left: 0, bottom: verPad, right: 0)
            self.imageView?.contentMode = .scaleAspectFit
        }
    }
    
}

// MARK:- APRoundedLabel
class APRoundedLabel: UILabel {
    var deviceRatio: APDeviceRatio = APDeviceRatio.default
    @IBInspectable var deviceRatioType: Int {
        get {
            return self.deviceRatio.rawValue
        }
        set( new) {
            self.deviceRatio = APDeviceRatio(rawValue: new) ?? .default
        }
    }
    
    @IBInspectable var borderColor: UIColor = UIColor.clear{
        didSet {
            setNeedsLayout()
        }
    }
    @IBInspectable var cRadius: CGFloat = 0.0{
        didSet {
            setNeedsLayout()
        }
    }
    @IBInspectable var borderWidth: CGFloat = 0.0{
        didSet {
            setNeedsLayout()
        }
    }
    @IBInspectable var fullRounded: Bool = false{
        didSet {
            setNeedsLayout()
        }
    }
    @IBInspectable var mask_corners: String = "0,0,0,0"{
        didSet {
            setNeedsLayout()
        }
    }
    
    @IBInspectable var paddingApply: Bool = false{
        didSet {
            setNeedsLayout()
        }
    }
    @IBInspectable var topInset: CGFloat = 0.0{
        didSet {
            setNeedsLayout()
        }
    }
    @IBInspectable var leftInset: CGFloat = 0.0{
        didSet {
            setNeedsLayout()
        }
    }
    @IBInspectable var bottomInset: CGFloat = 0.0{
        didSet {
            setNeedsLayout()
        }
    }
    @IBInspectable var rightInset: CGFloat = 0.0{
        didSet {
            setNeedsLayout()
        }
    }
    
    var insets: UIEdgeInsets {
        get {
            return UIEdgeInsets.init(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)
        }
        set {
            topInset = newValue.top
            leftInset = newValue.left
            bottomInset = newValue.bottom
            rightInset = newValue.right
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.prepareToDeviceRatioUI()
        self.prepareUI()
    }
    
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect)
    }
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        var adjSize = super.sizeThatFits(size)
        if self.paddingApply{
            adjSize.width += leftInset + rightInset
            adjSize.height += topInset + bottomInset
        }
        
        return adjSize
    }
    override var intrinsicContentSize: CGSize {
        var contentSize = super.intrinsicContentSize
        if self.paddingApply{
            contentSize.width += leftInset + rightInset
            contentSize.height += topInset + bottomInset
        }
        return contentSize
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.prepareUI()
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        prepareUI()
    }
    //    override func setNeedsLayout() {
    //        super.setNeedsLayout()
    //        self.setNeedsDisplay()
    //    }
    
    
    func prepareUI() {
        //        self.layoutIfNeeded()
        
        self.layer.borderWidth = self.borderWidth
        self.layer.borderColor = self.borderColor.cgColor
        
        // Corner Radius
        if (self.fullRounded || self.cRadius > 0 ) {
            let comp = mask_corners.components(separatedBy: ",")
            var corners: UIRectCorner = []
            var cornerMask: CACornerMask = []
            for (idx,str) in comp.enumerated(){
                if str >= "1" && idx == 0{
                    corners = [.topLeft]
                    cornerMask = [.layerMinXMinYCorner]
                }else if str >= "1" && idx == 1{
                    corners.insert(.topRight)
                    cornerMask.insert(.layerMaxXMinYCorner)
                }else if str >= "1" && idx == 2{
                    corners.insert(.bottomLeft)
                    cornerMask.insert(.layerMinXMaxYCorner)
                }else if str >= "1" && idx == 3{
                    corners.insert(.bottomRight)
                    cornerMask.insert(.layerMaxXMaxYCorner)
                    break
                }
            }
            if corners.isEmpty{
                corners = .allCorners
            }
            if cornerMask.isEmpty{
                cornerMask = [.layerMinXMinYCorner, .layerMinXMaxYCorner , .layerMaxXMinYCorner, .layerMaxXMaxYCorner]
            }
            self.roundCorners(corners,cornerMask, radius: self.fullRounded ? self.bounds.size.height/2 :self.cRadius)
        }
    }
    
    func prepareToDeviceRatioUI(){
        if deviceRatio == .width{
            self.font = self.font.withSize(self.font.pointSize  * _widthRatio)
        }
    }
}

// MARK:- APRoundedView
@IBDesignable
class APRoundedView: UIView {
    @IBInspectable var borderColor: UIColor = UIColor.clear{
        didSet {
            setNeedsLayout()
        }
    }
    @IBInspectable var cRadius: CGFloat = 0.0{
        didSet {
            setNeedsLayout()
        }
    }
    @IBInspectable var borderWidth: CGFloat = 0.0{
        didSet {
            setNeedsLayout()
        }
    }
    @IBInspectable var fullRounded: Bool = false{
        didSet {
            setNeedsLayout()
        }
    }
    @IBInspectable var mask_corners: String = "0,0,0,0"{
        didSet {
            setNeedsLayout()
        }
    }
    
    @IBInspectable var shadowColor: UIColor?{
        didSet {
            setNeedsLayout()
        }
    }
    @IBInspectable var shadowOpacity: Float = 0.0{
        didSet {
            setNeedsLayout()
        }
    }
    @IBInspectable var shadowOffset: CGSize = CGSize.zero{
        didSet {
            setNeedsLayout()
        }
    }
    @IBInspectable var shadowBlur: CGFloat = 0{
        didSet {
            setNeedsLayout()
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.prepareUI()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.prepareUI()
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        prepareUI()
    }
    //    override func setNeedsLayout() {
    //        super.setNeedsLayout()
    //        self.setNeedsDisplay()
    //    }
    
    
    func prepareUI() {
        //        self.layoutIfNeeded()
        self.layer.borderWidth = self.borderWidth
        self.layer.borderColor = self.borderColor.cgColor
        self.layer.cornerRadius = self.fullRounded ? self.bounds.size.height/2 :self.cRadius
        
        if let shColor = self.shadowColor{
            self.layer.shadowColor = shColor.cgColor
            self.layer.shadowOpacity = self.shadowOpacity
            self.layer.shadowOffset = self.shadowOffset
            self.layer.shadowRadius = self.shadowBlur
            self.layer.masksToBounds = false
        }else{
            self.layer.shadowColor = UIColor.clear.cgColor
            self.layer.shadowOpacity = 0
            self.layer.masksToBounds = (self.fullRounded || self.cRadius > 0 )
        }
        
        
        // Corner Radius
        if (self.fullRounded || self.cRadius > 0 ) {
            let comp = mask_corners.components(separatedBy: ",")
            var corners: UIRectCorner = []
            var cornerMask: CACornerMask = []
            for (idx,str) in comp.enumerated(){
                if str >= "1" && idx == 0{
                    corners = [.topLeft]
                    cornerMask = [.layerMinXMinYCorner]
                }else if str >= "1" && idx == 1{
                    corners.insert(.topRight)
                    cornerMask.insert(.layerMaxXMinYCorner)
                }else if str >= "1" && idx == 2{
                    corners.insert(.bottomLeft)
                    cornerMask.insert(.layerMinXMaxYCorner)
                }else if str >= "1" && idx == 3{
                    corners.insert(.bottomRight)
                    cornerMask.insert(.layerMaxXMaxYCorner)
                    break
                }
            }
            if corners.isEmpty {
                corners = .allCorners
            }
            if cornerMask.isEmpty{
                cornerMask = [.layerMinXMinYCorner, .layerMinXMaxYCorner , .layerMaxXMinYCorner, .layerMaxXMaxYCorner]
            }
            self.roundCorners(corners,cornerMask, radius: self.fullRounded ? self.bounds.size.height/2 :self.cRadius)
        }
    }
}

//@IBDesignable
class GradientView: APRoundedView {
    
    @IBInspectable var firstColor: UIColor = UIColor.clear {
        didSet {
            setNeedsLayout()
        }
    }
    
    @IBInspectable var secondColor: UIColor = UIColor.clear {
        didSet {
            setNeedsLayout()
        }
    }

    @IBInspectable var isHorizontal: Bool = true {
        didSet {
            setNeedsLayout()
        }
    }
    
      @IBInspectable var start_Point: CGPoint = CGPoint.zero {
        didSet {
            setNeedsLayout()
        }
    }
    
    @IBInspectable var end_Point: CGPoint = CGPoint.zero{
        didSet {
            setNeedsLayout()
        }
    }

    
    
    override class var layerClass: AnyClass {
        get {
            return CAGradientLayer.self
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.updateView()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.updateView()
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        updateView()
    }
    
    func updateView() {
        let layer = self.layer as! CAGradientLayer
        layer.colors = [firstColor, secondColor].map {$0.cgColor}
        if (isHorizontal) {
            layer.startPoint = start_Point
            layer.endPoint = end_Point
        } else {
            layer.startPoint = CGPoint(x: 0.5, y: 0)
            layer.endPoint = CGPoint (x: 0.5, y: 1)
        }
    }
    
}


// MARK:- APGradientView
//@IBDesignable
class APGradientView: APRoundedView {
    @IBInspectable var topColor: UIColor = UIColor.white {
        didSet {
            setNeedsLayout()
        }
    }
    @IBInspectable var bottomColor: UIColor = UIColor.black {
        didSet {
            setNeedsLayout()
        }
    }
  
    @IBInspectable var start_Point: CGPoint = CGPoint.zero {
        didSet {
            setNeedsLayout()
        }
    }
    
    @IBInspectable var end_Point: CGPoint = CGPoint.zero{
        didSet {
            setNeedsLayout()
        }
    }
    
    override class var layerClass: AnyClass {
        return CAGradientLayer.self
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.prepareUI()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.prepareUI()
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        prepareUI()
    }
    //    override func setNeedsLayout() {
    //        super.setNeedsLayout()
    //        self.setNeedsDisplay()
    //    }
    
    override func prepareUI() {
        let gradientLayer = layer as! CAGradientLayer
        gradientLayer.colors = [topColor.cgColor, bottomColor.cgColor]
        gradientLayer.startPoint = start_Point
        gradientLayer.endPoint = end_Point
         //        self.layoutIfNeeded()
        self.layer.borderWidth = self.borderWidth
        self.layer.borderColor = self.borderColor.cgColor
        self.layer.cornerRadius = self.fullRounded ? self.bounds.size.height/2 :self.cRadius
        
        if let shColor = self.shadowColor{
            self.layer.shadowColor = shColor.cgColor
            self.layer.shadowOpacity = self.shadowOpacity
            self.layer.shadowOffset = self.shadowOffset
            self.layer.shadowRadius = self.shadowBlur
            self.layer.masksToBounds = false
        }else{
            self.layer.shadowColor = UIColor.clear.cgColor
            self.layer.shadowOpacity = 0
            self.layer.masksToBounds = (self.fullRounded || self.cRadius > 0 )
        }
        
        
        // Corner Radius
        if (self.fullRounded || self.cRadius > 0 ) {
            let comp = mask_corners.components(separatedBy: ",")
            var corners: UIRectCorner = []
            var cornerMask: CACornerMask = []
            for (idx,str) in comp.enumerated(){
                if str >= "1" && idx == 0{
                    corners = [.topLeft]
                    cornerMask = [.layerMinXMinYCorner]
                }else if str >= "1" && idx == 1{
                    corners.insert(.topRight)
                    cornerMask.insert(.layerMaxXMinYCorner)
                }else if str >= "1" && idx == 2{
                    corners.insert(.bottomLeft)
                    cornerMask.insert(.layerMinXMaxYCorner)
                }else if str >= "1" && idx == 3{
                    corners.insert(.bottomRight)
                    cornerMask.insert(.layerMaxXMaxYCorner)
                    break
                }
            }
            if corners.isEmpty {
                corners = .allCorners
            }
            if cornerMask.isEmpty{
                cornerMask = [.layerMinXMinYCorner, .layerMinXMaxYCorner , .layerMaxXMinYCorner, .layerMaxXMaxYCorner]
            }
            self.roundCorners(corners,cornerMask, radius: self.fullRounded ? self.bounds.size.height/2 :self.cRadius)
        }
    }
}
// MARK:- APTextFiled
class APTextFiled: UITextField {
    @IBInspectable var placeholderColor: UIColor = UIColor.white
    @IBInspectable var placeholderFont: UIFont?
    @IBInspectable var clearBtnImage : UIImage?
    var custom_placeholder_attributes :[NSAttributedString.Key:Any]? {
        didSet{
            updatePlaceholdeUI()
        }
    }
    override var placeholder: String?{
        didSet {
            updatePlaceholdeUI()
        }
    }
    
    var deviceRatio: APDeviceRatio = APDeviceRatio.default
    @IBInspectable var deviceRatioType: Int {
        get {
            return self.deviceRatio.rawValue
        }
        set( new) {
            self.deviceRatio = APDeviceRatio(rawValue: new) ?? .default
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layoutIfNeeded()
        self.prepareToDeviceRatioUI()
        if let img = self.clearBtnImage, let clearButton = self.value(forKey: "_clearButton") as? UIButton  {
            // Set the template image copy as the button image
            clearButton.setImage(img, for: .normal)
        }
    }
    override func layoutSubviews() {
        super.layoutSubviews()
         if let img = self.clearBtnImage, let clearButton = self.value(forKey: "_clearButton") as? UIButton  {
            // Set the template image copy as the button image
            clearButton.setImage(img, for: .normal)
        }
    }
    func prepareToDeviceRatioUI(){
        if deviceRatio == .width{
            if let afont = font {
                font = afont.withSize(afont.pointSize * _widthRatio)
            }
        }else if deviceRatio == APDeviceRatio.height{
            if let afont = font {
                font = afont.withSize(afont.pointSize * _heightRatio)
            }
        }
        self.updatePlaceholdeUI()
        
    }
    func updatePlaceholdeUI(){
        var attributes :[NSAttributedString.Key:Any] =  [NSAttributedString.Key.foregroundColor :  self.placeholderColor]
        if let cattributes = custom_placeholder_attributes{
            attributes.merge(with: cattributes)
        }
        if let afont = self.placeholderFont{
            if deviceRatio == APDeviceRatio.width{
                attributes[NSAttributedString.Key.font] = afont.withSize(afont.pointSize * _widthRatio)
            }else if deviceRatio == APDeviceRatio.height{
                attributes[NSAttributedString.Key.font] = afont.withSize(afont.pointSize * _heightRatio)
            }else{
                attributes[NSAttributedString.Key.font] = afont
            }
        }
        self.attributedPlaceholder = NSAttributedString(string: self.placeholder ?? "", attributes: attributes)
    }
}

// MARK:- APLinkTextView
class APLinkTextView: UITextView {
    override func awakeFromNib() {
        super.awakeFromNib()
        self.isScrollEnabled = false
        self.isEditable = false
        self.isSelectable = true
        self.textContainerInset = UIEdgeInsets.init(top: 0, left: -5, bottom: 0, right: -5)
        if #available(iOS 11.0, *) {
            self.textDragInteraction?.isEnabled = false
        }
    }
    // diable to selction and only allow link
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        
        guard let pos = closestPosition(to: point) else { return false }
        
        guard let range = tokenizer.rangeEnclosingPosition(pos, with: .character, inDirection: UITextDirection(rawValue: UITextLayoutDirection.left.rawValue)) else { return false }
        
        let startIndex = offset(from: beginningOfDocument, to: range.start)
        
        return attributedText.attribute(NSAttributedString.Key.link, at: startIndex, effectiveRange: nil) != nil
    }
    
    override var canBecomeFirstResponder: Bool { return false }
    
    override var canBecomeFocused: Bool { return false }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return false
    }
}


// MARK: - APPageControl
class APPageControl: UIPageControl {
     @IBInspectable var dotSpacing: CGFloat = 6{
        didSet {
            UIView.animate(withDuration: 0.4) {
                self.layoutSubviews()
            }
        }
    }
    
    @IBInspectable var dotSize: CGFloat = 6{
        didSet {
            UIView.animate(withDuration: 0.4) {
                self.layoutSubviews()
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        var i: Int = 0
        let width: CGFloat = self.dotSize * (CGFloat)(self.subviews.count + 3) + self.dotSpacing * (CGFloat)(self.subviews.count - 1)
        var x: CGFloat = self.frame.size.width / 2 - (width / 2)
        let y: CGFloat = self.frame.size.height / 2 - self.dotSize / 2
        
        for view in self.subviews {
            var frame: CGRect = view.frame
            frame.origin.x = x
            frame.origin.y = y
            if (self.currentPage == i) {
                frame.size = CGSize(width: self.dotSize * 4, height: self.dotSize)
                x += self.dotSize * 4 + self.dotSpacing
            } else {
                frame.size = CGSize(width: self.dotSize, height: self.dotSize)
                x += self.dotSize + self.dotSpacing
            }
            view.layer.cornerRadius = self.dotSize / 2
            view.frame = frame
            i += 1
        }
    }
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        self.layoutSubviews()
    }
}


// MARK: - APDashedBorderView
class APDashedBorderView: UIView {
    var shapeLayer = CAShapeLayer()
    
    @IBInspectable var shapeStrokeColor: UIColor = UIColor(hex: "e9e9ee"){
        didSet {
            setNeedsLayout()
        }
    }
    @IBInspectable var shapeFillColor: UIColor?{
        didSet {
            setNeedsLayout()
        }
    }
    @IBInspectable var lineWidth: CGFloat = 1 {
        didSet {
            setNeedsLayout()
        }
    }
    @IBInspectable var fullRounded: Bool = false{
        didSet {
            setNeedsLayout()
        }
    }
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            setNeedsLayout()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initShadowLayer()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initShadowLayer()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.prepareUI()
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        prepareUI()
    }
    
    fileprivate func initShadowLayer() {
        self.shapeLayer.lineDashPattern = [1.2, 1]
          layer.addSublayer(self.shapeLayer)
    }
    
    func prepareUI(){
        self.layoutIfNeeded()
        let cRadius = self.fullRounded ? self.bounds.size.height/2 : self.cornerRadius
        self.shapeLayer.fillColor = self.shapeFillColor?.cgColor
        self.shapeLayer.strokeColor = self.shapeStrokeColor.cgColor
        self.shapeLayer.lineWidth = self.lineWidth
        self.shapeLayer.path = UIBezierPath(roundedRect: self.bounds, cornerRadius: cRadius).cgPath
        self.shapeLayer.frame =  self.bounds
        self.layer.cornerRadius = cRadius
    }
    
}
