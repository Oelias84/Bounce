//
//  QuestionnaireFitnessLevelViewController.swift
//  FitApp
//
//  Created by iOS Bthere on 10/12/2020.
//

import UIKit
import GMStepper

class QuestionnaireFitnessLevelViewController: UIViewController {
	
	var fitnessLevel = 0
	var weaklyWorkouts = 0
	var externalWorkouts = 0
	
	@IBOutlet weak var beginnerButton: UIButton!
	@IBOutlet weak var intermediateButton: UIButton!
	@IBOutlet weak var advancedButton: UIButton!
	
	@IBOutlet weak var weeklyWorkoutCheckFirst: UIButton!
	@IBOutlet weak var weeklyWorkoutCheckSecond: UIButton!
	@IBOutlet weak var weeklyWorkoutCheckThird: UIButton!
	@IBOutlet weak var externalTrainingStepper: GMStepper!
	
	@IBOutlet weak var nextButton: UIButton!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		navigationItem.setHidesBackButton(true, animated: false)
	}
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		setupView()
		setupCheckMarks()
	}
	
	@IBAction func backButtonAction(_ sender: Any) {
		navigationController?.popViewController(animated: true)
	}
	@IBAction func nextButtonAction(_ sender: Any) {
		
		if fitnessLevel != 0 && weaklyWorkouts != 0 {
			UserProfile.defaults.fitnessLevel = fitnessLevel
			UserProfile.defaults.weaklyWorkouts = weaklyWorkouts
			UserProfile.defaults.externalWorkout = externalWorkouts
			performSegue(withIdentifier: K.SegueId.moveToSumup, sender: self)
		} else {
			presentOkAlert(withTitle: "אופס",withMessage: "נראה כי לא נעשתה בחירה, יש לבחור רמת קושי ולאחר מכן מספר אימונים", buttonText: "הבנתי") {
				return
			}
		}
	}
	@IBAction func levelCheckBoxes(sender: UIButton) {
		fitnessLevel = sender.tag

		switch sender {
		case beginnerButton:
			beginnerButton.isSelected = true
			intermediateButton.isSelected = false
			advancedButton.isSelected = false
			
			weeklyWorkoutCheckFirst.backgroundColor = .projectTail
			weeklyWorkoutCheckFirst.borderColorV = .projectTail
			weeklyWorkoutCheckSecond.borderColorV = .white
			weeklyWorkoutCheckThird.borderColorV = .white
			weeklyWorkoutCheckSecond.backgroundColor = .clear
			weeklyWorkoutCheckThird.backgroundColor = .clear
			weaklyWorkouts = 2
		case intermediateButton:
			beginnerButton.isSelected = false
			intermediateButton.isSelected = true
			advancedButton.isSelected = false

			weeklyWorkoutCheckFirst.backgroundColor = .clear
			weeklyWorkoutCheckFirst.borderColorV = .white
			weaklyWorkouts = 0
		case advancedButton:
			beginnerButton.isSelected = false
			intermediateButton.isSelected = false
			advancedButton.isSelected = true

			weeklyWorkoutCheckFirst.backgroundColor = .clear
			weeklyWorkoutCheckFirst.borderColorV = .white
			weaklyWorkouts = 0
		default:
			return
		}
		if !sender.isSelected {
			fitnessLevel = 0
		}
		hideUnnecessaryWeeklySelectionOptions(sender.tag)
	}
	@IBAction func weeklyWorkoutsButtonsAction(sender: UIButton) {
		sender.isSelected = !sender.isSelected
		
        if fitnessLevel == 0 {
            presentOkAlert(withMessage: "יש לבחור קודם את רמת הכושר") {}
			weeklyWorkoutCheckFirst.isSelected = false
			weeklyWorkoutCheckSecond.isSelected = false
			weeklyWorkoutCheckThird.isSelected = false
            return
        }
		sender.backgroundColor = .projectTail
		sender.borderColorV = .projectTail
		
		switch sender {
		case weeklyWorkoutCheckFirst:
			weeklyWorkoutCheckSecond.borderColorV = .white
			weeklyWorkoutCheckThird.borderColorV = .white
			weeklyWorkoutCheckSecond.backgroundColor = .clear
			weeklyWorkoutCheckThird.backgroundColor = .clear
			weaklyWorkouts = 2
		case weeklyWorkoutCheckSecond:
			weeklyWorkoutCheckFirst.borderColorV = .white
			weeklyWorkoutCheckThird.borderColorV = .white
			weeklyWorkoutCheckFirst.backgroundColor = .clear
			weeklyWorkoutCheckThird.backgroundColor = .clear
			weaklyWorkouts = 3
		case weeklyWorkoutCheckThird:
			weeklyWorkoutCheckFirst.borderColorV = .white
			weeklyWorkoutCheckSecond.borderColorV = .white
			weeklyWorkoutCheckFirst.backgroundColor = .clear
			weeklyWorkoutCheckSecond.backgroundColor = .clear
			weaklyWorkouts = 4
		default:
			return
		}
		if !sender.isSelected && sender != weeklyWorkoutCheckFirst {
			weaklyWorkouts = 0
		}
	}
}

