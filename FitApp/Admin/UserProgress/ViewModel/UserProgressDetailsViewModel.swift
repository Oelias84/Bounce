//
//  UserProgressDetailsViewModel.swift
//  FitApp
//
//  Created by Ofir Elias on 06/06/2022.
//

import Foundation

final class UserProgressDetailsViewModel {
	
	let userProgressData: CaloriesProgressState!
	
	init(userProgressData: CaloriesProgressState) {
		self.userProgressData = userProgressData
	}
	
	var getDate: String {
		return userProgressData.date.dateStringDisplay
	}
	var getDifferenceBetweenAverageWeight: String {
		return String(format:"%.2f", userProgressData.differenceBetweenAverageWeight)
	}
	var getDifferenceBetweenAverageWeightPercentage: String {
		return String(format:"%.2f", userProgressData.differenceBetweenAverageWeightPercentage)
	}
	var getUserCaloriesBetweenConsumedAndGiven: String {
		return String(format:"%.2f", userProgressData.userCaloriesBetweenConsumedAndGiven)
	}
	var getUserWeekConsumedCalories: String {
		return String(format:"%.2f", userProgressData.userWeekConsumedCalories)
	}
	var getUserWeekExpectedCalories: String {
		return String(format:"%.2f", userProgressData.userWeekExpectedCalories)
	}
	var getFirstWeekAverageWeight: String {
		return String(format:"%.2f", userProgressData.firstWeekAverageWeight)
	}
	var getSecondWeekAverageWeight: String {
		return String(format:"%.2f", userProgressData.secondWeekAverageWeight)
	}
}
