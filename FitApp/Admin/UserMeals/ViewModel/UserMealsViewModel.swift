//
//  UserMealsViewModel.swift
//  FitApp
//
//  Created by Ofir Elias on 04/06/2022.
//

import Foundation

final class UserMealsViewModel {
	
	var userID: String!
	var meals: ObservableObject<[Meal]?> = ObservableObject(nil)
	
	init(userID: String) {
		self.userID = userID
		fetchMealsBy(date: Date())
	}
	
	var getNumberOfMeals:Int {
		meals.value?.count ?? 0
	}
	func getCellForRow(at index: Int) -> Meal {
		meals.value![index]
	}
}

//MARK: - Functions
extension UserMealsViewModel {
	
	func fetchMealsBy(date: Date) {
		GoogleApiManager.shared.getMealFor(userID: userID, date) {
			[weak self] result in
			guard let self = self else { return }
			
			switch result {
				
			case .success(let dailyMeal):
				
				if let dailyMeal = dailyMeal {
					self.meals.value = dailyMeal.meals
				} else {
					self.meals.value = []
				}
			case .failure(let error):
				print("Error:", error.localizedDescription)
			}
		}
	}
}
