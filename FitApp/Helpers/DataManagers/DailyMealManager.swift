//
//  DailyMealManager.swift
//  FitApp
//
//  Created by Ofir Elias on 12/09/2021.
//

import Foundation

class DailyMealManager {
	
	static func calculateMealAverageCalories(meals: [DailyMeal]) -> Double {
		var mealCalorieSum = 0.0
		
		//Get the overall isMealDone calories
		meals.forEach { dailyMeal in
			
			for meal in dailyMeal.meals {
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
		return mealCalorieSum
	}
	
	static func calculateMealExpectedCalories(meals: [DailyMeal]) -> Double {
		var mealCalorieSum = 0.0
		
		//Get the overall isMealDone calories
		meals.forEach { dailyMeal in
			
			for meal in dailyMeal.meals {
				if meal.mealType != .other {
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
		}
		return mealCalorieSum
	}
	static func getCurrentMealsCalories(meals: [Meal]) -> String {
		var mealCalorieSum: Double = 0.0
		
		meals.forEach {
			$0.dishes.forEach {
				switch $0.type {
				case .protein:
					mealCalorieSum += $0.amount * 150.0
				case .carbs, .fat:
					mealCalorieSum += $0.amount * 100
				}
			}
		}
		return "\(mealCalorieSum)"
	}
	static func getMealCaloriesSum(dishes: [Dish]) -> String {
		var mealCalorieSum: Double = 0.0
		
		dishes.forEach {
			switch $0.type {
			case .protein:
				mealCalorieSum += $0.amount * 150.0
			case .carbs, .fat:
				mealCalorieSum += $0.amount * 100
			}
		}
		return String(format: "%.0f", mealCalorieSum)
	}
}
