//
//  QuestionnaireSecondActivityViewControllerViewController.swift
//  FitApp
//
//  Created by Ofir Elias on 18/02/2021.
//

import UIKit

class QuestionnaireSecondActivityViewController: UIViewController {
	
	public var isFromSettings = false
	private var lifeStyleSelection: Int?

	@IBOutlet weak var sittingCheckBox: UIButton!
	@IBOutlet weak var semiActiveCheckBox: UIButton!
	@IBOutlet weak var activeCheckBox: UIButton!
	@IBOutlet weak var veryActiveCheckBox: UIButton!
	@IBOutlet weak var nextButton: UIButton!
	

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		setUpTextfields()
	}
	
	@IBAction func nextButtonAction(_ sender: Any) {
		
		if let lifeStyle = lifeStyleSelection {
			UserProfile.defaults.steps = nil
			UserProfile.defaults.kilometer = nil
			UserProfile.defaults.lifeStyle = getLifeStyle(for: lifeStyle)
			if isFromSettings {
				updateServer()
			} else {
				performSegue(withIdentifier: K.SegueId.moveToNutrition, sender: self)
			}
		}
	}
	@IBAction func checkBoxAction(_ sender: UIButton) {
		sender.isSelected = !sender.isSelected
		switch sender.tag {
		case 1:
			semiActiveCheckBox.isSelected = false
			activeCheckBox.isSelected = false
			veryActiveCheckBox.isSelected = false
		case 2:
			sittingCheckBox.isSelected = false
			activeCheckBox.isSelected = false
			veryActiveCheckBox.isSelected = false
		case 3:
			sittingCheckBox.isSelected = false
			semiActiveCheckBox.isSelected = false
			veryActiveCheckBox.isSelected = false
		case 4:
			sittingCheckBox.isSelected = false
			semiActiveCheckBox.isSelected = false
			activeCheckBox.isSelected = false
		default:
			break
		}
		lifeStyleSelection = sender.tag
		UserProfile.defaults.lifeStyle = getLifeStyle(for: lifeStyleSelection!)
	}
}

extension QuestionnaireSecondActivityViewController {
	
	private func updateServer() {
		UserProfile.updateServer()
		if let firstViewController = self.navigationController?.viewControllers[1] {
			self.navigationController?.popToViewController(firstViewController, animated: true)
		}
	}
	private func setUpTextfields() {
		nextButton.setTitle(isFromSettings ? "אישור" : "הבא", for: .normal)
		if let lifeStyle = UserProfile.defaults.lifeStyle {
			getLifeStyleCheckBox(for: lifeStyle)
		}
	}
	private func getLifeStyle(for lifestyle: Int) -> Double {
		switch lifestyle {
		case 1:
			return 1.2
		case 2:
			return 1.3
		case 3:
			return 1.5
		case 4:
			return 1.6
		default:
			return 0.0
		}
	}
	private func getLifeStyleCheckBox(for lifestyle: Double) {
		switch lifestyle {
		case 1.2:
			sittingCheckBox.isSelected = true
			lifeStyleSelection = 1
		case 1.3:
			semiActiveCheckBox.isSelected = true
			lifeStyleSelection = 2
		case 1.5:
			activeCheckBox.isSelected = true
			lifeStyleSelection = 3
		case 1.6:
			veryActiveCheckBox.isSelected = true
			lifeStyleSelection = 4
		default:
			break
		}
	}
}
