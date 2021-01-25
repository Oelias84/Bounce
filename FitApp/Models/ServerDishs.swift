//
//  ServerDish.swift
//  FitApp
//
//  Created by iOS Bthere on 07/01/2021.
//

import Foundation

struct ServerDish: Codable, Comparable {

    let name: String

	static func < (lhs: ServerDish, rhs: ServerDish) -> Bool {
		lhs.name < rhs.name
	}
}

struct ServerDishes: Codable {
    
    let carbs: [ServerDish]
    let fat: [ServerDish]
    let protein: [ServerDish]
}
