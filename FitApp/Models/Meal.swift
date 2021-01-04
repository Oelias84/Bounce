//
//  Meal.swift
//  FitApp
//
//  Created by iOS Bthere on 15/12/2020.
//

import Foundation

enum MealType: Int{
    
    case breakfast
    case middle1
    case lunch
    case middle2
    case supper
}

class Meal: Comparable {

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
            return "ארוחת ביניית 2"
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
    
    static func < (lhs: Meal, rhs: Meal) -> Bool {
        lhs.date < rhs.date
    }
    
    static func == (lhs: Meal, rhs: Meal) -> Bool {
        lhs.id == rhs.id
    }
}
