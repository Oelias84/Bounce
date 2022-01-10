//
//  QuestionnaireActivityViewController.swift
//  FitApp
//
//  Created by iOS Bthere on 10/12/2020.
//

import UIKit

class QuestionnaireActivityViewController: UIViewController {
	
	public var isFromSettings = false
	private var minimumKilometers: Float = 0.1
	private var minimumSteps: Int = 100
	
	@IBOutlet weak var titleTextLabel: UILabel!
	@IBOutlet weak var dontKnowTextLabel: UILabel!
	@IBOutlet weak var kilometersSlider: UISlider! {
		didSet {
			kilometersSlider.value = minimumKilometers
			kilometersSlider.minimumValue = minimumKilometers
			kilometersSlider.maximumValue = 25.00
		}
	}
	@IBOutlet weak var stepsSlider: UISlider! {
		didSet {
			stepsSlider.value = minimumKilometers
			stepsSlider.minimumValue = Float(minimumSteps)
			stepsSlider.maximumValue = 30000.0
		}
	}
	@IBOutlet weak var kilometersLabel: UILabel!
	@IBOutlet weak var stepsLabel: UILabel!
	@IBOutlet weak var kilometersCheckBox: UIButton!
	@IBOutlet weak var stepsCheckBox: UIButton!
	@IBOutlet weak var nextButton: UIButton!
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == K.SegueId.moveToSecondActivity {
			let QuestionnaireSecondActivityVC = segue.destination as! QuestionnaireSecondActivityViewController
			QuestionnaireSecondActivityVC.isFromSettings = isFromSettings
		}
	}
	override func viewDidLoad() {
		super.viewDidLoad()
		
		navigationItem.setHidesBackButton(true, animated: false)
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		setUpTextfields()
	}
	
	@IBAction func backButtonAction(_ sender: Any) {
		navigationController?.popViewController(animated: true)
	}
	@IBAction func nextButtonAction(_ sender: Any) {
		
		if kilometersCheckBox.isSelected {
			if let kilometers = kilometersLabel.text?.split(separator: " ").first {
				UserProfile.defaults.kilometer = Double(kilometers)
				UserProfile.defaults.lifeStyle = nil
				UserProfile.defaults.steps = nil
			}
			shouldMoveToNutrition()
		} else if stepsCheckBox.isSelected {
			if let steps = stepsLabel.text {
				UserProfile.defaults.steps = Int(steps)
				UserProfile.defaults.lifeStyle = nil
				if self.isFromSettings {
					let userData = UserProfile.defaults
					UserProfile.defaults.kilometer = ConsumptionManager.shared.stepsToKilometers(steps: userData.steps! , height: userData.height!)
				} else {
					UserProfile.defaults.kilometer = nil
				}
			}
			shouldMoveToNutrition()
		} else {
			performSegue(withIdentifier: K.SegueId.moveToSecondActivity, sender: self)
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
		
		if sender.isSelected {
			switch sender.tag {
			case 1:
				stepsCheckBox.isSelected = false
				stepsSlider.isEnabled = false
				stepsLabel.text = String(minimumSteps)
				kilometersSlider.isEnabled = true
			case 2:
				kilometersCheckBox.isSelected = false
				stepsSlider.isEnabled = true
				kilometersSlider.isEnabled = false
				kilometersLabel.text =  String(minimumKilometers) + " " + K.Units.kilometers
			default:
				return
			}
		}
	}
}

extension QuestionnaireActivityViewController {
	
	private func setUpTextfields() {
		
		titleTextLabel.text = StaticStringsManager.shared.getGenderString?[5]
		dontKnowTextLabel.text = StaticStringsManager.shared.getGenderString?[6]
		
		let userData = UserProfile.defaults
		
		if let steps = userData.steps {
			stepsLabel.text = String(steps)
			stepsCheckBox.isSelected = true
			kilometersSlider.isEnabled = false
		} else if let kilometers = userData.kilometer {
			kilometersLabel.text = String(kilometers)
			kilometersCheckBox.isSelected = true
			stepsSlider.isEnabled = false
		} else {
			kilometersLabel.text = String(minimumKilometers) + " " + K.Units.kilometers
			stepsLabel.text = String(minimumSteps)
		}
	}
	private func updateServer() {
		UserProfile.updateServer()
		navigationController?.popViewController(animated: true)
	}
	private func shouldMoveToNutrition() {
		if isFromSettings {
			updateServer()
		} else {
			performSegue(withIdentifier: K.SegueId.moveToNutrition, sender: self)
		}
	}
	private func stepsAndKilometersOff() {
		kilometersCheckBox.isSelected = false
		kilometersSlider.isEnabled = false
		stepsCheckBox.isSelected = false
		stepsSlider.isEnabled = false
	}
}
