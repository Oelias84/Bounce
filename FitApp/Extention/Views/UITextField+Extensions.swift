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
	
	func setupDatePickerWithDayName() {
		let picker = configurePicker()
		picker.tag = 0
		if #available(iOS 13.4, *) {
			picker.preferredDatePickerStyle = .wheels
			picker.sizeToFit()
		}
		if let textFieldTime = self.text?.timeFromString {
			picker.date = textFieldTime 
		}
		picker.datePickerMode = .date
		picker.backgroundColor = .white
		self.inputView = picker
	}
	func setupDatePicker() {
		let picker = configurePicker()
		picker.tag = 1
		if #available(iOS 13.4, *) {
			picker.preferredDatePickerStyle = .wheels
			picker.sizeToFit()
		}
		if let textFieldTime = self.text?.timeFromString {
			picker.date = textFieldTime
		}
		picker.datePickerMode = .date
		picker.backgroundColor = .white
		self.inputView = picker
	}
	func setupTimePicker() {
		let picker = configurePicker()
		picker.tag = 2
		if #available(iOS 13.4, *) {
			picker.preferredDatePickerStyle = .wheels
			picker.sizeToFit()
		}
		if let textFieldTime = self.text?.timeFromString {
			picker.date = textFieldTime
		}
		picker.datePickerMode = .time
		picker.backgroundColor = .white
		self.inputView = picker
	}
	@objc private func pickerChanged(_ sender: UIDatePicker) {
		
		switch sender.tag {
		case 0:
			break
		case 1:
			self.text = sender.date.fullDateString
		case 2:
			self.text = sender.date.timeString
		default:
			self.text = sender.date.dateStringDisplay
		}
	}
}
