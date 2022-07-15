//
//  UIColorExtension.swift
//  FitFin
//
//  Created by MAC OS 13 on 07/12/21.
//

import Foundation
import UIKit


// MARK: - Hex and RGB Methods with DisplayP3 or SRGB
extension UIColor {
    //Initialize
    convenience init(hex: String, alpha: CGFloat = 1.0, isDisplayP3: Bool = false) {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        let scanner = Scanner(string: cString)
        //        scanner.scanLocation = 0
        
        var rgbValue: UInt64 = 0
        
        scanner.scanHexInt64(&rgbValue)
        
        let r = (rgbValue & 0xff0000) >> 16
        let g = (rgbValue & 0xff00) >> 08
        let b = rgbValue & 0xff
        if #available(iOS 10.0, *), isDisplayP3 {
            self.init(displayP3Red: CGFloat(r) / 0xff, green: CGFloat(g) / 0xff, blue: CGFloat(b) / 0xff, alpha: alpha)
        }else{
            self.init(red: CGFloat(r) / 0xff, green: CGFloat(g) / 0xff, blue: CGFloat(b) / 0xff, alpha: alpha )
        }
        
    }
    
    // Class Methods
    class func colorWithRGB(r: CGFloat, g: CGFloat, b: CGFloat, alpha: CGFloat = 1.0, isDisplayP3: Bool = false) -> UIColor {
        if #available(iOS 10.0, *), isDisplayP3 {
            return UIColor(displayP3Red: r / 255.0, green: g / 255.0, blue: b / 255.0, alpha: alpha)
        }else{
            return UIColor(red: r / 255.0, green: g / 255.0, blue: b / 255.0, alpha: alpha)
        }
    }
    
    class func colorWithGray(gray: CGFloat, alpha: CGFloat = 1.0, isDisplayP3: Bool = false) -> UIColor {
        return colorWithRGB(r: gray, g: gray, b: gray, alpha: alpha, isDisplayP3: isDisplayP3)
    }
}


// MARK:- App Colors

enum AppColor: String {
    
    case app_black_000000 = "app_black_000000"
    case app_white_ffffff = "app_white_ffffff"
    case app_dark_green_004718 = "app_dark_green_004718"
    case app_dark_orange_EC9428 = "app_dark_orange_EC9428"
    case app_light_green_006622 = "app_light_green_006622"
    case app_light_orange_F8BC69 = "app_light_orange_F8BC69"
    case app_textfield_green_006622 = "app_textfield_green_006622"
    case app_placeholder_grey_C7C7CC = "app_placeholder_grey_C7C7CC"
    //MARK:- Method
    func color(_ alpha: CGFloat? = nil) -> UIColor {
        if let color = UIColor(named: self.rawValue){
            if let a = alpha{
                return color.withAlphaComponent(a)
            }
            return color
        }
        let hex = self.rawValue.components(separatedBy: "_").last
        if let strHex = hex, !strHex.contains("#") {
            if let a = alpha{
                return UIColor(hex: strHex, alpha: a, isDisplayP3: true)
            }
            return UIColor(hex: strHex, isDisplayP3: true)
        }
        if let a = alpha{
            return UIColor(hex: self.rawValue, alpha: a, isDisplayP3: true)
        }
        return UIColor(hex: self.rawValue, isDisplayP3: true)
    }
    
    /// Returns random generated color.
    static var random: UIColor {
        srandom(arc4random())
        var red: Double = 0
        while (red < 0.1 || red > 0.84) {
            red = drand48()
        }
        
        var green: Double = 0
        while (green < 0.1 || green > 0.84) {
            green = drand48()
        }
        
        var blue: Double = 0
        while (blue < 0.1 || blue > 0.84) {
            blue = drand48()
        }
        return UIColor(displayP3Red: CGFloat(red), green: CGFloat(green), blue: CGFloat(blue), alpha: 1.0)
    }
    
}

