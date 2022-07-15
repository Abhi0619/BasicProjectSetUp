//
//  RawdataConverter.swift
//  FitFin
//
//  Created by MAC OS 13 on 07/12/21.
//

import Foundation
import UIKit

class RawdataConverter: NSObject {
    /**
     Convert if timestamp to date else return current date
     */
    class func date(_ timestamp: Any?) -> Date {
        if let any = timestamp {
            if let str = any as? String {
                return Date(timeIntervalSince1970: RawdataConverter.double(str))
            } else if let str = any as? NSNumber {
                return Date(timeIntervalSince1970: str.doubleValue)
            }
        }
        return Date()
    }
    
    /**
     Convert if Any object is timestamp then retuen date else check yyyy-MM-dd HH:mm:ss formate match then return date else return nil
     */
    
    class func optionalDate(_ format: DateFormat,_ anything: Any?) -> Date? {
        if let any = anything {
            if let str = any as? String, !str.isEmpty {
                return stringFormatToDate(format, str)
            }else if let str = any as? NSNumber {
                return Date(timeIntervalSince1970: str.doubleValue)
            }
        }
        return nil
    }
    
    class func dateWithFormat(_ format: DateFormat,_ anything: Any?) -> Date {
        if let any = anything {
            if let str = any as? String, !str.isEmpty {
                return stringFormatToDate(format, str) ?? Date()
            }else if let str = any as? NSNumber {
                return Date(timeIntervalSince1970: str.doubleValue)
            }
        }
        return Date()
    }
    
//    class func optionalDate(_ anything: Any?) -> Date? {
//        if let any = anything {
//            if let str = any as? String, !str.isEmpty {
//                if str.contains("-") && str.contains(":") && str.contains("T") && str.contains("Z") {
//                    return Date.stringFormatted2ToDate(str)
//                }else if str.contains("-") && str.contains(":") && str.contains("T")  {
//                    return Date.stringFormatted5ToDate(str)
//                }else if str.contains("-") && str.contains(":") {
//                    return Date.stringFormatted1ToDate(str)
//                }else if str.contains("-") {
//                    return Date.stringFormatted3ToDate(str)
//                }else if !str.contains(":") {
//                    return Date(timeIntervalSince1970: RawdataConverter.double(str))
//                }
//            } else if let str = any as? NSNumber {
//                return Date(timeIntervalSince1970: str.doubleValue)
//            }
//        }
//        return nil
//    }
    /**
     Convert Any object to integer
     */
    class func integer(_ anything: Any?) -> Int {
        
        if let any = anything {
            if let num = any as? NSNumber {
                return num.intValue
            } else if let str = any as? NSString {
                return str.integerValue
            }
        }
        return 0
    }
    /**
     Convert if Any object is integer then return integer value else return nil
     */
    class func optionalInteger(_ anything: Any?) -> Int? {
        if let any = anything {
            if let num = any as? NSNumber {
                return num.intValue
            } else if let str = any as? String {
                if !str.isEmpty {
                    return (str as NSString).integerValue
                }
            }
        }
        return nil
    }
        /**
     Convert Any object to integer16
     */
    class func integer16(_ anything: Any?) -> Int16 {
        
        if let any = anything {
            if let num = any as? NSNumber {
                return num.int16Value
            } else if let str = any as? NSString {
                return Int16(str.intValue)
            }
        }
        return 0
    }
    
    /**
     Convert if Any object is integer16 then return integer16 value else return nil
     */
    class func optionalInteger16(_ anything: Any?) -> Int16? {
        if let any = anything {
            if let num = any as? NSNumber {
                return num.int16Value
            } else if let str = any as? String {
                if !str.isEmpty {
                    return Int16((str as NSString).intValue)
                }
            }
        }
        return nil
    }
    /**
     Convert Any object to int32
     */
    class func int32(_ anything: Any?) -> Int32 {
        if let any = anything {
            if let num = any as? NSNumber {
                return num.int32Value
            } else if let str = any as? NSString {
                return str.intValue
            }
        }
        return 0
    }
    /**
     Convert if Any object is int32 then return int32 value else return nil
     */
    class func optionalInt32(_ anything: Any?) -> Int32? {
        if let any = anything {
            if let num = any as? NSNumber {
                return num.int32Value
            } else if let str = any as? String {
                if !str.isEmpty {
                    return (str as NSString).intValue
                }
            }
        }
        return nil
    }
    
    /**
     Convert Any object to int64
     */
    class func int64(_ anything: Any?) -> Int64 {
        if let any = anything {
            if let num = any as? NSNumber {
                return num.int64Value
            } else if let str = any as? NSString {
                return str.longLongValue
            }
        }
        return 0
    }
    /**
     Convert if Any object is int64 then return int64 value else return nil
     */
    class func optionalInt64(_ anything: Any?) -> Int64? {
        if let any = anything {
            if let num = any as? NSNumber {
                return num.int64Value
            } else if let str = any as? String {
                if !str.isEmpty {
                    return (str as NSString).longLongValue
                }
            }
        }
        return nil
    }
    
