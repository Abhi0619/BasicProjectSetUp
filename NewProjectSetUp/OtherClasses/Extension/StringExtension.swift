//
//  StringExtension.swift
//  FitFin
//
//  Created by MAC OS 13 on 07/12/21.
//

import Foundation
import UIKit
import MobileCoreServices

//MARK: - Localizable
extension String {
    
    func localized(lang: String? = nil) ->String {
        let langType = RawdataConverter.string(_userDefault.value(forKey: UserdefaultKeyList.selectedLanguage.rawValue))
        let path = Bundle.main.path(forResource: lang ?? langType, ofType: "lproj")
        let bundle = Bundle(path: path!)
        return NSLocalizedString(self, tableName: nil, bundle: bundle!, value: "", comment: "")
    }
        
    func localizeWithFormat(arguments: CVarArg...) -> String{
        return String(format: self.localized(), arguments: arguments)
    }
    
    //USE:-
    //    let localizedText = "LTo use Siri with my app, please set %@ as the default list on your device reminders settings".localizeWithFormat(arguments: siriCalendarTitle)
}

//MARK: - HTML Formatter
extension String {
    var htmlToAttributedString: NSAttributedString? {
        guard let data = data(using: .utf8) else { return NSAttributedString() }
        do {
            return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding:String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            return NSAttributedString()
        }
    }
    var htmlToString: String {
        return htmlToAttributedString?.string ?? ""
    }
}

// MARK: - Layout
extension String {
    
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        let options: NSStringDrawingOptions = [NSStringDrawingOptions.usesLineFragmentOrigin, NSStringDrawingOptions.usesFontLeading ]
        
        let boundingBox = self.boundingRect(with: constraintRect, options: options, attributes: [NSAttributedString.Key.font: font], context: nil)
        return boundingBox.height
    }
    
    func width(withNoConstrainedHeight font: UIFont) -> CGFloat {
        let width = CGFloat(999)
        let options: NSStringDrawingOptions = [NSStringDrawingOptions.usesLineFragmentOrigin, NSStringDrawingOptions.usesFontLeading ]
        let constraintRect = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: options, attributes: [NSAttributedString.Key.font: font], context: nil)
        return boundingBox.width
    }
    
    func getAttributeString(_ font:UIFont,color:UIColor) ->  NSMutableAttributedString {
        let mutatingAttributedString = NSMutableAttributedString(string: self)
        mutatingAttributedString.addAttribute(NSAttributedString.Key.font, value: font, range: NSMakeRange(0, self.count))
        mutatingAttributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: NSMakeRange(0, self.count))
        return mutatingAttributedString
    }
    // GET File FilenameExtension
    func getFilenameExtension() -> String?{
        if let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, self as CFString, nil)?.takeRetainedValue() {
            if let type = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassFilenameExtension)?.takeRetainedValue() {
                return type as String
            }
        }
        return nil
    }
    // GET File MimeType
    func getFileMimeType() -> String{
        if let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, self as CFString, nil)?.takeRetainedValue() {
            if let type = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType)?.takeRetainedValue() as String? {
                return type
            }
        }
        return "application/octet-stream"
    }
}

extension String {
    
    func trim() -> String{
        let strTrimmed = (NSString(string:self)).trimmingCharacters(in: CharacterSet.whitespaces)
        return strTrimmed
    }
    
    // Mobile Validation
    func isMobileNumer(str : String) -> Bool{
        let aSet = NSCharacterSet(charactersIn:"0123456789").inverted
        let compSepByCharInSet = str.components(separatedBy: aSet)
        let numberFiltered = compSepByCharInSet.joined(separator: "")
        return str == numberFiltered
    }
    
    // Mobile Validation
    func isMobile() -> Bool{
        let PHONE_REGEX = "^\\d{10}$"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", PHONE_REGEX)
        let result =  phoneTest.evaluate(with: self)
        return result
    }
    
    //Email Validation
    func isEmailAddress() -> Bool {
        // print("validate calendar: \(testStr)")
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: self)
    }
}


