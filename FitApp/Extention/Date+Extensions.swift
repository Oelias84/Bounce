//
//  Date+Extensions.swift
//  FitApp
//
//  Created by iOS Bthere on 08/12/2020.
//

import Foundation


extension Date {
    
    var fullDateString: String {
        let formatter             = DateFormatter()
        formatter.dateFormat     = "dd/MM/yyyy HH:mm"
        formatter.locale         = Locale(identifier: "en_Us")
        formatter.timeZone         = .current
        return formatter.string(from: self)
    }
    
    var timeString: String {
        let formatter             = DateFormatter()
        formatter.dateFormat     = "HH:mm"
        formatter.locale         = Locale(identifier: "en_GB")
        formatter.timeZone         = .current
        return formatter.string(from: self)
    }
    
    var dateStringForDB: String {
        let formatter             = DateFormatter()
        formatter.dateFormat     = "yyyy-MM-dd"
        formatter.locale         = Locale(identifier: "en_Us")
        formatter.timeZone         = .current
        return formatter.string(from: self)
    }
    
    var dateStringDisplay: String {
        let formatter             = DateFormatter()
        formatter.dateFormat     = "dd/MM/yyyy"
        formatter.locale         = Locale(identifier: "en_Us")
        formatter.timeZone         = .current
        return formatter.string(from: self)
    }
}
