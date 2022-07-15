//
//  ImpExtentions.swift
//  FitFin
//
//  Created by MAC OS 13 on 07/12/21.
//

import Foundation
import UIKit
import MobileCoreServices
import Photos
import SDWebImage

// MARK: - AP SET IMAGE
extension UIImageView {

    func ap_setImage(withURL url: URL?, placeholderImage: UIImage? = nil,
                     completionHandler: (()->())? = nil) {
        self.sd_setImage(with: url, placeholderImage: placeholderImage)
    }

//    static func ap_downloadImage(withURL url: URL,
//                                 completion: (() -> ())? = nil){
////        let token: String = "" //_loggedUser?.token ?? ""
////
////        let modifier = AnyModifier { request in
////            var r = request
////            r.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
////            return r
////        }
//
//        ImageDownloader.default.downloadImage(with: url, options: [.transition(.fade(0.25))], progressBlock: nil, completionHandler: completion)
//    }

}



// MARK: - Make a section array
extension UILocalizedIndexedCollation {
    //func for partition array in sections
    func partitionObjects(array:[AnyObject], collationStringSelector:Selector, sort: Bool = false) -> ([AnyObject], [String]) {
        var unsortedSections = [[AnyObject]]()
        //1. Create a array to hold the data for each section
        for _ in self.sectionTitles {
            unsortedSections.append([]) //appending an empty array
        }
        //2. Put each objects into a section
        for item in array {
            let index:Int = self.section(for: item, collationStringSelector:collationStringSelector)
            unsortedSections[index].append(item)
        }
        //3. sorting the array of each sections
        let sectionTitles = self.sectionTitles
        var sections = [AnyObject]()
        for index in 0 ..< unsortedSections.count {
            //            if unsortedSections[index].count > 0 {
            ////            sectionTitles.append(self.sectionTitles[index])
            //            sections.append(self.sortedArray(from: unsortedSections[index], collationStringSelector: collationStringSelector) as AnyObject)
            //            }
            if sort{
                sections.append(self.sortedArray(from: unsortedSections[index], collationStringSelector: collationStringSelector) as AnyObject)
            }else{
                sections.append(unsortedSections[index] as AnyObject)
            }
        }
        return (sections, sectionTitles)
    }
}

//MARK: - Data
extension Data {
    func hexString() -> String {
        return self.reduce("") { string, byte in
            string + String(format: "%02X", byte)
        }
    }
    func sizeString(units: ByteCountFormatter.Units = [.useAll], countStyle: ByteCountFormatter.CountStyle = .file) -> String {
        let bcf = ByteCountFormatter()
        bcf.allowedUnits = units
        bcf.countStyle = .file
        return bcf.string(fromByteCount: Int64(count))
    }
}

//MARK: - URL
extension URL{
    var attributes: [FileAttributeKey : Any]? {
        do {
            return try FileManager.default.attributesOfItem(atPath: path)
        } catch let error as NSError {
            print("FileAttribute error: \(error)")
        }
        return nil
    }
    
    var fileSize: UInt64 {
        return attributes?[.size] as? UInt64 ?? UInt64(0)
    }
    
    var creationDate: Date? {
        return attributes?[.creationDate] as? Date
    }
    // GET File MimeType
    func getFileMimeType() -> String{
        if let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, self.pathExtension as CFString, nil)?.takeRetainedValue() {
            if let type = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType)?.takeRetainedValue() as String? {
                return type
            }
        }
        return "application/octet-stream"
    }
    
}

extension UINavigationController {
    func popToViewController(ofClass: AnyClass, animated: Bool = true) {
        if let vc = viewControllers.last(where: { $0.isKind(of: ofClass) }) {
            popToViewController(vc, animated: animated)
        }
    }
}

//MARK: - UILabel
extension UILabel {
    
    // This will give combined string with respective attributes
    func setAttributed(texts: [String], attributes: [[NSAttributedString.Key : Any]]) {
        let attbStr = NSMutableAttributedString()
        for (index,element) in texts.enumerated() {
            attbStr.append(NSAttributedString(string: element, attributes: attributes[index]))
        }
        attributedText = attbStr
    }
    func addCharactersSpacing(spacing: CGFloat, text: String, range: NSRange) {
        let attributedString = NSMutableAttributedString(string: text)
        attributedString.addAttribute(NSAttributedString.Key.kern, value: spacing, range: range)
        self.attributedText = attributedString
    }
}

//MARK: - UIAlertController

