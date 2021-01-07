//
//  MealViewModel.swift
//  FitApp
//
//  Created by iOS Bthere on 01/01/2021.
//

import Foundation

class MealViewModel: NSObject {
    
    var meals: [Meal]? {
        didSet {
            self.bindMealViewModelToController()
        }
    }
    private var manager: ConsumptionManager!
    private var googleService: GoogleApiManager!
    
    var bindMealViewModelToController : (() -> ()) = {}
    
    override init() {
        super.init()
        
        manager = ConsumptionManager()
        googleService = GoogleApiManager()
        fetchMealsForOrCreate(date: Date(), prefer: .breakfast, numberOfMeals: 3, protein: manager.getDayProtein, carbs: manager.getDayCarbs, fat: manager.getDayFat)
    }
    
    func updateMeals(for date: Date) {
        guard let meals = self.meals else { return }
        let dailyMeal = DailyMeal(meals: meals)
        
        googleService.updateMealBy(date: date, dailyMeal: dailyMeal)
    }
    func fetchMealsBy(date: Date) {
        googleService.getMealFor(date) { result in
            switch result {
            case .success(let meals):
                if let meals = meals {
                    self.meals = meals
                } else {
                    self.meals = []
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    func fetchMealsForOrCreate(date: Date, prefer: MealType?, numberOfMeals: Int, protein: Double, carbs: Double, fat: Double) {
        googleService.getMealFor(date) { result in
            switch result {
            case .success(let meals):
                if let meals = meals {
                    self.meals = meals
                } else {
                    self.meals = self.populateMeals(hasPrefer: prefer, numberOfMeals: numberOfMeals, protein: protein, carbs: carbs, fat: fat)
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
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
        let carbsForMeal = mealDishesDivider(hasPrefer: hasPrefer != nil,
                                             numberOfDishes: numberOfDishes(numberOfMeals: numberOfMeals, dishType: .carbs, numberOfDishes: carbs))
        let proteinForMeal = mealDishesDivider(hasPrefer: hasPrefer != nil,
                                               numberOfDishes: numberOfDishes(numberOfMeals: numberOfMeals, dishType: .protein, numberOfDishes: protein))
        let fatForMeal = mealDishesDivider(hasPrefer: hasPrefer != nil,
                                           numberOfDishes: numberOfDishes(numberOfMeals: numberOfMeals, dishType: .fat, numberOfDishes: fat))
        
        for i in 0...2 {
            let carbsDish = Dish(name: "טונה", type: .carbs, amount: carbsForMeal.0)
            let proteinDish = Dish(name: "ביצים", type: .protein, amount: proteinForMeal.0)
            let fatDish = Dish(name: "שוורמה", type: .fat, amount: fatForMeal.0)
            
            dayMeals[i].dishes = [carbsDish, proteinDish, fatDish]
        }
        if let prefer = hasPrefer {
            if let addToPreferred = dayMeals.first(where: {$0.mealType == prefer}) {
                addToPreferred.dishes.forEach { dish in
                    switch dish.type {
                    case .carbs:
                        dish.amount += carbsForMeal.1
                    case .protein:
                        dish.amount += proteinForMeal.1
                    case .fat:
                        dish.amount += fatForMeal.1
                    }
                }
            }
        }
        if numberOfMeals == 4 {
            dayMeals.append(Meal(mealType: .middle1, dishes: [Dish(name: "ביצים", type: .carbs, amount: 1)]))
        } else if numberOfMeals == 5 {
            dayMeals.append(Meal(mealType: .middle1, dishes: [Dish(name: "טונה", type: .protein, amount: 1), Dish(name: "ליה", type: .fat, amount: 0.5)]))
        }
        googleService.createDailyMeal(meals: dayMeals.sorted())
        return dayMeals.sorted()
    }
}
