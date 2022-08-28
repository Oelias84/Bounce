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
		return decimalWeight.shortFraction() + " ק״ג"
    }
	var decimalWeight: Decimal {
		return Decimal(weight)
	}
	static func < (lhs: Weight, rhs: Weight) -> Bool {
		lhs.date < rhs.date
	}
}

struct Weights: Codable {
    
    let weights: [Weight]
}

class WeightPeriod {
	
	let startDate: Date
	let endDate: Date
	var weightsArray: [Weight]?
	
	var decimalWeight: [Decimal] {
		guard weightsArray != nil else { return [] }
		var weights = [Decimal]()
		
		weightsArray?.forEach {
			weights.append(Decimal($0.weight))
		}
		return weights
	}
	var weightsSum: Decimal {
		decimalWeight.reduce(0, +)
	}
	
	init(startDate: Date, endDate: Date, weightsArray: [Weight]? = nil) {
		self.startDate = startDate
		self.endDate = endDate
		self.weightsArray = weightsArray
	}
	func canContain(_ date: Date) -> Bool {
		startDate.onlyDate <= date.onlyDate && date.onlyDate <= endDate.onlyDate
	}
}
