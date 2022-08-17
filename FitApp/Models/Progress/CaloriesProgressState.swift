//
//  CaloriesProgressState.swift
//  FitApp
//
//  Created by Ofir Elias on 17/09/2021.
//

import Foundation

struct CaloriesProgressState: Codable {
	
	var date: Date?
	var oldDailyExpectedCalories: Double?
	var newDailyExpectedCalories: Double?
	var differenceBetweenAverageWeight: Double?
	var differenceBetweenAverageWeightPercentage: Double?
	var userCaloriesBetweenConsumedAndGiven: Double?
	var userWeekConsumedCalories: Double?
	var userWeekExpectedCalories: Double?
	var firstWeekAverageWeight: Double?
	var secondWeekAverageWeight: Double?
	
//	init(date: Date, oldDailyExpectedCalories: Double, newDailyExpectedCalories: Double, userCaloriesBetweenConsumedAndGiven: Double,
//		 userWeekConsumedCalories: Double, userWeekExpectedCalories: Double,
//		 firstWeekAverageWeight: Double, secondWeekAverageWeight: Double) {
//
//		let averageWeightDifference = firstWeekAverageWeight - secondWeekAverageWeight
//		let averageWeightDifferencePrecent = ( averageWeightDifference / firstWeekAverageWeight) * 100
//
//		self.date = date
//		self.oldDailyExpectedCalories = oldDailyExpectedCalories
//		self.newDailyExpectedCalories = newDailyExpectedCalories
//		self.differenceBetweenAverageWeight = averageWeightDifference
//		self.differenceBetweenAverageWeightPercentage = averageWeightDifferencePrecent
//		self.userWeekConsumedCalories = userWeekConsumedCalories
//		self.userWeekExpectedCalories = userWeekExpectedCalories
//		self.firstWeekAverageWeight = firstWeekAverageWeight
//		self.secondWeekAverageWeight = secondWeekAverageWeight
//		self.userCaloriesBetweenConsumedAndGiven = userCaloriesBetweenConsumedAndGiven
//	}
}
