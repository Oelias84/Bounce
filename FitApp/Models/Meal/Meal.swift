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
	case other
}

class Meal: Codable {

    let id: UUID
    var dateString: String
    let mealType: MealType
    var dishes: [Dish]
    var mealDescription: String?
    var isMealDone: Bool
	
	var date: Date {
		get {
			return dateString.dateFromString!
		}
		set {
			dateString = newValue.dateStringForDB
		}
	}
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
		case .other:
			return "ארוחת חריגה"
        }
    }
    
	init(mealType: MealType, dishes: [Dish], date: String = Date().dateStringForDB) {
        self.id = UUID()
        self.mealType = mealType
        self.dateString = date
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

struct MealTarget: Codable {
	
	var carbs: Double
	var fats: Double
	var protein: Double
}

struct DailyMeal: Codable {
    
    let meals: [Meal]
}
