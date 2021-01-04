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

    private let id: UUID
    private var dishName: String
    var type: DishType
    var amount: Double
    var isDishDone: Bool
    
    init(name: String, type: DishType, amount: Double) {
        self.id = UUID()
        self.dishName = name
        self.type = type
        self.amount = amount
        self.isDishDone = false
    }
    
    var getDishName: String {
        self.dishName
    }
    var printAmount: String {
        String(format: "%.2f", self.amount)
    }
    var printDishType: String {
        self.type.rawValue
    }
}

extension Dish: Comparable {

    static func < (lhs: Dish, rhs: Dish) -> Bool {
        false
    }
    static func == (lhs: Dish, rhs: Dish) -> Bool {
        lhs.id == rhs.id
    }
}
