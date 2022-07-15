//
//  DatePickerViewController.swift
//  Shippers
//

import Foundation
import UIKit

extension UIAlertController {
    
    /// Add a date picker
    ///
    /// - Parameters:
    ///   - mode: date picker mode
    ///   - date: selected date of date picker
    ///   - minimumDate: minimum date of date picker
    ///   - maximumDate: maximum date of date picker
    ///   - action: an action for datePicker value change
    
    func addDatePicker(mode: UIDatePicker.Mode, date: Date?, minimumDate: Date? = nil, maximumDate: Date? = nil, isInline: Bool = false, action: DatePickerViewController.Action?) {
        let datePicker = DatePickerViewController(mode: mode, date: date, minimumDate: minimumDate, maximumDate: maximumDate, isInline: isInline ,action: action)
        set(vc: datePicker, height: isInline ? 400 : 175)
    }

}

class DatePickerViewController: UIViewController {
    
    public typealias Action = (Date) -> Void
    
    fileprivate var action: Action?
    
    fileprivate lazy var datePicker: UIDatePicker = { [unowned self] in
        $0.addTarget(self, action: #selector(DatePickerViewController.actionForDatePicker), for: .valueChanged)
        return $0
        }(UIDatePicker())
    
    required init(mode: UIDatePicker.Mode, date: Date? = nil, minimumDate: Date? = nil, maximumDate: Date? = nil, isInline: Bool = false ,action: Action?) {
        super.init(nibName: nil, bundle: nil)
        datePicker.datePickerMode = mode
        datePicker.date = date ?? Date()
        datePicker.minimumDate = minimumDate
        datePicker.maximumDate = maximumDate
        if #available(iOS 13.4, *) {
            if isInline == true {
                if #available(iOS 14.0, *) {
                    datePicker.preferredDatePickerStyle = .inline
                }else{
                    datePicker.preferredDatePickerStyle = .compact
                }
            }else{
                datePicker.preferredDatePickerStyle = .wheels
            }
        } else {
            // Fallback on earlier versions
        }

        self.action = action
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        jprint("Deallocated: \(self.classForCoder)")
    }
    
    override func loadView() {
        view = datePicker
    }
    
    @objc func actionForDatePicker() {
        action?(datePicker.date)
    }
    
    public func setDate(_ date: Date) {
        datePicker.setDate(date, animated: true)
    }
}


// USE

/*
 let alert = UIAlertController(style: self.alertStyle, title: "Date Picker", message: "Select Date")
 alert.addDatePicker(mode: .dateAndTime, date: Date(), minimumDate: nil, maximumDate: nil) { date in
 print(date)
 }
 alert.addAction(title: "Done", style: .cancel)
 alert.show()
 */