extension UIAlertController {
    class func actionWithMessage(message: String? = nil, title: String? = nil, cancelBtnTitle: String = "Cancel", type: UIAlertController.Style, buttons: [String] = [], btnStyle: [UIAlertAction.Style] = [], controller: UIViewController, tintColor: UIColor? = nil, block: ((_ tapped: String)->())? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: type)
        for (idx, btn) in buttons.enumerated() {
            var style = UIAlertAction.Style.default
            if !btnStyle.isEmpty, idx < btnStyle.count {
                style = btnStyle[idx]
            }
            alert.addAction(UIAlertAction(title: btn, style: style, handler: { (action) -> Void in
                block?(action.title ?? "")
            }))
        }
        alert.addAction(UIAlertAction(title: cancelBtnTitle, style: UIAlertAction.Style.cancel, handler: { (action) -> Void in
            
            block?(action.title ?? "")
        }))
        if let color = tintColor {
            alert.view.tintColor = color
        }
        DispatchQueue.main.async {
            controller.present(alert, animated: true, completion: nil)
        }
    }
    
    static func actionWithMessageDestructive(message: String?, title: String?, cancelBtnTitle: String = "Cancel", type: UIAlertController.Style, buttons: [String], controller: UIViewController ,block:@escaping (_ tapped: String)->()) {
           let alert = UIAlertController(title: title, message: message, preferredStyle: type)
           for btn in buttons {
               alert.addAction(UIAlertAction(title: btn, style: UIAlertAction.Style.destructive, handler: { (action) -> Void in
                   block(action.title ?? "")
               }))
           }
           alert.addAction(UIAlertAction(title: cancelBtnTitle, style: UIAlertAction.Style.cancel, handler: { (action) -> Void in
               block(action.title ?? "")
           }))
             DispatchQueue.main.async {
           controller.present(alert, animated: true, completion: nil)
           }
       }
    
}

//MARK: - IndexPath

extension IndexPath {
    // Return IndexPath
    static func indexPathForTblCell(atView view: UIView, inTableView tableView: UITableView) -> IndexPath? {
        let cpt = tableView.convert(CGPoint(x: view.bounds.midX, y: view.bounds.midY), from:view)
        return tableView.indexPathForRow(at: cpt)
    }
    
    
    static func indexPathForColCell(atView view: UIView, inCollectionView collectionView: UICollectionView) -> IndexPath? {
        let cpt = collectionView.convert(CGPoint(x: view.bounds.midX, y: view.bounds.midY), from:view)
        return collectionView.indexPathForItem(at: cpt)
    }
}


extension UITableView {
    
    func scrollToBottom(){
        
        DispatchQueue.main.async {
            let indexPath = IndexPath(
                row: self.numberOfRows(inSection:  self.numberOfSections - 1) - 1,
                section: self.numberOfSections - 1)
            self.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }
    
    func scrollToSection(section: Int) {
        DispatchQueue.main.async {
            let indexPath = IndexPath(
                row: self.numberOfRows(inSection:  self.numberOfSections - 1) - 1,
                section: section)
            self.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }
    
    
    func scrollToTop() {
        
        DispatchQueue.main.async {
            let indexPath = IndexPath(row: 0, section: 0)
            self.scrollToRow(at: indexPath, at: .top, animated: false)
        }
    }
}

// MARK: - UITextField
extension UITextField {
    
    // This will give combined string with respective attributes
    func setAttributed(placeholder texts: [String], attributes: [[NSAttributedString.Key : Any]]) {
        let attbStr = NSMutableAttributedString()
        for (index,element) in texts.enumerated() {
            attbStr.append(NSAttributedString(string: element, attributes: attributes[index]))
        }
        attributedPlaceholder = attbStr
    }
    
    func addCharactersSpacing(spacing: CGFloat, text: String, range: NSRange) {
        let attributedString = NSMutableAttributedString(string: text)
        attributedString.addAttribute(NSAttributedString.Key.kern, value: spacing, range: range)
        self.attributedText = attributedString
    }
}

//MARK: - NSAttributedString
extension NSAttributedString {
    
    func height(withConstrainedWidth width: CGFloat = CGFloat.greatestFiniteMagnitude) -> CGFloat {
        let constraintRect = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: [NSStringDrawingOptions.usesLineFragmentOrigin, NSStringDrawingOptions.usesFontLeading], context: nil)
        return ceil(boundingBox.height)
    }
    func width(_ height: CGFloat = CGFloat.greatestFiniteMagnitude) -> CGFloat {
        let constraintRect = CGSize(width: CGFloat.greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: [NSStringDrawingOptions.usesLineFragmentOrigin, NSStringDrawingOptions.usesFontLeading], context: nil)
        return ceil(boundingBox.width)
    }
    
    // This will give combined string with respective attributes
    class func attributedText(texts: [String], attributes: [[NSAttributedString.Key : Any]]) -> NSMutableAttributedString {
        let attbStr = NSMutableAttributedString()
        for (index,element) in texts.enumerated() {
            attbStr.append(NSAttributedString(string: element, attributes: attributes[index]))
        }
        return attbStr
    }
    class func attributedText(fullText: String, texts: [String] = [], attributes: [NSAttributedString.Key : Any], textAttributes: [NSAttributedString.Key : Any]) -> NSMutableAttributedString {
        let attribute =  NSMutableAttributedString(string: fullText, attributes: attributes)
        for element in texts {
            let rangeOfTitle = (fullText as NSString).range(of: element)
            attribute.addAttributes(textAttributes, range: rangeOfTitle)
        }
        return attribute
    }
}

//MARK: - Dictionary

extension Dictionary {
    
