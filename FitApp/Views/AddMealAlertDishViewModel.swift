//
//  AddMealAlertDishViewModel.swift
//  FitApp
//
//  Created by Ofir Elias on 24/10/2022.
//

import Foundation

struct AddMealAlertDishViewModel {
	
	let dish = Dish(name: "", type: .protein, amount: 0.0)
	private let typeNames: [String] = DishType.allCases.map { $0.rawValue }
	private let halfNumbers: [Double] = K.Arrays.halfNumbers
	
	// Getters
	func getPickerCount(for pickerView: Int) -> Int {
		switch pickerView {
		case 0:
			return typeNames.count
		case 1:
			return halfNumbers.count
		default:
			return 0
		}
	}
	func getTitle(for pickerView:  Int, in row: Int) -> String? {
		switch pickerView {
		case 0:
			return typeNames[row]
		case 1:
			return "\(halfNumbers[row])"
		default:
			return nil
		}
	}
	func getDishName(for row: Int) -> String {
		typeNames[row]
	}
	func getHalfNumber(for row: Int) -> Double {
		halfNumbers[row]
	}
}
