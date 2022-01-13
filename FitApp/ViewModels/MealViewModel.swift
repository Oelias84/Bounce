//
//  MealViewModel.swift
//  FitApp
//
//  Created by iOS Bthere on 01/01/2021.
//

import Foundation

struct DishesDividerResult {
	
	var amount: Double
	var remainder: Double = 0.0
	var lunchRemainder: Double = 0.0
}

class MealViewModel: NSObject {
	
	static let shared = MealViewModel()
	private let consumptionManager = ConsumptionManager.shared
	
	var meals: [Meal]? {
		didSet {
			self.bindMealViewModelToController()
		}
	}
	private var currentMealDate: Date?
	let mealManager = MealManager.shared
	
	var bindMealViewModelToController: (() -> ()) = {}
	
	private override init() {
		super.init()
	}
	
	func fetchData(date: Date? = Date()) {
		consumptionManager.calculateUserData()
		if self.meals == nil || date?.onlyDate != Date().onlyDate {
			let userData = UserProfile.defaults
			var preferredMeal: MealType?
			switch userData.mostHungry {
			case 1:
				preferredMeal = .breakfast
			case 2:
				preferredMeal = .lunch
			case 3:
				preferredMeal = .supper
			default:
				preferredMeal = nil
			}
			fetchMealsForOrCreate(date: date!, prefer: preferredMeal, numberOfMeals: userData.mealsPerDay!, protein: consumptionManager.getDailyProtein(), carbs: consumptionManager.getDailyCarbs(), fat: consumptionManager.getDailyFat())
		}
	}
	func createMealsForNewUserData() -> [Meal] {
		consumptionManager.calculateUserData()
		let userData = UserProfile.defaults
		var preferredMeal: MealType?
		
		switch userData.mostHungry {
		case 1:
			preferredMeal = .breakfast
		case 2:
			preferredMeal = .lunch
		case 3:
			preferredMeal = .supper
		default:
			preferredMeal = nil
		}
		
		let meals = self.populateMeals(forMessage: true, date: Date() + 1, hasPrefer: preferredMeal, numberOfMeals: userData.mealsPerDay!, protein: consumptionManager.getDailyProtein(), carbs: consumptionManager.getDailyCarbs(), fat: consumptionManager.getDailyFat())
		return meals
	}
	
	//MARK: - Meals Progressb
	func getMealDate() -> Date {
		return meals!.first!.date
	}
	func getProgress() -> (MealProgress, MealTarget) {
		var carbs: Double
		var fats: Double
		var protein: Double
		
		var carbsTarget: Double
		var fatsTarget: Double
		var proteinTarget: Double
		
		guard let meals = meals else {
			LocalNotificationManager.shared.setMealNotification()
			return (MealProgress(carbs: 0.0, fats: 0.0, protein: 0.0), MealTarget(carbs: 0.0, fats: 0.0, protein: 0.0))
		}
		
		carbs = 0
		fats = 0
		protein = 0
		
		carbsTarget = 0
		fatsTarget = 0
		proteinTarget = 0
		
		
		for meal in meals {
			for dish in meal.dishes {
				
				switch dish.type {
				case .carbs:
					carbsTarget += dish.amount
				case .fat:
					fatsTarget += dish.amount
				case .protein:
					proteinTarget += dish.amount
				}
				
				if dish.isDishDone {
					switch dish.type {
					case .carbs:
						carbs += dish.amount
					case .fat:
						fats += dish.amount
					case .protein:
						protein += dish.amount
					}
				}
			}
		}
		
		let minNotificationSetTime = "17:00".timeFromString!.onlyTime
		
		if (carbs + fats + protein) == 0 || (Date().onlyTime.isLater(than: minNotificationSetTime)) {
			LocalNotificationManager.shared.setMealNotification()
		} else {
			LocalNotificationManager.shared.removeMealsNotification()
		}
		return (MealProgress(carbs: carbs, fats: fats, protein: protein), MealTarget(carbs: carbsTarget, fats: fatsTarget, protein: proteinTarget))
	}
	