    mutating func merge(with dictionary: Dictionary) {
        dictionary.forEach { updateValue($1, forKey: $0) }
    }
    
    func merged(with dictionary: Dictionary) -> Dictionary {
        var dict = self
        dict.merge(with: dictionary)
        return dict
    }
}

//MARK: - Array
extension Array where Element: Equatable {
    
    mutating func remove(object: Element) {
        if let index = firstIndex(of: object) {
            remove(at: index)
        }
    }
    
    mutating func replace(object: Element, toObject: Element) {
        if let index = firstIndex(of: object) {
            self[index] = toObject
        }
    }
    mutating func removeObjectsInArray(array: [Element]) {
        for object in array {
            remove(object: object)
        }
    }
}

extension Array where Element: Hashable {
    func difference(from other: [Element]) -> [Element] {
        let thisSet = Set(self)
        let otherSet = Set(other)
        return Array(thisSet.symmetricDifference(otherSet))
    }
}

// MARK: - UIView
extension UIView {
    
    func roundCorners(_ corners:UIRectCorner,_ cornerMask: CACornerMask?, radius: CGFloat) {
        self.layer.masksToBounds = radius > 0
        if let _ =  cornerMask, #available(iOS 11.0, *){
            self.layer.cornerRadius = radius
            self.layer.maskedCorners = cornerMask!
        }else{
            let rectShape = CAShapeLayer()
            rectShape.bounds = self.frame
            rectShape.position = self.center
            rectShape.path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius)).cgPath
            self.layer.mask = rectShape
        }
    }
    
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
}


// MARK: - Constraint
extension NSLayoutConstraint {
    func applyMultiplier(with multiplier: CGFloat) -> NSLayoutConstraint {
        return NSLayoutConstraint(item: self.firstItem!, attribute: self.firstAttribute, relatedBy: self.relation, toItem: self.secondItem, attribute: self.secondAttribute, multiplier: multiplier, constant: self.constant)
    }
}

// MARK: - PHAsset
extension PHAsset {
    func getAssetThumbnail(_ targetSize: CGSize = CGSize(width: 100.0, height: 100.0)) -> UIImage {
        let manager = PHImageManager.default()
        let option = PHImageRequestOptions()
        var thumbnail = UIImage()
        option.isSynchronous = true
        manager.requestImage(for: self, targetSize: targetSize, contentMode: .default, options: option, resultHandler: { (result, info)-> Void in
            thumbnail = result!
        })
        return thumbnail
    }
    
}

extension UIApplication {

    class func getTopViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        
        if let nav = base as? UINavigationController {
            return getTopViewController(base: nav.visibleViewController)
            
        } else if let tab = base as? UITabBarController, let selected = tab.selectedViewController {
            return getTopViewController(base: selected)
            
        } else if let presented = base?.presentedViewController {
            return getTopViewController(base: presented)
        }
        return base
        
        /*
         USAGE
         if let topVC = UIApplication.getTopViewController() {
            topVC.view.addSubview(forgotPwdView)
         }
         */
        
    }
    
    class func topViewController(_ viewController: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let nav = viewController as? UINavigationController {
            return topViewController(nav.visibleViewController)
        }
        if let tab = viewController as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(selected)
            }
        }
        if let presented = viewController?.presentedViewController {
            return topViewController(presented)
        }
        return viewController
    }

    class func topNavigation(_ viewController: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UINavigationController? {

        if let nav = viewController as? UINavigationController {
            return nav
        }
        if let tab = viewController as? UITabBarController {
            if let selected = tab.selectedViewController {
                return selected.navigationController
            }
        }
        return viewController?.navigationController
    }
}


extension UIImage {
    enum JPEGQuality: CGFloat {
        case lowest  = 0
        case low     = 0.25
        case medium  = 0.6
        case high    = 0.75
        case highest = 1
    }
    
    func jpeg(_ jpegQuality: JPEGQuality) -> Data? {
        return jpegData(compressionQuality: jpegQuality.rawValue)
    }
}

extension UIImageView {
  func setImageColor(color: UIColor) {
    let templateImage = self.image?.withRenderingMode(.alwaysTemplate)
    self.image = templateImage
    self.tintColor = color
  }
}
