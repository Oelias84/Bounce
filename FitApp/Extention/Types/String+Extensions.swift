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
		formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
		formatter.locale = Locale(identifier: "en_GB")
		formatter.timeZone = .current
		return formatter.date(from: self)
	}
	var fullDateFromStringWithDay: Date? {
		let formatter = DateFormatter()
		formatter.dateFormat = "dd/MM/yy EEEE"
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
	
	//MARK: - String manipulation
	var splitFullName: (String, String) {
		let splitUserName = components(separatedBy: " ")
		if splitUserName.count == 2 {
			return (splitUserName[0], splitUserName[1])
		} else {
			return (splitUserName[0], "")
		}
	}
	var colorText: NSAttributedString {
		let myAttribute = [ NSAttributedString.Key.foregroundColor: UIColor.red ]
		let myAttrString = NSAttributedString(string: self, attributes: myAttribute)

		return myAttrString
	}
	//MARK: - Email format
	var safeEmail: String {
		var safeEmail = replacingOccurrences(of: ".", with: "-")
		safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
		return safeEmail
	}
	//MARK: - Image from string
	var showImage: UIImage? {
		guard let url = URL(string: self) else { return nil }
		if let data = try? Data(contentsOf: url) {
			return UIImage(data: data)
		}
		return nil
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
	//Decimal
	var toDecimalDouble: Double {
		let formatter = NumberFormatter()
		formatter.generatesDecimalNumbers = true
		formatter.numberStyle = NumberFormatter.Style.decimal
		if let formattedNumber = formatter.number(from: self) as? NSDecimalNumber  {
			return Double(truncating: formattedNumber)
		}
		return 0.0
	}
	
	func createAttributedString(attributedPart: Int, attributes: [NSAttributedString.Key: Any]) -> NSMutableAttributedString? {
		let finalString = NSMutableAttributedString()
		let wordsArray = self.words
		if wordsArray.count > 1 {
			for i in 0 ..< wordsArray.count {
				var attributedString = NSMutableAttributedString(string: String(wordsArray[i]) + " ", attributes: nil)

				if i == attributedPart {
					attributedString = NSMutableAttributedString(string: attributedString.string + " ", attributes: attributes)
					finalString.append(attributedString)
				} else {
					finalString.append(attributedString)
				}
			}
		}
		return finalString
	}
}

extension String {
    
    static let noInformation = "אין מידע"
}

extension StringProtocol {
	var words: [SubSequence] {
		return split { !$0.isLetter }
	}
}