extension QuestionnaireFitnessLevelViewController {
    
	private func setupView() {
		externalTrainingStepper.minimumValue = 0
		externalTrainingStepper.maximumValue = 5
		externalTrainingStepper.roundButtons = true
		externalTrainingStepper.labelTextColor = .white
		externalTrainingStepper.backgroundColor = .clear
		externalTrainingStepper.buttonsTextColor = .white
		externalTrainingStepper.labelBackgroundColor = .clear
		externalTrainingStepper.buttonsBackgroundColor = .projectTail
		externalTrainingStepper.labelFont = UIFont(name: "Assistant-SemiBold", size: 18)!
		externalTrainingStepper.addTarget(self, action: #selector(stepperValueChanged), for: .valueChanged)
	}
    private func setupCheckMarks() {
        let userData = UserProfile.defaults
        
        if let fitnessLevel = userData.fitnessLevel {
			self.fitnessLevel = fitnessLevel
			
			hideUnnecessaryWeeklySelectionOptions(fitnessLevel)

			switch fitnessLevel {
            case 1:
				weaklyWorkouts = 2
                beginnerButton.isSelected = true
				weeklyWorkoutCheckFirst.backgroundColor = .projectTail
				weeklyWorkoutCheckFirst.borderColorV = .projectTail
				weeklyWorkoutCheckSecond.borderColorV = .white
				weeklyWorkoutCheckThird.borderColorV = .white
				weeklyWorkoutCheckSecond.backgroundColor = .clear
				weeklyWorkoutCheckThird.backgroundColor = .clear
            case 2:
                intermediateButton.isSelected = true
				weeklyWorkoutCheckFirst.backgroundColor = .projectTail
				weeklyWorkoutCheckFirst.borderColorV = .projectTail
				weeklyWorkoutCheckSecond.borderColorV = .white
				weeklyWorkoutCheckThird.borderColorV = .white
				weeklyWorkoutCheckSecond.backgroundColor = .clear
				weeklyWorkoutCheckThird.backgroundColor = .clear
            case 3:
                advancedButton.isSelected = true
				beginnerButton.isSelected = false
				intermediateButton.isSelected = false
				advancedButton.isSelected = true

				weeklyWorkoutCheckFirst.backgroundColor = .clear
				weeklyWorkoutCheckFirst.borderColorV = .white
            default:
                break
            }
        }
        if let weaklyWorkouts = userData.weaklyWorkouts {
            switch weaklyWorkouts {
            case 2:
                weeklyWorkoutCheckFirst.isSelected = true
            case 3:
                weeklyWorkoutCheckSecond.isSelected = true
            case 4:
                weeklyWorkoutCheckThird.isSelected = true
            default:
                break
            }
        }
    }
    private func hideUnnecessaryWeeklySelectionOptions(_ sender: Int) {
        
		switch sender {
		case 1:
			weeklyWorkoutCheckFirst.isHidden = false
			weeklyWorkoutCheckSecond.isHidden = true
			weeklyWorkoutCheckThird.isHidden = true
		case 2:
			weeklyWorkoutCheckFirst.isHidden = false
			weeklyWorkoutCheckSecond.isHidden = false
			weeklyWorkoutCheckThird.isHidden = true
		case 3:
			weeklyWorkoutCheckFirst.isHidden = true
			weeklyWorkoutCheckSecond.isHidden = false
			weeklyWorkoutCheckThird.isHidden = false
		default:
			break
        }
    }
	@objc private func stepperValueChanged(_ sender: GMStepper) {
		externalWorkouts = Int(sender.value)
	}
}
