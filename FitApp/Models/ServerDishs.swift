//
//  ServerDish.swift
//  FitApp
//
//  Created by iOS Bthere on 07/01/2021.
//

import Foundation

struct ServerDish: Codable {
    
    let name: String
}

struct ServerDishes: Codable {
    
    let carbs: [ServerDish]
    let fat: [ServerDish]
    let protein: [ServerDish]
}
