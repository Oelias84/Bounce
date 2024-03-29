//
//  Dish.swift
//  FitApp
//
//  Created by iOS Bthere on 15/12/2020.
//

import Foundation

enum DishType: String, CaseIterable, Codable {
    
    case protein = "חלבון"
    case carbs = "פחמימה"
    case fat = "שומן"
    
    enum CodingKeys: String, CodingKey {
        case protein
        case carbs
        case fat
    }
}

class Dish: Codable  {

    private let id: UUID
    private var dishName: String
    var type: DishType
    var amount: Double
    var isDishDone: Bool
    
	init(name: String, type: DishType, amount: Double, isDishDone: Bool = false) {
        self.id = UUID()
        self.dishName = name
        self.type = type
        self.amount = amount
        self.isDishDone = isDishDone
    }
    
    var getDishName: String {
        self.dishName
    }
    var printAmount: String {
        String(format: "%.2f", self.amount)
    }
    var printDishType: String {
		return self.type.rawValue
    }
    
    func setName(name: String) {
        self.dishName = name
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
