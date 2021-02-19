//
//  ExerciseCategoryView.swift
//  FitApp
//
//  Created by Ofir Elias on 19/02/2021.
//

import UIKit

class ExerciseCategoryView: UIView {
	
	var type: String! {
		didSet {
			commonInit(type: self.type)
		}
	}
	
	@IBOutlet weak var exerciseCategoryBackgroundView: UIView!
	@IBOutlet weak var exerciseCategoryTextLabel: UILabel!
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	private func commonInit(type: String) {
		
		switch type {
		case "legs":
			exerciseCategoryTextLabel.text = "רגליים"
			exerciseCategoryBackgroundView.backgroundColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
		case "chest":
			exerciseCategoryTextLabel.text = "חזה"
			exerciseCategoryBackgroundView.backgroundColor = #colorLiteral(red: 0.1863320172, green: 0.6013119817, blue: 0.9211298823, alpha: 1)
		case "back":
			exerciseCategoryTextLabel.text = "גב"
			exerciseCategoryBackgroundView.backgroundColor = #colorLiteral(red: 1, green: 0.5763723254, blue: 0, alpha: 1)
		case "shoulders":
			exerciseCategoryTextLabel.text = "כתפיים"
			exerciseCategoryBackgroundView.backgroundColor = #colorLiteral(red: 0.9686274529, green: 0.78039217, blue: 0.3450980484, alpha: 1)
		case "stomach":
			exerciseCategoryTextLabel.text = "בטן"
			exerciseCategoryBackgroundView.backgroundColor = #colorLiteral(red: 0.5791940689, green: 0.1280144453, blue: 0.5726861358, alpha: 1)
		case "warmup":
			exerciseCategoryTextLabel.text = "חימום"
			exerciseCategoryBackgroundView.backgroundColor = #colorLiteral(red: 0.5741485357, green: 0.5741624236, blue: 0.574154973, alpha: 1)
		default:
			break
		}
	}
}
