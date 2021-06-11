//
//  MealTypePickerDataSource.swift
//  FitApp
//
//  Created by Ofir Elias on 11/06/2021.
//

import UIKit

class MealTypePickerDataSource: NSObject, UIPickerViewDataSource {
	

	override init() {
		
	}
	func numberOfComponents(in pickerView: UIPickerView) -> Int {
		1
	}
	func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		DishType.allCases.count
	}
}
