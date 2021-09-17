//
//  DailyMealManager.swift
//  FitApp
//
//  Created by Ofir Elias on 12/09/2021.
//

import Foundation

class DailyMealManager {
	
	static func calculateMealAverageCalories(meals: [DailyMeal]) -> Double? {
		var mealCalorieSum = 0.0
		var daysContainMealsDoneCount = 0
		var daysContainDishesDoneCount = 0
		
		//Get the number of days which has isDishDone == true
		for dailyMeal in meals {
			
			outerLoop: for i in 1...dailyMeal.meals.count {
				let meal = dailyMeal.meals[i-1]
				
				for dish in meal.dishes {
					if dish.isDishDone {
						daysContainDishesDoneCount += 1
						break outerLoop
					}
				}
			}
		}
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
				if meal.isMealDone {
					daysContainMealsDoneCount += 1
					break
				}
			}
		}
		
		if daysContainDishesDoneCount >= 4 || daysContainMealsDoneCount >= 1 {
			return mealCalorieSum / Double(daysContainDishesDoneCount)
		}
		return nil
	}
}
