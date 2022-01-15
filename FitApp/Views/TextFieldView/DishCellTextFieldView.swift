//
//  DishCellTextFieldView.swift
//  FitApp
//
//  Created by Ofir Elias on 15/01/2022.
//

import Foundation

import UIKit
import Foundation

class DishCellTextFieldView: UITextField {
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		
		borderStyle = .none
		layer.cornerRadius = 5
		layer.borderWidth = 1
		layer.borderColor = UIColor.black.cgColor
	}
}
