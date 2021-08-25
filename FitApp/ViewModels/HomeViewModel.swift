//
//  HomeViewModel.swift
//  FitApp
//
//  Created by Ofir Elias on 06/08/2021.
//

import UIKit
import Foundation

class HomeViewModel {
	
	lazy var mealViewModel = MealViewModel.shared
	private let userConsumption = ConsumptionManager.shared
	
	private var fatColor = #colorLiteral(red: 0.9450980392, green: 0.1529411765, blue: 0.06666666667, alpha: 1)
	private var carbsColor = #colorLiteral(red: 0.4980392157, green: 0.4980392157, blue: 0.8352941176, alpha: 1)
	private var proteinColor = #colorLiteral(red: 0.1411764706, green: 0.9960784314, blue: 0.2549019608, alpha: 1)

	// Getters
	var getMealDate: String {
		return mealViewModel.getMealStringDate()
	}
	var getUserCalories: String {
		return userConsumption.getCalories()
	}
	var getFatCurrentValue: String {
		return "\(getUserMealProgress.fatProgress)"
	}
	var getCarbsCurrentValue: String {
		return "\(getUserMealProgress.carbsProgress)"
	}
	var getProteinCurrentValue: String {
		return "\(getUserMealProgress.proteinProgress)"
	}
	var getFatTargateValue: String {
		return "\(getUserMealProgress.fatTarget)"
	}
	var getCarbsTargateValue: String {
		return "\(getUserMealProgress.carbsTarget)"
	}
	var getProteinTargateValue: String {
		return "\(getUserMealProgress.proteinTarget)"
	}
	
	var proteinPercentage: Double {
		return (getUserMealProgress.proteinProgress / getUserMealProgress.proteinTarget)
	}
	var carbsPercentage: Double {
		return (getUserMealProgress.carbsProgress / getUserMealProgress.carbsTarget)
	}
	var fatPercentage: Double {
		return (getUserMealProgress.fatProgress / getUserMealProgress.fatTarget)
	}
	
	var getUserMealProgress: UserProgress {
		let currentProgress = mealViewModel.getProgress()
		userConsumption.calculateUserData()

		return UserProgress(carbsTarget: userConsumption.getDailyCarbs(),
							proteinTarget: userConsumption.getDailyProtein(),
							fatTarget: userConsumption.getDailyFat(),
							carbsProgress: currentProgress.carbs,
							proteinProgress: currentProgress.protein,
							fatProgress: currentProgress.fats)
	}
	func fetchMeals() {
		mealViewModel.fetchData()
	}
	
	var getFatColor: UIColor {
		return fatColor
	}
	var getCarbsColor: UIColor {
		return carbsColor
	}
	var getProteinColor: UIColor {
		return proteinColor
	}
	
	// Meals Binder
	func bindToMealViewModel(completion: @escaping ()->()) {
		mealViewModel.bindMealViewModelToController = {
			completion()
		}
	}
	
	// Check user current status
	func checkAddWeight(completion: @escaping ()->()) {
		WeightViewModel.checkAddWeight {
			showWeightAlert in
			if showWeightAlert {
				completion()
			}
		}
	}
	func checkDidFinishDailyMeals(completion: @escaping ()->()) {
		mealViewModel.checkDailyMealIsDoneBeforeHour {
			mealIsDone in
			if !mealIsDone {
				completion()
			}
		}
	}
	func getMotivationText(completion: @escaping (String) -> ()) {
		var motivationText = "..."
		
		GoogleApiManager.shared.getMotivations { result in
			
			switch result {
			case .success(let motivations):
				if let motivations = motivations {
					if let lastMotivation = UserProfile.defaults.motivationText {
						motivationText = motivations.text.filter{ $0 != lastMotivation }[Int.random(in: 0...motivations.text.count-2)]
						completion(motivationText)
					} else {
						motivationText = motivations.text[Int.random(in: 0...motivations.text.count)]
						completion(motivationText)
					}
				}
			case .failure(let error):
				print(error)
			}
		}
	}
}
