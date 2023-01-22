//
//  AddMealTextFieldView.swift
//  FitApp
//
//  Created by Ofir Elias on 11/01/2022.
//
import UIKit
import Foundation

class AddMealTextFieldView: UITextField {
	
	public var shouldPerformAction: Bool = true

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		
		borderStyle = .none
		layer.cornerRadius = 5
		layer.borderWidth = 1
		layer.borderColor = UIColor.projectTail.cgColor
	}
	
	override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
		shouldPerformAction
	}
}
