//
//  Weight.swift
//  FitApp
//
//  Created by iOS Bthere on 23/12/2020.
//

import Foundation

struct Weight: Codable {
    
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
}

struct Weights: Codable {
    
    let weights: [Weight]
}
