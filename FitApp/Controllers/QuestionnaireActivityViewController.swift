//
//  QuestionnaireActivityViewController.swift
//  FitApp
//
//  Created by iOS Bthere on 10/12/2020.
//

import UIKit

class QuestionnaireActivityViewController: UIViewController {
	
	private var isFromQuestionnaire: Bool!
	
	@IBOutlet weak var kilometresSlider: UISlider! {
		didSet {
			kilometresSlider.maximumValue = 100.00
		}
	}
	@IBOutlet weak var stepsSlider: UISlider! {
		didSet {
			stepsSlider.maximumValue = 10000.00
		}
	}
	@IBOutlet weak var currentPageLabel: UILabel!
	@IBOutlet weak var kilometersLabel: UILabel!
	@IBOutlet weak var stepsLabel: UILabel!
	@IBOutlet weak var kilometersCheckBox: UIButton!
	@IBOutlet weak var stepsCheckBox: UIButton!
	@IBOutlet weak var nextButton: UIButton!
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		if !isFromQuestionnaire {
			nextButton.setTitle("אישור", for: .normal)
			currentPageLabel.isHidden = true
		}
	}
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		setUpTextfields()
		isFromQuestionnaire = parent?.restorationIdentifier == K.NavigationId.QuestionnaireNavigation
	}
	
	@IBAction func nextButtonAction(_ sender: Any) {
		
		
			if kilometersCheckBox.isSelected {
				if let kilometers = kilometersLabel.text?.split(separator: " ").first {
					UserProfile.defaults.kilometer = Double(kilometers)
					UserProfile.defaults.steps = nil
				}
				if isFromQuestionnaire {
				
				} else {
					performSegue(withIdentifier: K.SegueId.moveToNutrition, sender: self)
				}
			} else if stepsCheckBox.isSelected {
				if let steps = stepsLabel.text {
					UserProfile.defaults.steps = Int(steps)
				}
				if isFromQuestionnaire {
				
				} else {
					performSegue(withIdentifier: K.SegueId.moveToNutrition, sender: self)
				}
			} else {
				navigationController?.popViewController(animated: true)
			}
	}
	@IBAction func kilometersSliderAction(_ sender: UISlider) {
		kilometersLabel.text = String(format: "%.1f", sender.value) + " " + K.Units.kilometers
	}
	@IBAction func stepsSliderAction(_ sender: UISlider) {
		stepsLabel.text = String(format: "%.0f", sender.value)
	}
	@IBAction func checkBoxes(sender: UIButton) {
		sender.isSelected = !sender.isSelected
		
		switch sender.tag {
		case 1:
			if sender.isSelected {
				stepsCheckBox.isSelected = false
			}
		case 2:
			if sender.isSelected {
				kilometersCheckBox.isSelected = false
			}
		default:
			return
		}
		
		(kilometersCheckBox.isSelected || stepsCheckBox.isSelected)
			? nextButton.setTitle("הבא", for: .normal)
			: nextButton.setTitle("דלג", for: .normal)
	}
}

extension QuestionnaireActivityViewController {
	
	func setUpTextfields() {
		let userData = UserProfile.defaults
		
		if let kilometers = userData.kilometer {
			kilometersLabel.text = String(kilometers)
			kilometersCheckBox.isSelected = true
		} else if let steps = userData.steps {
			stepsLabel.text = String(steps)
			stepsCheckBox.isSelected = true
		}
	}
	
	func updateData() {
		let userData = UserProfile.defaults
		let manager = GoogleApiManager()
		let data = ServerUserData(name: userData.name!, birthDate: userData.birthDate!.dateStringForDB, weight: userData.weight!, height: userData.height!, fatPercentage: userData.fatPercentage!, steps: userData.steps, kilometer: userData.kilometer, mealsPerDay: userData.mealsPerDay!, mostHungry: userData.mostHungry!, fitnessLevel: userData.fitnessLevel!, weaklyWorkouts: userData.weaklyWorkouts!, finishOnboarding: true)
		
		manager.updateUserData(userData: data)
	}
}
