//
//  CaloriesProgressState.swift
//  FitApp
//
//  Created by Ofir Elias on 17/09/2021.
//

import Foundation

struct CaloriesProgressState: Codable, Comparable {

	let date: Date
	let differenceBetweenAverageWeight: Double
	let differenceBetweenAverageWeightPercentage: Double
	let userCaloriesBetweenConsumedAndGiven: Double
	let userWeekConsumedCalories: Double
	let userWeekExpectedCalories: Double
	let firstWeekAverageWeight: Double
	let secondWeekAverageWeight: Double
	
	init(date: Date, userCaloriesBetweenConsumedAndGiven: Double,
		 userWeekConsumedCalories: Double, userWeekExpectedCalories: Double,
		 firstWeekAverageWeight: Double, secondWeekAverageWeight: Double) {
		
		let averageWeightDifference = firstWeekAverageWeight - secondWeekAverageWeight
		let averageWeightDifferencePrecent = ( averageWeightDifference / firstWeekAverageWeight) * 100
		
		self.date = date
		self.differenceBetweenAverageWeight = averageWeightDifference
		self.differenceBetweenAverageWeightPercentage = averageWeightDifferencePrecent
		self.userWeekConsumedCalories = userWeekConsumedCalories
		self.userWeekExpectedCalories = userWeekExpectedCalories
		self.firstWeekAverageWeight = firstWeekAverageWeight
		self.secondWeekAverageWeight = secondWeekAverageWeight
		self.userCaloriesBetweenConsumedAndGiven = userCaloriesBetweenConsumedAndGiven
	}
	
	static func < (lhs: CaloriesProgressState, rhs: CaloriesProgressState) -> Bool {
		lhs.date > rhs.date
	}
}
