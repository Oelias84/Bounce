//
//  QuestionnaireGanderViewController.swift
//  FitApp
//
//  Created by Ofir Elias on 31/12/2021.
//

import Foundation
import UIKit

enum UserGender: Int {
	
	case women = 1
	case men = 2
}

class QuestionnaireGanderViewController: UIViewController {
	
	var gender: UserGender?

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
			presentOkAlert(withTitle: "אופס",withMessage: "יש לבחור מגדר") {
				return
			}
		} else {
			UserProfile.defaults.userGander = gender?.rawValue
			performSegue(withIdentifier: K.SegueId.moveToFatPercentage, sender: self)
		}
	}
	@IBAction func backButtonAction(_ sender: Any) {
		navigationController?.popViewController(animated: true)
	}

	private func setUpCheckBox() {
		let userData = UserProfile.defaults
		
		if let gender = userData.userGander {
			
			switch gender {
			case 1:
				self.gender = .women
				womenCheckBoxButton.isSelected = true
			case 2:
				self.gender = .men
				menCheckBoxButton.isSelected = true
			default:
				break
			}
		}
	}
	private func userSelect(_ sender: UIButton) {
		
		switch sender {
		case womenCheckBoxButton:
			gender = .women
			menCheckBoxButton.isSelected = false
		case menCheckBoxButton:
			gender = .men
			womenCheckBoxButton.isSelected = false
		default :
			break
		}
	}
}
