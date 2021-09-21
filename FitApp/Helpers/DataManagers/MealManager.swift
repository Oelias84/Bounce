//
//  MealManager.swift
//  FitApp
//
//  Created by Ofir Elias on 10/06/2021.
//

import UIKit

class MealManager {
	
	static let shared = MealManager()
	private var dishesNames: [[ServerDish]]?

	private init() {
		fetchDishes()
	}
	
	
	//MARK: - Dishes
	func fetchDishes() {
		if dishesNames != nil && dishesNames!.count > 0 { return }
		
		GoogleApiManager.shared.getDishes { result in
			switch result {
			case .success(let dishes):
				if let dishes = dishes {
					self.dishesNames = dishes
				} else {
					return
				}
			case .failure(let error):
				print(error)
			}
		}
	}
	func getDishesFor(type: DishType) -> [ServerDish] {
		var dishArray: [ServerDish] = []
		guard let dishes = self.dishesNames else { return [] }
		
		switch type {
		case .fat:
			dishArray = dishes[0].sorted()
		case .carbs:
			dishArray = dishes[1].sorted()
		case .protein:
			dishArray = dishes[2].sorted()
		}
		return dishArray
	}
}
