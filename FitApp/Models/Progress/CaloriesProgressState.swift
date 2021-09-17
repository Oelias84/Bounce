//
//  CaloriesProgressState.swift
//  FitApp
//
//  Created by Ofir Elias on 17/09/2021.
//

import Foundation

enum CaloriesStatus: String, Codable {
	
	case low = "low"
	case neutral = "neutral"
	case high = "high"
	case notEnoughData = "notEnoughData"
}


struct CaloriesProgressState: Codable {
	
	let date: Date
	let status: String
	
	init(date: Date, status: CaloriesStatus) {
		self.date = date
		self.status = status.rawValue
	}
}
