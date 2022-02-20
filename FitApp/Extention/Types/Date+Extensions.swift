//
//  Date+Extensions.swift
//  FitApp
//
//  Created by iOS Bthere on 08/12/2020.
//

import Foundation


extension Date {
	
	var fullDateString: String {
		let formatter = DateFormatter()
		formatter.dateFormat = "dd/MM/yyyy HH:mm"
		formatter.locale = Locale(identifier: "en_Us")
		formatter.timeZone = .current
		return formatter.string(from: self)
	}
	
	var timeString: String {
		let formatter = DateFormatter()
		formatter.dateFormat = "HH:mm"
		formatter.locale = Locale(identifier: "en_GB")
		formatter.timeZone = .current
		return formatter.string(from: self)
	}
	
	var dateStringForDB: String {
		let formatter = DateFormatter()
		formatter.dateFormat = "yyyy-MM-dd"
		formatter.locale = Locale(identifier: "en_Us")
		formatter.timeZone = .current
		return formatter.string(from: self)
	}
	var fullDateStringForDB: String {
		let formatter = DateFormatter()
		formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
		formatter.locale = Locale(identifier: "en_Us")
		formatter.timeZone = .current
		return formatter.string(from: self)
	}
	
	var dateStringDisplay: String {
		let formatter = DateFormatter()
		formatter.dateFormat = "dd/MM/yy"
		formatter.locale = Locale(identifier: "en_Us")
		formatter.timeZone = .current
		return formatter.string(from: self)
	}
	var displayMonth: String {
		let formatter = DateFormatter()
		formatter.dateFormat = "MM/yyyy"
		formatter.locale = Locale(identifier: "en_Us")
		formatter.timeZone = .current
		return formatter.string(from: self)
	}
	var displayDayInMonth: String {
		let formatter = DateFormatter()
		formatter.dateFormat = "dd/MM"
		formatter.locale = Locale(identifier: "en_Us")
		formatter.timeZone = .current
		return formatter.string(from: self)
	}
	var displayYear: String {
		let formatter = DateFormatter()
		formatter.dateFormat = "MM/yy"
		formatter.locale = Locale(identifier: "en_Us")
		formatter.timeZone = .current
		return formatter.string(from: self)
	}
	var displayDay: String {
		let formatter = DateFormatter()
		formatter.dateFormat = "dd"
		formatter.locale = Locale(identifier: "en_Us")
		formatter.timeZone = .current
		return formatter.string(from: self)
	}
	var displayDayName: String {
		let formatter = DateFormatter()
		formatter.dateFormat = "EEEE"
		formatter.timeZone = .current
		return formatter.string(from: self)
	}
	
	var age: String? {

		let birthday: Date = self
		let timeInterval = birthday.timeIntervalSinceNow
		let age = abs(Int(timeInterval / 31556926.0)).years.years
		
		return "\(age)"
	}
}

extension Date {
	
	var startOfWeek: Date? {
		let gregorian = Calendar(identifier: .gregorian)
		guard let sunday = gregorian.date(from: gregorian.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)) else { return nil }
		return gregorian.date(byAdding: .day, value: 0, to: sunday)
	}
	var endOfWeek: Date? {
		let gregorian = Calendar(identifier: .gregorian)
		guard let sunday = gregorian.date(from: gregorian.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)) else { return nil }
		return gregorian.date(byAdding: .day, value: 6, to: sunday)
	}
	var onlyDate: Date {
		let calender = Calendar.current
		var dateComponents = calender.dateComponents([.year, .month, .day], from: self)
		dateComponents.timeZone = NSTimeZone.system
		return calender.date(from: dateComponents)!
	}
	var onlyTime: Date {
		let calender = Calendar.current
		var dateComponents = calender.dateComponents([.hour,.minute], from: self)
		dateComponents.timeZone = NSTimeZone.system
		return calender.date(from: dateComponents)!
	}
}