    /**
     Convert Any object to uint64
     */
    class func uint64(_ anything: Any?) -> UInt64 {
        if let any = anything {
            if let num = any as? NSNumber {
                return num.uint64Value
            } else if let str = any as? NSString {
                return UInt64(str.doubleValue)
            }
        }
        return 0
    }
    /**
     Convert if Any object is uint64 then return int64 value else return nil
     */
    class func optionalUInt64(_ anything: Any?) -> UInt64? {
        if let any = anything {
            if let num = any as? NSNumber {
                return num.uint64Value
            } else if let str = any as? String {
                if !str.isEmpty {
                    return UInt64((str as NSString).doubleValue)
                }
            }
        }
        return nil
    }
    /**
     Convert Any object to double
     */
    class func double(_ anything: Any?) -> Double {
        if let any = anything {
            if let num = any as? NSNumber {
                return num.doubleValue
            } else if let str = any as? NSString {
                return str.doubleValue
            }
        }
        return 0
    }
    /**
     Convert if Any object is double then return double value else return nil
     */
    class func optionalDouble(_ anything: Any?) -> Double? {
        if let any = anything {
            if let num = any as? NSNumber {
                return num.doubleValue
            } else if let str = any as? String {
                if !str.isEmpty {
                    return (str as NSString).doubleValue
                }
            }
        }
        return nil
    }
    /**
     Convert Any object to float
     */
    class func float(_ anything: Any?) -> Float {
        if let any = anything {
            if let num = any as? NSNumber {
                return num.floatValue
            } else if let str = any as? NSString {
                return str.floatValue
            }
        }
        return 0
    }
    /**
     Convert if Any object is float then return float value else return nil
     */
    class func optionalFloat(_ anything: Any?) -> Float? {
        if let any = anything {
            if let num = any as? NSNumber {
                return num.floatValue
            } else if let str = any as? String {
                if !str.isEmpty {
                    return (str as NSString).floatValue
                }
            }
        }
        return nil
    }
    /**
     Convert Any object to string
     */
    class func string(_ anything: Any?) -> String {
        if let any = anything {
            if let num = any as? NSNumber {
                return num.stringValue
            } else if let str = any as? String {
                return str
            }
        }
        return ""
    }
    /**
     Convert if Any object is string then return string else return nil
     */
    class func optionalString(_ anything: Any?, isCheckEmpty isEmpty: Bool = true) -> String? {
        if let any = anything {
            if let num = any as? NSNumber {
                if isEmpty{
                    return num.stringValue.isEmpty ? nil : num.stringValue
                }
                return num.stringValue
            } else if let str = any as? String {
                if isEmpty{
                    return str.isEmpty ? nil : str
                }
                return str
            }
        }
        return nil
    }
    /**
     Convert if Any object is boolean then return boolean value else return false
     */
    class func boolean(_ anything: Any?) -> Bool {
        if let any = anything {
            if let num = any as? NSNumber {
                return num.boolValue
            } else if let str = any as? NSString {
                return str.boolValue
            }
        }
        return false
    }
    
    /**
        Convert if Any object is boolean then return boolean value else return false
        */
       class func optionalBoolean(_ anything: Any?) -> Bool? {
           if let any = anything {
               if let num = any as? NSNumber {
                   return num.boolValue
               } else if let str = any as? NSString {
                   return str.boolValue
               }
           }
           return nil
       }
    /**
     Convert if Any object is data type dictionary and also is not empty then return dictionary else return nil
     */
    class func dictionary(_ anything: Any?) -> [String:Any]? {
        if let any = anything {
            if let dict = any as? [String:Any] {
                return !dict.isEmpty ? dict : nil
            }
        }
        return nil
    }
    /**
     Convert if Any object is data type array and is also is not empty then return array else return nil
     */
    class func array(_ anything: Any?) -> [Any]? {
        if let any = anything {
            if let arr = any as? [Any] {
                return !arr.isEmpty ? arr : nil
            }
        }
        
        return nil
    }
    
    
    /**
     Convert any object to Json formate string if any error occurs then return empty string
     */
    class func toJsonString(fromAny parm : Any) -> String{
        do{
            let jsonData: Data = try JSONSerialization.data(withJSONObject: parm, options: JSONSerialization.WritingOptions.prettyPrinted)
            if let datastring = String(data: jsonData, encoding: String.Encoding.utf8){
                return datastring
            }
        } catch let error {
            jprint("toJsonString ERROR :\(error.localizedDescription)")
        }
        return  ""
    }
    /**
     Convert JSON String to Any if any error occurs then return nil
     */
    class func toAny(fromJson text: String) -> Any? {
        if let data = text.data(using: .utf8) {
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
                return json
            }  catch let error{
                jprint("jsonStringToAny ERROR :\(error.localizedDescription)")
            }
        }
        return nil
    }
    
}

