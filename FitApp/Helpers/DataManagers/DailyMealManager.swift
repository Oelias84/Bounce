//
//  DailyMealManager.swift
//  FitApp
//
//  Created by Ofir Elias on 12/09/2021.
//

import Foundation

class DailyMealManager {
	
	static func calculateMealExpectedCalories(meals: [DailyMeal]) -> Double {
		var mealCalorieSum = 0.0
		
		//Get the overall isMealDone calories
		meals.forEach { dailyMeal in
			
			for meal in dailyMeal.meals {
				if meal.mealType != .other {
					//Check if there are mealsDone
					meal.dishes.forEach { dish in
						if dish.isDishDone {
							switch dish.type {
							case .protein:
								mealCalorieSum += dish.amount * 150.0
							case .carbs, .fat:
								mealCalorieSum += dish.amount * 100.0
							}
						}
					}
				}
			}
		}
		return mealCalorieSum
	}
	
	static func calculateMealAverageCalories(meals: [DailyMeal]) -> Double {
		var mealCalorieSum = 0.0
		
		//Get the overall isMealDone calories
		meals.forEach { dailyMeal in
			
			for meal in dailyMeal.meals {
				//Check if there are mealsDone
				meal.dishes.forEach { dish in
					switch dish.type {
					case .protein:
						mealCalorieSum += dish.amount * 150.0
					case .carbs, .fat:
						mealCalorieSum += dish.amount * 100.0
					}
				}
			}
		}
		return mealCalorieSum
	}
}
