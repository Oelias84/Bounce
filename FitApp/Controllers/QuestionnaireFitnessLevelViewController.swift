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
	
	@IBOutlet weak var beginnerTitleTextLabel: UILabel!
	@IBOutlet weak var beginnerTextLabel: UILabel!
	@IBOutlet weak var intermediateTextLabel: UILabel!
	@IBOutlet weak var advanceTitleTextLabel: UILabel!
	@IBOutlet weak var advanceTextLabel: UILabel!
	@IBOutlet weak var selectNumberOfTrainingLabel: UILabel!
	@IBOutlet weak var externalWorkoutTextLabel: UILabel!
	
	@IBOutlet weak var beginnerCheckBox: UIButton!
	@IBOutlet weak var intermediateCheckBox: UIButton!
	@IBOutlet weak var advancedCheckBox: UIButton!
	
	@IBOutlet weak var towWeeklyWorkoutsButton: UIButton!
	@IBOutlet weak var threeWeeklyWorkoutsButton: UIButton!
	@IBOutlet weak var fourWeeklyWorkoutsButton: UIButton!
	
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
	
	@IBAction func infoButtonAction(_ UIButton: Any) {
		presentOkAlert(withTitle: StaticStringsManager.shared.getGenderString?[32] ?? "" ,withMessage: StaticStringsManager.shared.getGenderString?[33] ?? "")
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
			presentOkAlert(withTitle: "אופס",withMessage: "נראה כי לא נעשתה בחירה, יש לבחור רמת קושי ולאחר מכן מספר אימונים", buttonText: "הבנתי")
			return
		}
	}
	@IBAction func levelCheckBoxes(sender: UIButton) {
		fitnessLevel = sender.tag

		switch sender {
		case beginnerCheckBox:
			weaklyWorkouts = 2

			beginnerCheckBox.isSelected = true
			intermediateCheckBox.isSelected = false
			advancedCheckBox.isSelected = false
			
			towWeeklyWorkoutsButton.backgroundColor = .projectTail
			towWeeklyWorkoutsButton.borderColorV = .projectTail
			threeWeeklyWorkoutsButton.borderColorV = .white
			fourWeeklyWorkoutsButton.borderColorV = .white
			threeWeeklyWorkoutsButton.backgroundColor = .clear
			fourWeeklyWorkoutsButton.backgroundColor = .clear
		case intermediateCheckBox:
			weaklyWorkouts = 0

			beginnerCheckBox.isSelected = false
			intermediateCheckBox.isSelected = true
			advancedCheckBox.isSelected = false
			
			threeWeeklyWorkoutsButton.backgroundColor = .clear
			threeWeeklyWorkoutsButton.borderColorV = .white
			towWeeklyWorkoutsButton.backgroundColor = .clear
			towWeeklyWorkoutsButton.borderColorV = .white
		case advancedCheckBox:
			weaklyWorkouts = 0

			beginnerCheckBox.isSelected = false
			intermediateCheckBox.isSelected = false
			advancedCheckBox.isSelected = true
			
			threeWeeklyWorkoutsButton.backgroundColor = .clear
			threeWeeklyWorkoutsButton.borderColorV = .white
			towWeeklyWorkoutsButton.backgroundColor = .clear
			towWeeklyWorkoutsButton.borderColorV = .white
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
            presentOkAlert(withMessage: "יש לבחור קודם את רמת הכושר")
			towWeeklyWorkoutsButton.isSelected = false
			threeWeeklyWorkoutsButton.isSelected = false
			fourWeeklyWorkoutsButton.isSelected = false
            return
        }
		sender.backgroundColor = .projectTail
		sender.borderColorV = .projectTail
		
		switch sender {
		case towWeeklyWorkoutsButton:
			threeWeeklyWorkoutsButton.borderColorV = .white
			fourWeeklyWorkoutsButton.borderColorV = .white
			threeWeeklyWorkoutsButton.backgroundColor = .clear
			fourWeeklyWorkoutsButton.backgroundColor = .clear
			weaklyWorkouts = 2
		case threeWeeklyWorkoutsButton:
			towWeeklyWorkoutsButton.borderColorV = .white
			fourWeeklyWorkoutsButton.borderColorV = .white
			towWeeklyWorkoutsButton.backgroundColor = .clear
			fourWeeklyWorkoutsButton.backgroundColor = .clear
			weaklyWorkouts = 3
		case fourWeeklyWorkoutsButton:
			towWeeklyWorkoutsButton.borderColorV = .white
			threeWeeklyWorkoutsButton.borderColorV = .white
			towWeeklyWorkoutsButton.backgroundColor = .clear
			threeWeeklyWorkoutsButton.backgroundColor = .clear
			weaklyWorkouts = 4
		default:
			return
		}
		if !sender.isSelected && sender != towWeeklyWorkoutsButton {
			weaklyWorkouts = 0
		}
	}
}