//MARK: - Date Related
extension RawdataConverter {
    
    static func dateFormatter(format: DateFormat) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.timeZone = TimeZone(secondsFromGMT: 0) // UTC
        formatter.dateFormat = format.rawValue
        return formatter
    }

    static func formatedDateToString(_ format: DateFormat, date: Date) -> String {
        return dateFormatter(format: format).string(from: date)
    }
    
    static func stringFormatToDate(_ format: DateFormat,_ date: String) -> Foundation.Date? {
        return dateFormatter(format: format).date(from: date)
    }
    
    static func dateToString(_ format: DateFormat, date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format.rawValue
        formatter.timeZone = TimeZone(secondsFromGMT: 0) //UTC
        formatter.locale = Locale(identifier: "en_US")
        return formatter.string(from: date)
    }
    
    /**
    Convert date to fromated string in Device time zone (Local Time)
    Ex. yyy-MM-dd -> 1999-03-01 etc
    */
    static func localDateToString(_ format: DateFormat, date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format.rawValue
        formatter.locale = Locale(identifier: "en_US")
        formatter.timeZone = TimeZone.current
        return formatter.string(from: date)
    }
    
    /**
     Convert device timezone date to fromated string in UTC timezone
     Ex. yyy-MM-dd -> 1999-03-01 etc
     */
    static func localDateToServerTimeZone(_ format: DateFormat, date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format.rawValue
        formatter.timeZone = TimeZone(secondsFromGMT: 0) // UTC
        formatter.locale = Locale(identifier: "en_US")
        return formatter.string(from: date)
    }
    
    class func toCount(formate countInt: Int) -> String {
        var float : Double = 0.0
        var integer : Double = 0.0
        var count = "\(countInt)"
        let cnt = Double(countInt)
        if cnt > 999 && cnt < 999999 {
            float = cnt/1000.0
            let fr = Int(modf(float, &integer) * 100)
            if fr > 0 {
                count = String(format: "%.02f", float)
            } else {
                count = "\(Int(integer))"
            }
            count  += "K"
        } else if cnt > 999999  && cnt<999999999{
            float = cnt/1000000.0
            let fr = Int(modf(float, &integer) * 100)
            if fr > 0 {
                count = String(format: "%.02f", float)
            } else {
                count = "\(Int(integer))"
            }
            count  += "M"
        } else if cnt > 999999999  {
            float = cnt/1000000000.0
            let fr = Int(modf(float, &integer) * 100)
            if fr > 0 {
                count = String(format: "%.02f", float)
            } else {
                count = "\(Int(integer))"
            }
            count  += "B"
            
        }
        
        return count
    }
    
    class func toTimeAgo(since date: Date) -> String {
        
        let calendar = Calendar.current
        let now = Date()
        let unitFlags = Set<Calendar.Component>([.second, .minute, .hour, .day, .weekOfMonth, .month, .year])
        let components = calendar.dateComponents(unitFlags, from: date,  to: now)
        if let val = components.year, val > 0 {
            return  "\(val) year\(val == 1 ? "":"s") ago"
        }
        if let val = components.month , val > 0{
            return  "\(val) month\(val == 1 ? "":"s") ago"
        }
        if let val = components.weekOfMonth, val > 0 {
            return  "\(val) week\(val == 1 ? "":"s") ago"
        }
        if let val = components.day, val > 0 {
            return  "\(val) day\(val == 1 ? "":"s") ago"
        }
        if let val = components.hour, val > 0 {
            return  "\(val) hr\(val == 1 ? "":"s") ago"
        }
        if let val = components.minute, val > 0 {
            return  "\(val) min\(val == 1 ? "":"s") ago"
        }
        if let val = components.second, val > 0{
            return  "\(val) sec\(val == 1 ? "":"s") ago"
        }
        return "Just now"

    }
    
    
}


// MARK: Paging Structure
struct LoadMoreSpecific {
    var loadingIndex: Int = 1
    
    var totalRecord: Int = 0
    var maxLoad: Int = 100
    var lastIndex: Int?
    var isLoading: Bool = false
    var allRecordLoaded: Bool = false
    var isOneTimeScroll = false
    var isFirstTime: Bool = true
 
    var offset: String {
        get {
            if let index = lastIndex{
                return "\(loadingIndex - index)"
            }
            return "\(loadingIndex)"
        }
    }
    
    var limit : String {
        get {
            return "\(maxLoad)"
        }
    }
    
    init(limit: Int = 100){
        maxLoad = limit
    }
}
