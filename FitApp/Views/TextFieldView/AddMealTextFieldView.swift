//
//  AddMealTextFieldView.swift
//  FitApp
//
//  Created by Ofir Elias on 11/01/2022.
//
import UIKit
import Foundation

class AddMealTextFieldView: UITextField {
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		
		borderStyle = .none
		layer.cornerRadius = 5
		layer.borderWidth = 1
		layer.borderColor = UIColor.projectTail.cgColor
	}
}
