//
//  QuestionnaireActivityViewController.swift
//  FitApp
//
//  Created by iOS Bthere on 10/12/2020.
//

import UIKit

class QuestionnaireActivityViewController: UIViewController {
	
	public var isFromSettings = false
	
	@IBOutlet weak var kilometersSlider: UISlider! {
		didSet {
			kilometersSlider.value = 0.0
			kilometersSlider.maximumValue = 25.00
		}
	}
	@IBOutlet weak var stepsSlider: UISlider! {
		didSet {
			stepsSlider.maximumValue = 30000.00
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
	}
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		setUpTextfields()
	}
	
	@IBAction func nextButtonAction(_ sender: Any) {
		
		if kilometersCheckBox.isSelected {
			if let kilometers = kilometersLabel.text?.split(separator: " ").first {
				UserProfile.defaults.kilometer = Double(kilometers)
				UserProfile.defaults.lifeStyle = nil
				UserProfile.defaults.steps = nil
			}
			if isFromSettings {
				updateServer()
			} else {
				performSegue(withIdentifier: K.SegueId.moveToNutrition, sender: self)
			}
		} else if stepsCheckBox.isSelected {
			if let steps = stepsLabel.text {
				UserProfile.defaults.steps = Int(steps)
				UserProfile.defaults.lifeStyle = nil
				UserProfile.defaults.kilometer = nil
			}
			if isFromSettings {
				updateServer()
			} else {
				performSegue(withIdentifier: K.SegueId.moveToNutrition, sender: self)
			}
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
				stepsLabel.text = "0"
				kilometersSlider.isEnabled = true
			case 2:
				kilometersCheckBox.isSelected = false
				stepsSlider.isEnabled = true
				kilometersSlider.isEnabled = false
				kilometersLabel.text =  "0 " + K.Units.kilometers
			default:
				return
			}
		}
		
		(kilometersCheckBox.isSelected || stepsCheckBox.isSelected)
			? nextButton.setTitle(isFromSettings ? "אישור" : "הבא", for: .normal)
			: nextButton.setTitle("דלג", for: .normal)
	}
}

extension QuestionnaireActivityViewController {
	
	private func setUpTextfields() {
		let userData = UserProfile.defaults
		
		if let kilometers = userData.kilometer {
			nextButton.setTitle(isFromSettings ? "אישור" : "הבא", for: .normal)
			kilometersLabel.text = String(kilometers)
			kilometersCheckBox.isSelected = true
			stepsSlider.isEnabled = false
		} else if let steps = userData.steps {
			nextButton.setTitle(isFromSettings ? "אישור" : "הבא", for: .normal)
			stepsLabel.text = String(steps)
			stepsCheckBox.isSelected = true
			kilometersSlider.isEnabled = false
		}
	}
	private func updateServer() {
		UserProfile.updateServer()
		navigationController?.popViewController(animated: true)
	}
	
	private func stepsAndKilometersOff() {
		kilometersCheckBox.isSelected = false
		kilometersSlider.isEnabled = false
		stepsCheckBox.isSelected = false
		stepsSlider.isEnabled = false
	}
}
