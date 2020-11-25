//
//  String+Extensions.swift
//  MyFItApp
//
//  Created by Ofir Elias on 14/11/2020.
//

import UIKit

extension String {
	
	//MARK: - DateFormat
	func fullDateFromStringWith(format: String) -> Date? {
		let formatter = DateFormatter()
		formatter.dateFormat = format
		formatter.locale = Locale(identifier: "en_GB")
		return formatter.date(from: self)
	}
	var fullDateFromStringWithDash: Date? {
		let formatter = DateFormatter()
		formatter.dateFormat = "yyyy-MM-dd HH:mm"
		formatter.locale = Locale(identifier: "en_GB")
		formatter.timeZone = .current
		return formatter.date(from: self)
	}
	var fullDateFromString: Date? {
		let formatter = DateFormatter()
		formatter.dateFormat = "dd/MM/yyyy HH:mm"
		formatter.locale = Locale(identifier: "en_GB")
		formatter.timeZone = .current
		return formatter.date(from: self)
	}
	var timeFromString: Date? {
		let formatter = DateFormatter()
		formatter.dateFormat = "HH:mm"
		formatter.locale = Locale(identifier: "en_GB")
		formatter.timeZone = .current
		return formatter.date(from: self)
	}
	var dateFromString: Date? {
		let formatter = DateFormatter()
		formatter.dateFormat = "yyyy-MM-dd"
		formatter.locale = Locale(identifier: "en_GB")
		formatter.timeZone = .current
		return formatter.date(from: self)
	}
	var shortDateFromString: Date? {
		let formatter = DateFormatter()
		formatter.dateFormat = "yyyy-MM"
		formatter.locale = Locale(identifier: "en_GB")
		formatter.timeZone = .current
		return formatter.date(from: self)
	}
	
	//MARK: - Validation
	var isValidEmail: Bool {
		let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
		let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
		return emailPred.evaluate(with: self)
	}
	var isValidPrice: Bool {
		let formatter = NumberFormatter()
		formatter.allowsFloats = true
		let decimalSeparator = formatter.decimalSeparator ?? "."
		if formatter.number(from: self) != nil {
			let split = self.components(separatedBy: decimalSeparator)
			let digits = split.count == 2 ? split.last ?? "" : ""
			return digits.count <= 2
		}
		return false
	}
	var isValidBirthDate: Bool {
		guard let date = fullDateFromStringWith(format: "dd/MM/yyyy") else { return false}
		return date <= Date()
	}
	var isValidFullName: Bool {
		if !(self.split(separator: " ").count > 1) {
			return false
		} else{
			let fullNameRegex = "[A-Za-z\u{0590}-\u{05FF}]*"
			return self.range(of: fullNameRegex, options: .regularExpression) != nil
		}
	}
	var isValidWebLink: Bool {
		let regEx = "((https|http)://)((\\w|-)+)(([.]|[/])((\\w|-)+))+"
		let predicate = NSPredicate(format:"SELF MATCHES %@", argumentArray:[regEx])
		return predicate.evaluate(with: self)
	}
	var isValidStreet: Bool {
		let decimalCharacters = CharacterSet.decimalDigits
		let decimalRange = self.rangeOfCharacter(from: decimalCharacters)
		if  decimalRange != nil {
			return true
		}
		return false
	}
	//All phone Numbers
	var isValidPhoneNumber: Bool {
		let regEx = "^(\\+972|0)(\\-)?0?(([23489]{1}\\d{7})|[5]{1}\\d{8})|(\\*)\\d{3,5}|(07\\d{1})\\d{7}$"
		let predicate = NSPredicate(format:"SELF MATCHES %@", argumentArray:[regEx])
		return predicate.evaluate(with: self)
	}
	//Only Mobile Numbers
	var isValidMobilePhoneNumber: Bool {
		let regEx = "(^[+9725]{5})+(\\d{8}$)|(^05\\d([-]{0,1})\\d{7}$)"
		let predicate = NSPredicate(format:"SELF MATCHES %@", argumentArray:[regEx])
		return predicate.evaluate(with: self)
	}
}
