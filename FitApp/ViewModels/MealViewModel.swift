//
//  MealViewModel.swift
//  FitApp
//
//  Created by iOS Bthere on 01/01/2021.
//

import Foundation

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
	
	//MARK: - Meals Progress
	func getMealDate() -> Date {
		return meals!.first!.date
	}
	func getProgress() -> MealProgress {
		var carbs: Double
		var fats: Double
		var protein: Double
		
		guard let meals = meals else {
			LocalNotificationManager.shared.setMealNotification()
			return MealProgress(carbs: 0.0, fats: 0.0, protein: 0.0)
		}
		
		carbs = 0
		fats = 0
		protein = 0
		
		for meal in meals {
			for dish in meal.dishes {
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
		return MealProgress(carbs: carbs, fats: fats, protein: protein)
	}
	func getMealStringDate() -> String {
		return (currentMealDate ?? Date()).dateStringDisplay + " " + (currentMealDate ?? Date()).displayDayName
	}
	func getExceptionalCalories() -> String? {
		if let meals = meals, meals.contains(where: {$0.mealType == .other}) {
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
	func mealDishesDivider(hasPrefer: Bool, numberOfDishes: Double) -> (Double, Double) {
		let reducer = 0.5
		let numberOfMeals = 3
		let isDividable = (numberOfDishes / Double(numberOfMeals)).isWholeNumber
		var dishesForMeal = 0.0
		var reminder = 0.0
		
		if hasPrefer {
			if isDividable {
				let numberOfDishesLessOne = numberOfDishes-reducer
				dishesForMeal = (numberOfDishesLessOne / Double(numberOfMeals)).roundHalfDown
				reminder = numberOfDishesLessOne - (dishesForMeal * Double(numberOfMeals)) + reducer
			} else {
				dishesForMeal = (numberOfDishes / Double(numberOfMeals)).roundHalfDown
				reminder = numberOfDishes - (dishesForMeal * Double(numberOfMeals))
			}
		} else {
			if isDividable { return (numberOfDishes/Double(numberOfMeals), reminder) }
			dishesForMeal = (numberOfDishes / Double(numberOfMeals)).roundHalfDown
			reminder = numberOfDishes - (dishesForMeal * Double(numberOfMeals))
		}
		return (dishesForMeal, reminder.roundHalfDown)
	}
	func numberOfDishes(numberOfMeals: Int, dishType: DishType, numberOfDishes: Double) -> Double {
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
				return numberOfDishes - 1
			}
		} else {
			return numberOfDishes
		}
	}
	func populateMeals(date: Date, hasPrefer: MealType?, numberOfMeals: Int, protein: Double, carbs: Double, fat: Double) -> [Meal] {
		var dayMeals = [Meal(mealType: .breakfast, dishes: [], date: date), Meal(mealType: .lunch, dishes: [], date: date), Meal(mealType: .supper, dishes: [], date: date)]
		
		let numberCarbsDish = numberOfDishes(numberOfMeals: numberOfMeals, dishType: .carbs, numberOfDishes: carbs)
		let numberProteinDish = numberOfDishes(numberOfMeals: numberOfMeals, dishType: .protein, numberOfDishes: protein)
		let numberFatDishes = numberOfDishes(numberOfMeals: numberOfMeals, dishType: .fat, numberOfDishes: fat)
		
		let carbsForMeal = mealDishesDivider(hasPrefer: hasPrefer != nil, numberOfDishes: numberCarbsDish)
		let proteinForMeal = mealDishesDivider(hasPrefer: hasPrefer != nil, numberOfDishes: numberProteinDish)
		let fatForMeal = mealDishesDivider(hasPrefer: hasPrefer != nil, numberOfDishes: numberFatDishes)
		
		for i in 0...2 {
			let mealType: [MealType] = [.breakfast, .lunch, .supper]
			let carbsDish = Dish(name: DishesGenerator.randomDishFor(mealType: mealType[i], .carbs), type: .carbs, amount: carbsForMeal.0)
			let proteinDish = Dish(name: DishesGenerator.randomDishFor(mealType: mealType[i], .protein), type: .protein, amount: proteinForMeal.0)
			let fatDish = Dish(name: DishesGenerator.randomDishFor(mealType: mealType[i], .fat), type: .fat, amount: fatForMeal.0)
			
			dayMeals[i].dishes = [proteinDish, carbsDish, fatDish]
		}
		if let prefer = hasPrefer {
			if let addToPreferred = dayMeals.first(where: {$0.mealType == prefer}) {
				
				addToPreferred.dishes.forEach { dish in
					switch dish.type {
					case .protein:
						dish.amount += proteinForMeal.1
					case .carbs:
						dish.amount += carbsForMeal.1
					case .fat:
						dish.amount += fatForMeal.1
					}
				}
			}
		}
		if numberOfMeals == 4 {
			if numberCarbsDish < 4 {
				dayMeals.insert(Meal(mealType: .middle1,
									 dishes: [Dish(name: DishesGenerator.randomDishFor(mealType: .middle1, .protein),type: .protein, amount: 1)],
									 date: date), at: 1)
			} else {
				dayMeals.insert(Meal(mealType: .middle1,
									 dishes: [Dish(name: DishesGenerator.randomDishFor(mealType: .middle1, .carbs),type: .carbs, amount: 1)],
									 date: date), at: 1)
			}
		} else if numberOfMeals == 5 {
			dayMeals.insert(Meal(mealType: .middle1,
								 dishes: [Dish(name: DishesGenerator.randomDishFor(mealType: .middle1, .carbs), type: .carbs, amount: 1)],
								 date: date),at: 1)
			dayMeals.insert(Meal(mealType: .middle2,
								 dishes: [Dish(name: DishesGenerator.randomDishFor(mealType: .middle1, .protein),type: .protein, amount: 1), Dish(name: DishesGenerator.randomDishFor(mealType: .middle1, .fat), type: .fat, amount: 0.5)],
								 date: date), at: 3)
		}
		GoogleApiManager.shared.createDailyMeal(meals: dayMeals, date: date)
		return dayMeals
	}
}
