//
//  QuestionnaireFitnessLevelViewController.swift
//  FitApp
//
//  Created by iOS Bthere on 10/12/2020.
//

import UIKit

class QuestionnaireFitnessLevelViewController: UIViewController {
	
	var fitnessLevel = 0
	var weaklyWorkouts = 0
	
	@IBOutlet weak var beginnerButton: UIButton!
	@IBOutlet weak var intermediateButton: UIButton!
	@IBOutlet weak var advancedButton: UIButton!
	
	@IBOutlet weak var weaklyWorkoutCheckFirst: UIButton!
	@IBOutlet weak var weaklyWorkoutCheckSecond: UIButton!
	@IBOutlet weak var weaklyWorkoutCheckThird: UIButton!
    
	@IBOutlet weak var nextButton: UIButton!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
	}
	
	@IBAction func nextButtonAction(_ sender: Any) {
		if fitnessLevel != 0 && weaklyWorkouts != 0 {
			UserProfile.defaults.fitnessLevel = fitnessLevel
			UserProfile.defaults.weaklyWorkouts = weaklyWorkouts
			performSegue(withIdentifier: K.SegueId.moveToSumup, sender: self)
		} else {
			//show alert
			return
		}
	}
	@IBAction func levelCheckBoxes(sender: UIButton) {
		sender.isSelected = !sender.isSelected
		fitnessLevel = sender.tag
		
		switch sender.tag {
		case 1:
			intermediateButton.isSelected = false
			advancedButton.isSelected = false
		case 2:
			beginnerButton.isSelected = false
			advancedButton.isSelected = false
		case 3:
			beginnerButton.isSelected = false
			intermediateButton.isSelected = false
		default:
			return
		}
		if !sender.isSelected {
			fitnessLevel = 0
		}
	}
	@IBAction func weaklyWorkoutsCheckBoxes(sender: UIButton) {
		sender.isSelected = !sender.isSelected
		
		switch sender.tag {
		case 1:
			weaklyWorkouts = 3
			if sender.isSelected{
				weaklyWorkoutCheckSecond.isSelected = false
				weaklyWorkoutCheckThird.isSelected = false
			}
		case 2:
			weaklyWorkouts = 4
			if sender.isSelected{
				weaklyWorkoutCheckFirst.isSelected = false
				weaklyWorkoutCheckThird.isSelected = false
			}
		case 3:
			weaklyWorkouts = 5
			if sender.isSelected{
				weaklyWorkoutCheckFirst.isSelected = false
				weaklyWorkoutCheckSecond.isSelected = false
			}
		case 4:
			weaklyWorkouts = 6
			if sender.isSelected{
				weaklyWorkoutCheckFirst.isSelected = false
				weaklyWorkoutCheckSecond.isSelected = false
				weaklyWorkoutCheckThird.isSelected = false
			}
		default:
			return
		}
		if !sender.isSelected {
			weaklyWorkouts = 0
		}
	}
}
