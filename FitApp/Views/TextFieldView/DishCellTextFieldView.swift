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
	
	public var shouldPerformAction: Bool = true

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
			
		tintColor = .clear
		borderStyle = .none
		layer.cornerRadius = 5
		layer.borderWidth = 1
		layer.borderColor = UIColor.black.cgColor
	}
	
	override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
		shouldPerformAction
	}
}
