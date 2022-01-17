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
		sender.isSelected = !sender.isSelected
		userSelect(sender)
	}
	@IBAction func menCheckBoxButtonAction(_ sender: UIButton) {
		sender.isSelected = !sender.isSelected
		userSelect(sender)
	}
	@IBAction func continueButtonAction(_ sender: UIButton) {
		if gender == nil {
			presentOkAlert(withTitle: "אופס",withMessage: "יש לבחור מגדר")
			return
		} else {
			UserProfile.defaults.gender = gender?.rawValue
			performSegue(withIdentifier: K.SegueId.moveToFatPercentage, sender: self)
		}
	}
	@IBAction func backButtonAction(_ sender: Any) {
		navigationController?.popViewController(animated: true)
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
			menCheckBoxButton.isSelected = false
		case menCheckBoxButton:
			gender = .male
			womenCheckBoxButton.isSelected = false
		default :
			break
		}
	}
}
