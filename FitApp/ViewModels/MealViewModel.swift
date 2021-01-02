//
//  MealViewModel.swift
//  FitApp
//
//  Created by iOS Bthere on 01/01/2021.
//

import Foundation

struct MealViewModel {
    
    var meals: [Meal]!
    
    init(Prefer: Int?, numberOfMeals: Int, protein: Double, carbs: Double, fat: Double) {
        
        self.meals = self.populateMeals(hasPrefer: Prefer, numberOfMeals: numberOfMeals, protein: protein, carbs: carbs, fat: fat)
    }
    
    func roundHalfDown(_ x: Double) -> Double {
        let friction = x.fraction
        let whole = x.whole.nextDown.rounded()
        
        if friction > 0.0 && friction < 0.5 {
            return whole
        } else if friction > 0.5 && friction < whole+1 {
            return whole + 0.5
        }
        return x
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
    func mealDishesDivider(hasPrefer: Bool, numberOfDishes: Double) -> (Double, Double) {
        let reducer = 0.5
        let numberOfMeals = 3
        let isDividable = (numberOfDishes / Double(numberOfMeals)).isWholeNumber
        var dishesForMeal = 0.0
        var reminder = 0.0
        
        if hasPrefer {
            switch numberOfMeals {
            case 3:
                if isDividable {
                    let numberOfDishesLessOne = numberOfDishes-reducer
                    dishesForMeal = roundHalfDown(numberOfDishesLessOne / Double(numberOfMeals))
                    reminder = numberOfDishesLessOne - (dishesForMeal * Double(numberOfMeals)) + reducer
                } else {
                    dishesForMeal = roundHalfDown(numberOfDishes / Double(numberOfMeals))
                    reminder = numberOfDishes - (dishesForMeal * Double(numberOfMeals))
                }
            default:
                break
            }
        } else {
            if isDividable { return (numberOfDishes/Double(numberOfMeals), reminder) }
            switch numberOfMeals {
            case 3:
                dishesForMeal = roundHalfDown(numberOfDishes / Double(numberOfMeals))
                reminder = numberOfDishes - (dishesForMeal * Double(numberOfMeals))
            default:
                break
            }
        }
        return (dishesForMeal, reminder)
    }
    func populateMeals(hasPrefer: Int?, numberOfMeals: Int, protein: Double, carbs: Double, fat: Double) -> [Meal] {
        var dayMeals = [Meal(meaType: .breakfast, dishes: []), Meal(meaType: .lunch, dishes: []), Meal(meaType: .supper, dishes: [])]
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
            let preferredMeal = MealType(rawValue: prefer)
            if let addToPreferred = dayMeals.first(where: {$0.mealType == preferredMeal}) {
                addToPreferred.dishes.forEach { dish in
                    switch dish.type {
                    case .carbs: dish.amount += carbsForMeal.1
                    case .protein: dish.amount += proteinForMeal.1
                    case .fat: dish.amount += fatForMeal.1
                    }
                }
            }
        }
        if numberOfMeals == 4 {
            dayMeals.append(Meal(meaType: .middle1, dishes: [Dish(name: "ביצים", type: .carbs, amount: 1)]))
        } else if numberOfMeals == 5 {
            dayMeals.append(Meal(meaType: .middle1, dishes: [Dish(name: "טונה", type: .protein, amount: 1), Dish(name: "ליה", type: .fat, amount: 0.5)]))
        }
        return dayMeals.sorted()
    }
}
