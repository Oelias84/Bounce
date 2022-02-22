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
		let calendar: NSCalendar! = NSCalendar(calendarIdentifier: .gregorian)

		if #available(iOS 15, *) {
			let dateComponent = calendar.components(.year, from: self, to: .now, options: [])
			return "\(dateComponent.year! + 1)"
		} else {
			// Fallback on earlier versions
			let calendar: NSCalendar! = NSCalendar(calendarIdentifier: .gregorian)
			let now: NSDate! = NSDate()
			let dateComponent = calendar.components(.year, from: self, to: now as Date, options: [])
			return "\(dateComponent.year!)"
		}
	}
	func calculateAge(dob : String, format:String = "yyyy-MM-dd") -> (year :Int, month : Int, day : Int){
		let df = DateFormatter()
		df.dateFormat = format
		let date = df.date(from: dob)
		guard let val = date else{
			return (0, 0, 0)
		}
		var years = 0
		var months = 0
		var days = 0
		
		let cal = Calendar.current
		years = cal.component(.year, from: Date()) -  cal.component(.year, from: val)
		
		let currMonth = cal.component(.month, from: Date())
		let birthMonth = cal.component(.month, from: val)
		
		//get difference between current month and birthMonth
		months = currMonth - birthMonth
		//if month difference is in negative then reduce years by one and calculate the number of months.
		if months < 0
		{
			years = years - 1
			months = 12 - birthMonth + currMonth
			if cal.component(.day, from: Date()) < cal.component(.day, from: val){
				months = months - 1
			}
		} else if months == 0 && cal.component(.day, from: Date()) < cal.component(.day, from: val)
		{
			years = years - 1
			months = 11
		}
		
		//Calculate the days
		if cal.component(.day, from: Date()) > cal.component(.day, from: val){
			days = cal.component(.day, from: Date()) - cal.component(.day, from: val)
		}
		else if cal.component(.day, from: Date()) < cal.component(.day, from: val)
		{
			let today = cal.component(.day, from: Date())
			let date = cal.date(byAdding: .month, value: -1, to: Date())
			
			days = date!.daysInMonth - cal.component(.day, from: val) + today
		} else
		{
			days = 0
			if months == 12
			{
				years = years + 1
				months = 0
			}
		}
		
		return (years, months, days)
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