// MARK: - Character check
extension String {
    func isEqual(str: String) -> Bool {
        if self.compare(str) == ComparisonResult.orderedSame{
            return true
        }else{
            return false
        }
    }
    func trimming() -> String {
        return self.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
    }
    
    func replaceSpace() -> String {
        return self.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
    }
    
    func trimming(newLine: Bool = false) -> String {
        if newLine {
            return trimmingCharacters(in: .whitespacesAndNewlines)
        }else{
            return trimmingCharacters(in: .whitespaces)
        }
    }
    func contains(find: String) -> Bool{
        return self.range(of: find, options: String.CompareOptions.caseInsensitive) != nil
    }
    
    func trimWhiteSpace(newline: Bool = false) -> String {
        if newline {
            return self.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
        } else {
            return self.trimmingCharacters(in: NSCharacterSet.whitespaces)
        }
    }
}

// MARK: - String Validations
extension String {
    
    static func validate(value:String?) -> Bool {
        var strNew = ""
        if value != nil{
            strNew = value!.trimWhiteSpace(newline: true)
        }
        if value == nil || strNew == "" || strNew.count == 0  {  return true  } else  {  return false  }
    }
    
    static func isValidPasswordOld(_ str:String?) -> Bool{
        if str == nil || str == "" || str!.count < 8  {  return true  } else  {  return false  }
    }
    
    var isEmailAddressValid: Bool {
        let emailRegex = "^[_A-Za-z0-9-\\+]+(\\.[_A-Za-z0-9-]+)*@[A-Za-z0-9-]+(\\.[A-Za-z0-9]+)*(\\.[A-Za-z]{2,})$*(\\s?)"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: self)
    }
    
    var isUserNameValid: Bool {
        let cs = NSCharacterSet(charactersIn: "kAcceptableCharacters").inverted
        let filtered = components(separatedBy: cs).joined(separator: "")
        return !trimming(newLine: true).isEmpty && trimming(newLine: true).count > 2 && trimming(newLine: true).count < 20 && self == filtered
    }
    
    var isContactValid: Bool {
        let contactRegEx = "^[0-9]{6,14}$"
        let contactTest = NSPredicate(format:"SELF MATCHES %@", contactRegEx)
        return contactTest.evaluate(with: self)
    }
    
    var isNumOfUserValid: Bool {
        let contactRegEx = "^[0-9]{1,4}$"
        let contactTest = NSPredicate(format:"SELF MATCHES %@", contactRegEx)
        return contactTest.evaluate(with: self)
    }
    
    var isOtpVerified: Bool {
        if trimming(newLine: true).isEmpty {
            return false
        }else{
            return self.count >= 6
        }
    }
    
    var isPasswordValid: Bool {
        if trimming(newLine: true).isEmpty {
            return false
        }else{
            return self.count >= 6
        }
    }
    
    var isValidUrl: Bool {
        let urlRegEx = "^(https?://)?([-a-z0-9]{1,63}\\.)*?[a-z0-9][-a-z0-9]{0,61}[a-z0-9]\\.[a-z]{2,6}(/[-\\w@\\+\\.~#\\?&/=%]*)?$"
        let urlTest = NSPredicate(format:"SELF MATCHES %@", urlRegEx)
        return urlTest.evaluate(with: self)
        
    }
    static let decimalFormatterBool: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.allowsFloats = true
        formatter.locale = Locale(identifier: "en_US")
        return formatter
    }()
    
    private var decimalSeparator: String{
        return String.decimalFormatterBool.decimalSeparator ?? "."
    }
    
//    func displayPriceFormate(_ checkIsEmpty: Bool = true) -> String{
//        var text = self.trimming()
//        text = text.replacingOccurrences(of: "$", with: "")
//        text = text.replacingOccurrences(of: ",", with: "")
//        if checkIsEmpty && text.isEmpty {
//            return ""
//        }
//        let num = NSNumber(value: RawdataConverter.double(text))
//        return num.currencySymbol_formatted1
//    }
    
}
