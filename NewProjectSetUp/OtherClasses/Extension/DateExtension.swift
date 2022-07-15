//
//  DateExtension.swift
//  FitFin
//
//  Created by MAC OS 13 on 07/12/21.
//

import Foundation
import UIKit

enum DateFormat: String  {
    
    case EEEEMMMdyyyy = "EEEE, MMM d, yyyy"  //Tuesday, Apr 7, 2020
    case MMddyyyy = "MM/dd/yyyy" //04/07/2020
    case MMddyyyyHHmm = "MM-dd-yyyy HH:mm" //04-07-2020 05:25
    case MMMdhmma = "MMM d, h:mm a" // Apr 7, 5:25 AM
    case MMMMyyyy = "MMMM yyyy" //April 2020
    case MMMdyyyy = "MMM d, yyyy" //Apr 7, 2020
    case ddmmyyyy = "dd-MM-yyyy"
    case yyyyMMddHHmmss = "yyyy-MM-dd HH:mm:ss"
    case temp = "YYYY-MM-DD HH:MM:SSZ"
    case yyyyMMdd = "yyyy-MM-dd"
    case HHmmss = "HH:mm:ss"
    case yyyyMMddTHHmmss = "yyyy-MM-dd'T'HH:mm:ss"
    case yyyyMMddTHHmmssSSSZ = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
    case ddMMyyHHmma = "dd/MM/yy, h:mm a" //"6/1/20, 10:32PM"
    case dMMMyy = "d MMM yy" //6 JAN 20
    case hmma = "h:mm a" //10:32 PM
    case MMM = "MMM"
}


extension Foundation.Date {
    var day_suffix: String {
        let day = Calendar.current.component(.day, from: self)
        switch day {
        case 1,21,31:
            return "st"
        case 2,22:
            return "nd"
        case 3,23:
            return "rd"
        default:
            return "th"
        }
    }

    /**
     Convert date to fromated string in UTC
     Ex. yyy-MM-dd -> 1999-03-01 etc
     */
    func dateToString(_ format: String = "yyyy-MM-dd") -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.timeZone = TimeZone(secondsFromGMT: 0) //UTC
        formatter.locale = Locale(identifier: "en_US")
        return formatter.string(from: self)
    }
    
    
    func getDaySuffix()-> String {
        let calendar = Calendar.current
        
        let day = calendar.component(.day, from: self)
        switch day {
        case 11...13: return "th"
        default:
            switch day % 10 {
            case 1: return "st"
            case 2: return "nd"
            case 3: return "rd"
            default: return "th"
            }
        }
    }
    
    /**
     Convert date to fromated string in Device time zone (Local Time)
     Ex. yyy-MM-dd -> 1999-03-01 etc
     */
    func localDateToString(_ format: String = "yyyy-MM-dd") -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.locale = Locale(identifier: "en_US")
        formatter.timeZone = TimeZone.current
        
        return formatter.string(from: self)
    }
    
    /**
     Convert device timezone date to fromated string in UTC timezone
     Ex. yyy-MM-dd -> 1999-03-01 etc
     */
    func localDateToServerTimeZone(_ format: String = "yyyy-MM-dd") -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.timeZone = TimeZone(secondsFromGMT: 0) // UTC
        formatter.locale = Locale(identifier: "en_US")
        return formatter.string(from: self)
    }
    
    /**
     Convert string date to fromated string in UTC timezone
     */
    static func stringWith(dateFormate format: String, fromDate date: String) -> Foundation.Date {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.locale = Locale(identifier: "en_US")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter.date(from: date)!
    }
    
    /**
        Convert string date to fromated string in UTC timezone
        */
    static func stringWith(dateFormate format: String, fromDate date: String, abbreviation: String? = nil) -> Foundation.Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.locale = Locale(identifier: "en_US")
        if let abbreviation = abbreviation, !abbreviation.isEmpty {
            formatter.timeZone = TimeZone(abbreviation: abbreviation)
        }else{
            formatter.timeZone = TimeZone(secondsFromGMT: 0)
        }
        return formatter.date(from: date)
       }
    /**
     Convert timestamp(Double) to date
     */
    static func getOnlyIntervalSinceDate(_ timestamp: Double) -> Foundation.Date{
        let dateFromServer = Foundation.Date(timeIntervalSince1970: timestamp)
        return dateFromServer
    }
    
    /**
     get months list with localized names
     */
    static func getMonthList() -> [String]{
        let formatter  = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.timeZone = TimeZone.current
        
        var months: [String] = []
        
        for month in 0...11 {
            if let monthSymbols = formatter.monthSymbols{
                months.append(monthSymbols[month].capitalized)
            }
        }
        return months
    }
    /**
     get year list from 1970 to given date year
     */
    func getYearList() -> [String]{
        var years: [String] = []
        let year =  RawdataConverter.integer(self.localDateToString("yyyy"))
        if year > 1970{
            for idx in 1970...year {
                years.append("\(idx)")
            }
        }
        return years
    }
    
    func addAfter(component: Calendar.Component, value: Int) -> Foundation.Date? {
        return Calendar.current.date(byAdding: component, value: value, to: self)
    }
}

extension Date {
//    var age: Int { Calendar.current.dateComponents([.year], from: self, to: Date()).year! }
    
    
    
    //USE
    //let age = dob.age
}


extension Date {

    //An integer representation of age from the date object (read-only).
    var age: Int {
        get {
            let now = Date()
            let calendar = Calendar.current

            let ageComponents = calendar.dateComponents([.year], from: self, to: now)
            let age = ageComponents.year!
            return age
        }
    }

    init(year: Int, month: Int, day: Int) {
        var dc = DateComponents()
        dc.year = year
        dc.month = month
        dc.day = day

        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        if let date = calendar.date(from: dc) {
            self.init(timeInterval: 0, since: date)
        } else {
            fatalError("Date component values were invalid.")
        }
    }

}

extension Date {
    mutating func changeDays(by days: Int) {
        self = Calendar.current.date(byAdding: .day, value: days, to: self)!
    }
}
