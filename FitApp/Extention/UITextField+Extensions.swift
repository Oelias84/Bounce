//
//  UITextField+Extensions.swift
//  FitApp
//
//  Created by iOS Bthere on 08/12/2020.
//

import UIKit


extension UITextField {
        
    private func configurePicker() -> UIDatePicker {
        let picker = UIDatePicker()
        picker.backgroundColor = .white
        picker.addTarget(self, action: #selector(pickerChanged(_:)), for: .valueChanged)
        picker.timeZone = .current
        return picker
    }
    
    func setupDatePicker(){
        let picker = configurePicker()
        picker.datePickerMode = .date
        if #available(iOS 13.4, *) {
            picker.preferredDatePickerStyle = .wheels
            picker.sizeToFit()
        }
        if let textFieldTime = self.text?.timeFromString {
            picker.date = textFieldTime
        }
        picker.datePickerMode = UIDatePicker.Mode.date
        picker.backgroundColor = .white
        self.inputView = picker
    }

    
    @objc private func pickerChanged(_ sender: UIDatePicker){
        switch sender.datePickerMode {
        case .time:
            self.text = sender.date.timeString
        case .dateAndTime:
            self.text = sender.date.fullDateString
        default:
            self.text = sender.date.dateStringDisplay
        }
    }
}
