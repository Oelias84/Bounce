//
//  Weight.swift
//  FitApp
//
//  Created by iOS Bthere on 23/12/2020.
//

import Foundation

struct Weight: Codable, Comparable {
	
    let date: Date
    let weight: Double
    
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
