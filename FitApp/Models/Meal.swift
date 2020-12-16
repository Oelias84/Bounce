//
//  Meal.swift
//  FitApp
//
//  Created by iOS Bthere on 15/12/2020.
//

import Foundation

class Meal {
    
    var name: String
    var dishes: [Dish]
    var mealDescription: String?
    var isMealDone: Bool
    
    init(name: String, dishes: [Dish]) {
        self.name = name
        self.dishes = dishes
        self.isMealDone = false
    }
}