extension QuestionnaireFitnessLevelViewController {
    
	private func setupView() {
		externalTrainingStepper.minimumValue = 0
		externalTrainingStepper.maximumValue = 3
		externalTrainingStepper.roundButtons = true
		externalTrainingStepper.labelTextColor = .white
		externalTrainingStepper.backgroundColor = .clear
		externalTrainingStepper.buttonsTextColor = .white
		externalTrainingStepper.labelBackgroundColor = .clear
		externalTrainingStepper.buttonsBackgroundColor = .projectTail
		externalTrainingStepper.labelFont = UIFont(name: "Assistant-SemiBold", size: 18)!
		externalTrainingStepper.addTarget(self, action: #selector(stepperValueChanged), for: .valueChanged)
	}
	private func setupTextLabels() {
		beginnerTitleTextLabel.text = StaticStringsManager.shared.getGenderString?[14]
		beginnerTextLabel.text = StaticStringsManager.shared.getGenderString?[15]
		intermediateTextLabel.text = StaticStringsManager.shared.getGenderString?[16]
		advanceTitleTextLabel.text = StaticStringsManager.shared.getGenderString?[17]
		advanceTextLabel.text = StaticStringsManager.shared.getGenderString?[18]
		selectNumberOfTrainingLabel.text = StaticStringsManager.shared.getGenderString?[19]
		externalWorkoutTextLabel.text = StaticStringsManager.shared.getGenderString?[20]
	}
    private func setupCheckMarks() {
        let userData = UserProfile.defaults
        
        if let fitnessLevel = userData.fitnessLevel {
			self.fitnessLevel = fitnessLevel
			
			hideUnnecessaryWeeklySelectionOptions(fitnessLevel)

			switch fitnessLevel {
            case 1:
                beginnerCheckBox.isSelected = true
            case 2:
                intermediateCheckBox.isSelected = true
            case 3:
				beginnerCheckBox.isSelected = false
				intermediateCheckBox.isSelected = false
				advancedCheckBox.isSelected = true

				towWeeklyWorkoutsButton.backgroundColor = .clear
				towWeeklyWorkoutsButton.borderColorV = .white
            default:
                break
            }
        }
        if let weaklyWorkouts = userData.weaklyWorkouts {
			self.weaklyWorkouts = weaklyWorkouts
			
            switch weaklyWorkouts {
            case 2:
                towWeeklyWorkoutsButton.isSelected = true
				towWeeklyWorkoutsButton.backgroundColor = .projectTail
				towWeeklyWorkoutsButton.borderColorV = .projectTail
            case 3:
                threeWeeklyWorkoutsButton.isSelected = true
				threeWeeklyWorkoutsButton.borderColorV = .projectTail
				threeWeeklyWorkoutsButton.backgroundColor = .projectTail

            case 4:
                fourWeeklyWorkoutsButton.isSelected = true
				fourWeeklyWorkoutsButton.borderColorV = .projectTail
				fourWeeklyWorkoutsButton.backgroundColor = .projectTail
            default:
                break
            }
        }
		if let externalWorkouts = UserProfile.defaults.externalWorkout {
			self.externalWorkouts = externalWorkouts
			externalTrainingStepper.value = Double(externalWorkouts)
		}
    }
    private func hideUnnecessaryWeeklySelectionOptions(_ sender: Int) {
        
		switch sender {
		case 1:
			towWeeklyWorkoutsButton.isHidden = false
			threeWeeklyWorkoutsButton.isHidden = true
			fourWeeklyWorkoutsButton.isHidden = true
		case 2:
			towWeeklyWorkoutsButton.isHidden = false
			threeWeeklyWorkoutsButton.isHidden = false
			fourWeeklyWorkoutsButton.isHidden = true
		case 3:
			towWeeklyWorkoutsButton.isHidden = true
			threeWeeklyWorkoutsButton.isHidden = false
			fourWeeklyWorkoutsButton.isHidden = false
		default:
			break
        }
    }
	@objc private func stepperValueChanged(_ sender: GMStepper) {
		externalWorkouts = Int(sender.value)
	}
}
