//
//  DIsh.swift
//  FitApp
//
//  Created by iOS Bthere on 15/12/2020.
//

import Foundation

enum DishType: String {
    
    case protein = "חלבון"
    case carbs = "פחממה"
    case fat = "שומן"
}

class Dish {
    
    var dishName: String
    var type: DishType
    var amount: Int
    var isDishDone: Bool
    
    init(name: String, type: DishType, amount: Int) {
        self.dishName = name
        self.type = type
        self.amount = amount
        self.isDishDone = false
    }
}
