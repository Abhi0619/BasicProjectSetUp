//
//  UIFontExtension.swift
//  FitFin
//
//  Created by MAC OS 13 on 07/12/21.
//

import Foundation
import UIKit

enum FontBook: String {
    //MARK:- Arial Font
    case Proxima_Nova_Black_Italic       = "ProximaNova-BlackIt"
    case Proxima_Nova_Black              = "ProximaNova-Black"
    case Proxima_Nova_Bold_Italic        = "ProximaNova-BoldIt"
    case Proxima_Nova_Bold               = "ProximaNova-Bold"
    case Proxima_Nova_Extrabold_Italic   = "ProximaNova-ExtrabldIt"
    case Proxima_Nova_Font_regular       = "ProximaNova-Regular"
    case Proxima_Nova_Light_Italic       = "ProximaNova-LightIt"
    case Proxima_Nova_Light              = "ProximaNova-Light"
    case Proxima_Nova_Regular_Italic     = "ProximaNova-RegularIt"
    case Proxima_Nova_Semibold_Italic    = "ProximaNova-SemiboldIt"
    case Proxima_Nova_Semibold           = "ProximaNova-Semibold"
    case Proxima_Nova_Thin_Italic        = "ProximaNova-ThinIt"
    case Proxima_Nova_Thin               = "ProximaNovaT-Thin"
        
    //MARK:- Method
    func of(_ size: CGFloat) -> UIFont {
        return UIFont(name: self.rawValue, size: size)!
    }
}
