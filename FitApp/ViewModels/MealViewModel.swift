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
    
    private var manager: ConsumptionManager!
    public var googleService: GoogleApiManager!
    
    var bindMealViewModelToController : (() -> ()) = {}
    
    override init() {
        super.init()
        
        manager = ConsumptionManager()
        googleService = GoogleApiManager()
    }
    
    func fetchData() {
        fetchMealsForOrCreate(date: Date(), prefer: .breakfast, numberOfMeals: 3, protein: manager.getDayProtein, carbs: manager.getDayCarbs, fat: manager.getDayFat)
        fetchDishes()
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
    
    //MARK: - Meals
    func updateMeals(for date: Date) {
        guard let meals = self.meals else { return }
        let dailyMeal = DailyMeal(meals: meals)
        googleService.updateMealBy(date: date, dailyMeal: dailyMeal)
    }
    func fetchMealsBy(date: Date, completion: @escaping () -> ()) {
        googleService.getMealFor(date) { result in
            switch result {
            case .success(let dailyMeal):
                if let dailyMeal = dailyMeal {
                    self.meals = dailyMeal.meals
                    completion()
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
            case .success(let dailyMeal):
                if let dailyMeal = dailyMeal {
                    self.meals = dailyMeal.meals
                } else {
                    self.meals = self.populateMeals(hasPrefer: prefer, numberOfMeals: numberOfMeals, protein: protein, carbs: carbs, fat: fat)
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    //MARK: Dishes
    func fetchDishes() {
        if dishes != nil && dishes!.count > 0 { return }
        
        googleService.getDishes { result in
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
            dishArray = dishes[0]
        case .carbs:
            dishArray = dishes[1]
        case .protein:
            dishArray = dishes[2]
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
