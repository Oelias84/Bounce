//
//  MealViewModel.swift
//  FitApp
//
//  Created by iOS Bthere on 01/01/2021.
//

import Foundation

class MealViewModel: NSObject {
    
    static let shared = MealViewModel()
    var meals: [Meal]? {
        didSet {
            self.bindMealViewModelToController()
        }
    }
    private var dishes: [[ServerDish]]?
	private var currentMealDate: Date?
    
    var bindMealViewModelToController : (() -> ()) = {}
    
    override init() {
        super.init()
		
		fetchDishes()
    }
    
    func fetchData() {
		let consumptionManager = ConsumptionManager.shared
		consumptionManager.calculateUserData()
		
        if self.meals == nil {
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
			fetchMealsForOrCreate(date: Date(), prefer: preferredMeal, numberOfMeals: userData.mealsPerDay!, protein: consumptionManager.getDayProtein, carbs: consumptionManager.getDayCarbs, fat: consumptionManager.getDayFat)
        }
    }
    
    //MARK: - Meals Progress
    func getProgress() -> MealProgress {
        var carbs = 0.0
        var fats = 0.0
        var protein = 0.0

		guard meals != nil else { return MealProgress(carbs: 0.0, fats: 0.0, protein: 0.0) }
        for meal in meals! {
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
        return MealProgress(carbs: carbs, fats: fats, protein: protein)
    }
	func getMealDate() -> Date {
		return currentMealDate ?? Date()
	}
	func checkDailyMealIsDone(completion: @escaping (Bool) -> ()) {
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
    func updateMeals(for date: Date) {
        guard let meals = self.meals else { return }
        let dailyMeal = DailyMeal(meals: meals)
		GoogleApiManager.shared.updateMealBy(date: date, dailyMeal: dailyMeal)
    }
    func fetchMealsBy(date: Date) {
		GoogleApiManager.shared.getMealFor(date) { result in
            switch result {
            case .success(let dailyMeal):
                if let dailyMeal = dailyMeal {
                    self.meals = dailyMeal.meals
					self.currentMealDate = date
                } else {
                    self.meals = []
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    func fetchMealsForOrCreate(date: Date, prefer: MealType?, numberOfMeals: Int, protein: Double, carbs: Double, fat: Double) {
		GoogleApiManager.shared.getMealFor(date) { result in
            switch result {
            case .success(let dailyMeal):
                if let dailyMeal = dailyMeal {
                    self.meals = dailyMeal.meals
					self.currentMealDate = date
                } else {
                    self.meals = self.populateMeals(hasPrefer: prefer, numberOfMeals: numberOfMeals, protein: protein, carbs: carbs, fat: fat)
					UserProfile.defaults.showMealNotFinishedAlert = true
                }
            case .failure(let error):
                print(error)
            }
        }
    }
	func checkTodaysMeal(completion: @escaping (Bool) -> ()) {
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
    
    //MARK: Dishes
    func fetchDishes() {
        if dishes != nil && dishes!.count > 0 { return }
        
		GoogleApiManager.shared.getDishes { result in
            switch result {
            case .success(let dishes):
                if let dishes = dishes {
                    self.dishes = dishes
                } else {
                    return
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    func getDishesFor(type: DishType) -> [ServerDish] {
        var dishArray: [ServerDish] = []
        guard let dishes = self.dishes else { return [] }
        
        switch type {
        case .fat:
			dishArray = dishes[0].sorted()
        case .carbs:
			dishArray = dishes[1].sorted()
        case .protein:
			dishArray = dishes[2].sorted()
        }
        return dishArray
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
    func populateMeals(hasPrefer: MealType?, numberOfMeals: Int, protein: Double, carbs: Double, fat: Double) -> [Meal] {
        var dayMeals = [Meal(mealType: .breakfast, dishes: []), Meal(mealType: .lunch, dishes: []), Meal(mealType: .supper, dishes: [])]
		
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
				dayMeals.insert(Meal(mealType: .middle1, dishes: [Dish(name: DishesGenerator.randomDishFor(mealType: .middle1, .protein), type: .protein, amount: 1)]), at: 1)
			} else {
				dayMeals.insert(Meal(mealType: .middle1, dishes: [Dish(name: DishesGenerator.randomDishFor(mealType: .middle1, .carbs), type: .carbs, amount: 1)]), at: 1)
			}
        } else if numberOfMeals == 5 {
            dayMeals.insert(Meal(mealType: .middle1, dishes: [Dish(name: DishesGenerator.randomDishFor(mealType: .middle1, .carbs), type: .carbs, amount: 1)]), at: 1)
            dayMeals.insert(Meal(mealType: .middle2, dishes: [Dish(name: DishesGenerator.randomDishFor(mealType: .middle1, .protein), type: .protein, amount: 1),
                                                              Dish(name: DishesGenerator.randomDishFor(mealType: .middle1, .fat), type: .fat, amount: 0.5)]), at: 3)
        }
		GoogleApiManager.shared.createDailyMeal(meals: dayMeals)
        return dayMeals
    }
}
