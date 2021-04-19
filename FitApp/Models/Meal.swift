//
//  Meal.swift
//  FitApp
//
//  Created by iOS Bthere on 15/12/2020.
//

import Foundation

enum MealType: Int, Codable {
    
    case breakfast
    case middle1
    case lunch
    case middle2
    case supper
}

class Meal: Codable {

    let id: UUID
    let date: Date
    let mealType: MealType
    var dishes: [Dish]
    var mealDescription: String?
    var isMealDone: Bool
    
    var name: String {
        switch mealType {
        case .breakfast:
            return "ארוחת בוקר"
        case .middle1:
            return "ארוחת ביניים 1"
        case .lunch:
            return "ארוחת צהריים"
        case .middle2:
            return "ארוחת ביניים 2"
        case .supper:
            return "ארוחת ערב"
        }
    }
    
    init(mealType: MealType, dishes: [Dish]) {
        self.id = UUID()
        self.mealType = mealType
        self.date = Date()
        self.dishes = dishes
        self.isMealDone = false
    }
}

extension Meal: Comparable {
    
    static func < (lhs: Meal, rhs: Meal) -> Bool {
        lhs.date < rhs.date
    }
    static func == (lhs: Meal, rhs: Meal) -> Bool {
        lhs.id == rhs.id
    }
}

struct MealProgress: Codable {
    
    var carbs: Double
    var fats: Double
    var protein: Double
}

struct DailyMeal: Codable {
    
    let meals: [Meal]
}
