//
//  HomeViewModel.swift
//  FitApp
//
//  Created by Ofir Elias on 06/08/2021.
//

import UIKit
import Foundation

class HomeViewModel {
	
	private let userConsumption = ConsumptionManager.shared
	
	private var fatColor = UIColor.projectTurquoise
	private var carbsColor = UIColor.projectGreen
	private var proteinColor = UIColor.projectTail
	
	// Getters
	var getMealDate: String {
		return MealViewModel.shared.getMealStringDate()
	}
	var getUserCalories: String {
		return MealViewModel.shared.getCurrentMealCalories()
	}
	var getUserExceptionalCalories: String? {
		if let exCalories = MealViewModel.shared.getExceptionalCalories() {
			return exCalories
		}
		return nil
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
		let currentProgress = MealViewModel.shared.getProgress()
		userConsumption.calculateUserData()
		
		return UserProgress(carbsTarget: currentProgress.1.carbs,
							proteinTarget: currentProgress.1.protein,
							fatTarget: currentProgress.1.fats,
							carbsProgress: currentProgress.0.carbs,
							proteinProgress: currentProgress.0.protein,
							fatProgress: currentProgress.0.fats)
	}
	func fetchMeals() {
		
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
		MealViewModel.shared.fetchData()
		MealViewModel.shared.bindMealViewModelToController = {
			completion()
		}
	}
	
	// Check user current status
	func checkAddWeight(completion: @escaping ()->()) {
		WeightsManager.shared.checkAddWeight {
			showWeightAlert in
			if showWeightAlert {
				completion()
			}
		}
	}
	func checkDidFinishDailyMeals(completion: @escaping ()->()) {
		MealViewModel.shared.checkDailyMealIsDoneBeforeHour {
			mealIsDone in
			if !mealIsDone {
				completion()
			}
		}
	}
	func getMotivationText(completion: @escaping (String?) -> ()) {
		if let motivationText = UserProfile.defaults.motivationText {
			completion(motivationText)
			if let lastMotivationDate = UserProfile.defaults.lastMotivationDate?.onlyDate, lastMotivationDate.isLater(than: Date().onlyDate) {
				DispatchQueue.global(qos: .background).async {
					GoogleApiManager.shared.getMotivations { result in
						switch result {
						case .success(let motivations):
							if let motivations = motivations {
								completion(motivations.text.filter{ $0 != motivationText }[Int.random(in: 0...motivations.text.count-2)])
								UserProfile.defaults.lastMotivationDate = Date().onlyDate
							}
						case .failure(let error):
							completion(motivationText)
							print(error)
						}
					}
				}
			}
		} else {
			completion(nil)
			DispatchQueue.global(qos: .background).async {
				GoogleApiManager.shared.getMotivations { result in
					switch result {
					case .success(let motivations):
						if let motivations = motivations {
							completion(motivations.text[Int.random(in: 0...motivations.text.count)])
						}
					case .failure(let error):
						
						print(error)
					}
				}
			}
		}
	}
}