	func getMealStringDate() -> String {
		return (currentMealDate ?? Date()).dateStringDisplay + " " + (currentMealDate ?? Date()).displayDayName
	}
	func getExceptionalCalories() -> String? {
		if let meals = meals, meals.contains(where: {$0.mealType != .other}) {
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
			return String(format: "%.0f", mealCalorieSum)
		}
		return nil
	}
	func getCurrentMealCalories() -> String {
		var mealCalorieSum: Double = 0.0
		
		meals?.forEach {
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
	func getMealCaloriesSum(dishes: [Dish]) -> String {
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
	func checkDailyMealIsDoneBeforeHour(completion: @escaping (Bool) -> ()) {
		let calendar = Calendar.current
		let pastHour = calendar.dateComponents([.hour,.minute,.second], from: "22:30".timeFromString!)
		let currentHour = calendar.dateComponents([.hour,.minute,.second], from: Date())
		
		guard pastHour.hour! <= currentHour.hour! && pastHour.minute! <= currentHour.minute! && (UserProfile.defaults.showMealNotFinishedAlert ?? true) else {
			completion(true)
			return
		}
		
		checkTodaysMeal { isMealsDone in
			completion(isMealsDone)
		}
	}
	
	//MARK: - Meals
	func getMealsCount() -> Int {
		if let meals = meals, meals.first(where: {$0.mealType == .other}) == nil, !meals.isEmpty {
			return (meals.count) + 1
		}
		return meals?.count ?? 0
	}
	func updateMeals(for date: Date) {
		guard let meals = self.meals else { return }
		let dailyMeal = DailyMeal(meals: meals)
		getProgress()
		GoogleApiManager.shared.updateMealBy(date: date, dailyMeal: dailyMeal)
	}
	func removeExceptionalMeal(for date: Date) {
		guard var meals = self.meals else { return }
		meals.removeAll(where: { $0.name == "ארוחת חריגה" })
		let dailyMeal = DailyMeal(meals: meals)
		getProgress()
		GoogleApiManager.shared.updateMealBy(date: date, dailyMeal: dailyMeal)
		fetchMealsBy(date: date) {_ in}
	}
	
	func fetchMealsBy(date: Date, completion: @escaping (Bool) -> ()) {
		GoogleApiManager.shared.getMealFor(date) { result in
			switch result {
			case .success(let dailyMeal):
				if let dailyMeal = dailyMeal {
					self.meals = dailyMeal.meals
					self.currentMealDate = date
					completion(true)
				} else {
					self.meals = []
					completion(false)
				}
			case .failure(let error):
				print(error)
			}
		}
	}
	func move(portion: Double, of dish: Dish, from meal: Meal, to destinationMeal: Meal) {
		if let dishToSubtract = meal.dishes.first(where: { $0 == dish }) {
			if dishToSubtract.amount == portion {
				//Remove original dish if from its meal if portion equals to dish amount
				meal.dishes.removeAll(where: { $0 == dish })
			} else {
				//Subtract portion from the original dish
				dishToSubtract.amount -= portion
			}
		}
		//Append the dish with the desire portion to the destinationMeal
		destinationMeal.dishes.append(Dish(name: dish.getDishName, type: dish.type, amount: portion))
		
		updateMeals(for: meal.date)
		fetchMealsBy(date: meal.date) {_ in}
	}
	
	private func fetchMealsForOrCreate(date: Date, prefer: MealType?, numberOfMeals: Int, protein: Double, carbs: Double, fat: Double) {
		GoogleApiManager.shared.getMealFor(date) { result in
			switch result {
			case .success(let dailyMeal):
				if let dailyMeal = dailyMeal {
					self.meals = dailyMeal.meals
					self.currentMealDate = date
				} else {
					self.meals = self.populateMeals(date: date, hasPrefer: prefer, numberOfMeals: numberOfMeals, protein: protein, carbs: carbs, fat: fat)
					UserProfile.defaults.showMealNotFinishedAlert = true
				}
			case .failure(let error):
				print(error)
			}
		}
	}
	private func checkTodaysMeal(completion: @escaping (Bool) -> ()) {
		GoogleApiManager.shared.getMealFor(Date()) { result in
			switch result {
			case .success(let dailyMeal):
				if let dailyMeal = dailyMeal {
					dailyMeal.meals.forEach { meal in
						if meal.isMealDone != true {
							completion(false)
						} else {
							completion(true)
							UserProfile.defaults.showMealNotFinishedAlert = false
						}
					}
				}
			case .failure(let error):
			print(error)
			}
		}
	}
	func checkIfCurrentMealIsDone() -> Bool {
		
		if let meals = meals {
			if (meals.first(where: {!$0.isMealDone}) != nil) { return false }
		}
		return true
	}
	
	//MARK: - Meals Algorithm
	private func mealDishesDivider(hasPrefer: Bool, numberOfDishes: Double) -> DishesDividerResult {
		let numberOfMeals = 3
		let dishesForMealRaw = numberOfDishes / Double(numberOfMeals)
		let dishesForMeal = dishesForMealRaw.mealRound
		
		var result: DishesDividerResult {
			
			if !hasPrefer {
				if (dishesForMealRaw == dishesForMeal) {
					return DishesDividerResult(amount: dishesForMeal)
				} else {
					let remainder = ((dishesForMealRaw - dishesForMeal) * Double(numberOfMeals)).roundHalfDown
					return DishesDividerResult(amount: dishesForMeal, lunchRemainder: remainder)
				}
			} else {
				if (dishesForMealRaw == dishesForMeal) {
					// Is dividable
					var diff: Double
					var remainder: Double
					
					if (dishesForMeal > 0.5) {
						diff = 0.5
						remainder = 1.5
					} else {
						diff = 0.0
						remainder = 0.5
					}
					return DishesDividerResult(amount: dishesForMeal - diff, remainder: remainder)
				} else {
					// Not dividable
					let remainder = ((dishesForMealRaw - dishesForMeal) * Double(numberOfMeals)).roundHalfDown
					return DishesDividerResult(
						amount: dishesForMeal,
						remainder: remainder
					)
				}
			}
		}
		return result
	}
	private func numberOfDishes(numberOfMeals: Int, dishType: DishType, numberOfDishes: Double) -> Double {
		
		if numberOfMeals == 4 {
			switch dishType {
			case .carbs:
				return numberOfDishes - 1.0
			default:
				return numberOfDishes
			}
		} else if numberOfMeals == 5 {
			switch dishType {
			case .carbs:
				return numberOfDishes - 1.0
			case .fat:
				return numberOfDishes - 0.5
			case .protein:
				return numberOfDishes - 1.0
			}
		} else {
			return numberOfDishes
		}
	}
	private func populateMeals(forMessage: Bool = false, date: Date, hasPrefer: MealType?, numberOfMeals: Int, protein: Double, carbs: Double, fat: Double) -> [Meal] {

			let numberCarbsDish = numberOfDishes(numberOfMeals: numberOfMeals, dishType: .carbs, numberOfDishes: carbs)
			let numberProteinDish = numberOfDishes(numberOfMeals: numberOfMeals, dishType: .protein, numberOfDishes: protein)
			let numberFatDishes = numberOfDishes(numberOfMeals: numberOfMeals, dishType: .fat, numberOfDishes: fat)
			
			let carbsForMeal = mealDishesDivider(hasPrefer: hasPrefer != nil, numberOfDishes: numberCarbsDish)
			let proteinForMeal = mealDishesDivider(hasPrefer: hasPrefer != nil, numberOfDishes: numberProteinDish)
			let fatForMeal = mealDishesDivider(hasPrefer: hasPrefer != nil, numberOfDishes: numberFatDishes)
			
			let dateString = date.dateStringForDB
			var dayMeals = [
				Meal(
					mealType: .breakfast,
					dishes: [
						Dish(
							name: DishesGenerator.randomDishFor(mealType: .breakfast, .protein),
							type: .protein,
							amount: proteinForMeal.amount
						),
						Dish(
							name: DishesGenerator.randomDishFor(mealType: .breakfast, .carbs),
							type: .carbs,
							amount: carbsForMeal.amount
						),
						Dish(
							name: DishesGenerator.randomDishFor(mealType: .breakfast, .fat),
							type: .fat,
							amount: fatForMeal.amount
						),
					],
					date: dateString
				),
				Meal(
					mealType: .lunch,
					dishes: [
						Dish(
							name: DishesGenerator.randomDishFor(mealType: .lunch, .protein),
							type: .protein,
							amount: proteinForMeal.amount + proteinForMeal.lunchRemainder
						),
						Dish(
							name: DishesGenerator.randomDishFor(mealType: .lunch, .carbs),
							type: .carbs,
							amount: carbsForMeal.amount + carbsForMeal.lunchRemainder
						),
						Dish(
							name: DishesGenerator.randomDishFor(mealType: .lunch, .fat),
							type: .fat,
							amount: fatForMeal.amount + fatForMeal.lunchRemainder
						),
					],
					date: dateString
				),
				Meal(
					mealType: .supper,
					dishes: [
						Dish(
							name: DishesGenerator.randomDishFor(mealType: .supper, .protein),
							type: .protein,
							amount: proteinForMeal.amount
						),
						Dish(
							name: DishesGenerator.randomDishFor(mealType: .supper, DishType.carbs),
							type: .carbs,
							amount: carbsForMeal.amount
						),
						Dish(
							name: DishesGenerator.randomDishFor(mealType: .supper, DishType.fat),
							type: .fat,
							amount: fatForMeal.amount
						),
					],
					date: dateString
				)
			]
			if let prefer = hasPrefer {
				if let addToPreferred = dayMeals.first(where: {$0.mealType == prefer}) {
					
					addToPreferred.dishes.forEach { dish in
						switch dish.type {
						case .protein:
							dish.amount += proteinForMeal.remainder
						case .carbs:
							dish.amount += carbsForMeal.remainder
						case .fat:
							dish.amount += fatForMeal.remainder
						}
					}
				}
			}
		
			if numberOfMeals == 4 {
				if numberCarbsDish < 4 {
					dayMeals.insert(Meal(mealType: .middle1,
										 dishes: [Dish(name: DishesGenerator.randomDishFor(mealType: .middle1, .protein), type: .protein, amount: 1)],
										 date: dateString), at: 1)
				} else {
					dayMeals.insert(Meal(mealType: .middle1,
										 dishes: [Dish(name: DishesGenerator.randomDishFor(mealType: .middle1, .carbs), type: .carbs, amount: 1)],
										 date: dateString), at: 1)
				}
			} else if numberOfMeals == 5 {
				
				dayMeals.insert(Meal(mealType: .middle1,
									 dishes: [Dish(name: DishesGenerator.randomDishFor(mealType: .middle1, .carbs), type: .carbs, amount: 1)],
									 date: dateString),at: 1)
				
				dayMeals.insert(Meal(mealType: .middle2,
									 dishes: [Dish(name: DishesGenerator.randomDishFor(mealType: .middle1, .protein), type: .protein, amount: 1),
											  Dish(name: DishesGenerator.randomDishFor(mealType: .middle1, .fat), type: .fat, amount: 0.5)],
									 date: dateString), at: 3)
			}
			return dayMeals
		}
}
