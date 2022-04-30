//
//  QuestionnaireGanderViewController.swift
//  FitApp
//
//  Created by Ofir Elias on 31/12/2021.
//

import Foundation
import UIKit

class QuestionnaireGanderViewController: UIViewController {
	
	var gender: Gender?

	@IBOutlet weak var womenCheckBoxButton: UIButton!
	@IBOutlet weak var menCheckBoxButton: UIButton!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		navigationItem.setHidesBackButton(true, animated: false)

		setUpCheckBox()
	}
	
	@IBAction func womenCheckBoxButtonAction(_ sender: UIButton) {
		userSelect(womenCheckBoxButton)
	}
	@IBAction func menCheckBoxButtonAction(_ sender: UIButton) {
		userSelect(menCheckBoxButton)
	}
	@IBAction func continueButtonAction(_ sender: UIButton) {
		if gender == nil {
			presentOkAlert(withTitle: "אופס",withMessage: "יש לבחור מגדר")
			return
		} else {
			UserProfile.defaults.gender = gender?.rawValue
			performSegue(withIdentifier: K.SegueId.moveToPersonalDetails, sender: self)
		}
	}
	
	private func setUpCheckBox() {
		let userData = UserProfile.defaults
		
		if let gender = userData.getGender {
			self.gender = gender
			switch gender {
			case .female:
				womenCheckBoxButton.isSelected = true
			case .male:
				menCheckBoxButton.isSelected = true
			}
		}
	}
	private func userSelect(_ sender: UIButton) {
		
		switch sender {
		case womenCheckBoxButton:
			gender = .female
			womenCheckBoxButton.isSelected = true
			menCheckBoxButton.isSelected = false
		case menCheckBoxButton:
			gender = .male
			womenCheckBoxButton.isSelected = false
			menCheckBoxButton.isSelected = true
		default :
			break
		}
	}
}
