//
//  Weight.swift
//  FitApp
//
//  Created by iOS Bthere on 23/12/2020.
//

import Foundation

struct Weight: Codable, Comparable {
	
    var dateString: String
    var weight: Double
	var imagePath: String?
    
	init(dateString: String, weight: Double, imagePath: String? = nil) {
		self.dateString = dateString
		self.weight = weight
		self.imagePath = imagePath
	}
	var date: Date {
		get {
			return dateString.dateFromString!
		}
		set {
			dateString = newValue.dateStringForDB
		}
	}
    var printWeightFullDate: String {
		return date.dateStringDisplay
    }
    var printWeightDay: String {
        return date.displayDayInMonth
    }
    var printWeight: String {
        return String(format: "%.1f", weight) + " ק״ג"
    }
	
	static func < (lhs: Weight, rhs: Weight) -> Bool {
		lhs.date < rhs.date
	}
}

struct Weights: Codable {
    
    let weights: [Weight]
}
