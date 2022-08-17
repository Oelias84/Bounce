//
//  UserProgressManager.swift
//  FitApp
//
//  Created by Ofir Elias on 08/08/2022.
//

import Foundation

class UserProgressManager {
	
	let shard = UserProgressManager()
	
	private let mealsManager = MealsManager.shared
	private let weightsManager = WeightsManager.shared
	private let googleManager = GoogleApiManager.shared
	
	private var userDailyMeals: [DailyMeal]!
	private var userWeightsPeriod: [WeightPeriod]!

	private var dailyCalories: Double!
	private var newDailyCalories: Double!
	private var lastCalorieCheckDate: Date?
	
	private var firstWeek: WeightPeriod! {
		didSet {
			hasEnoughWeights = (firstWeek.weightsArray?.count ?? 0) < 3
			firstWeekAverageWeight = firstWeek.getWeightsAverage
		}
	}
	private var secondWeek: WeightPeriod! {
		didSet {
			hasEnoughWeights = (secondWeek.weightsArray?.count ?? 0) < 3
			secondWeekAverageWeight = secondWeek.getWeightsAverage
		}
	}
	
	private var firstWeekAverageWeight: Double!
	private var secondWeekAverageWeight: Double!
	
	private var hasEnoughWeights = false
	private var lastCaloriesCheckDateString: Date?

	private var caloriesProgress = CaloriesProgressState()
	
	private init() {
		if caloriesProgress.date == nil {
			self.caloriesProgress.date = Date().onlyDate
		}
	}
}

extension UserProgressManager {
	
	// Fetch data
	private func fetchMeals(completion: @escaping () -> ()) {
		
		googleManager.getAllMeals {
			[weak self] result in
			guard let self = self else { return }
			
			switch result {
			case .success(let dailyMeals):
				guard let dailyMeals = dailyMeals else { return }
				self.userDailyMeals = dailyMeals
				completion()
			case .failure(let error):
				print(error)
				completion()
			}
		}
	}
	private func fetchWeights(completion: @escaping () -> ()) {
		
		weightsManager.splittedWeeksWeightsPeriod.bind {
			[weak self] weightsPeriod in
			guard let self = self else { return }
			
			if weightsPeriod != nil {
				self.userWeightsPeriod = weightsPeriod
				completion()
			}
		}
	}
	
	// Configure data
	private func configureWeightsPeriods() {
		guard let firstWeekDate = weightsManager.getFirstWeight?.date.onlyDate.add(3.weeks) else { return }

		// If first time
		if Date().onlyDate.isEarlier(than: firstWeekDate) {
			firstWeek = userWeightsPeriod[0]
			secondWeek = userWeightsPeriod[1]
		} else {
			guard let lastCaloriesCheckDateString = lastCaloriesCheckDateString else { return }

			firstWeek = userWeightsPeriod.first(where: {
				let firstWeekDate = lastCaloriesCheckDateString.subtract(1.days).onlyDate
				let weightPeriod = $0.canContain(firstWeekDate)
				return weightPeriod
			})
			secondWeek = userWeightsPeriod.first(where: {
				let secondWeekStartDate = firstWeek?.endDate.onlyDate.add(1.days)
				let weightPeriod = $0.canContain(secondWeekStartDate!)
				return weightPeriod
			})
		}
	}
	private func calculateConsumedCaloriesFormPastWeek() {
		guard let lastCaloriesCheckDateString = lastCaloriesCheckDateString else { return }
		
		//If first check the take today and subtract a week else add take
		let firstDayForCalculatedWeek = lastCaloriesCheckDateString.subtract(1.weeks).start(of: .day)
		
		let mealsConsumedInPeriod = userDailyMeals.filter {
			$0.meals.first!.date.onlyDate.isLaterThanOrEqual(to: firstDayForCalculatedWeek) &&
			$0.meals.first!.date.onlyDate.isEarlier(than: firstDayForCalculatedWeek.add(1.weeks).start(of: .day))
		}
		
		let consumedCalories = DailyMealManager.calculateMealAverageCalories(meals: mealsConsumedInPeriod)
		caloriesProgress.userExpectedDailyCalories = DailyMealManager.calculateMealExpectedCalories(meals: mealsConsumedInPeriod)
		caloriesProgress.userCaloriesBetweenConsumedAndGiven = consumedCalories - userExpectedDailyCalories
		caloriesProgress.userConsumedCalories = consumedCalories
	}
}
