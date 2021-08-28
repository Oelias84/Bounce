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
	
	@IBOutlet weak var weeklyWorkoutCheckFirst: UIButton!
	@IBOutlet weak var weeklyWorkoutCheckSecond: UIButton!
	@IBOutlet weak var weeklyWorkoutCheckThird: UIButton!

    @IBOutlet weak var weeklyWorkoutFirst: UIStackView!
    @IBOutlet weak var weeklyWorkoutSecond: UIStackView!
    @IBOutlet weak var weeklyWorkoutThird: UIStackView!
	@IBOutlet weak var weeklyWorkoutStack: UIStackView!
	
	@IBOutlet weak var nextButton: UIButton!
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		
		setupCheckMarks()
	}
	
	@IBAction func nextButtonAction(_ sender: Any) {
		
		if fitnessLevel != 0 && weaklyWorkouts != 0 {
			UserProfile.defaults.fitnessLevel = fitnessLevel
			UserProfile.defaults.weaklyWorkouts = weaklyWorkouts
			performSegue(withIdentifier: K.SegueId.moveToSumup, sender: self)
		} else {
			presentOkAlert(withTitle: "אופס",withMessage: "נראה כי לא נעשתה בחירה, יש לבחור רמת קושי ולאחר מכן מספר אימונים", buttonText: "הבנתי") {
				return
			}
		}
	}
	@IBAction func levelCheckBoxes(sender: UIButton) {
		sender.isSelected = !sender.isSelected
		fitnessLevel = sender.tag
		weeklyWorkoutStack.isHidden = false
		
		switch sender.tag {
		case 1:
			intermediateButton.isSelected = false
			advancedButton.isSelected = false
			
			weaklyWorkouts = 2
			weeklyWorkoutCheckFirst.isSelected = sender.isSelected
			
			weeklyWorkoutCheckSecond.isSelected = false
			weeklyWorkoutCheckThird.isSelected = false
		case 2:
			weaklyWorkouts = 0
			weeklyWorkoutCheckFirst.isSelected = false
			
			beginnerButton.isSelected = false
			advancedButton.isSelected = false
		case 3:
			weaklyWorkouts = 0
			weeklyWorkoutCheckFirst.isSelected = false

			beginnerButton.isSelected = false
			intermediateButton.isSelected = false
		default:
			return
		}
		if !sender.isSelected {
			fitnessLevel = 0
		}
        hideUnnecessaryWeeklySelectionOptions()
	}
	@IBAction func weeklyWorkoutsCheckBoxes(sender: UIButton) {
		sender.isSelected = !sender.isSelected
        if fitnessLevel == 0 {
            presentOkAlert(withMessage: "יש לבחור קודם את רמת הכושר") {}
			weeklyWorkoutCheckFirst.isSelected = false
			weeklyWorkoutCheckSecond.isSelected = false
			weeklyWorkoutCheckThird.isSelected = false
            return
        }
        
		switch sender.tag {
		case 1:
			weaklyWorkouts = 2
			if sender.isSelected{
				weeklyWorkoutCheckSecond.isSelected = false
				weeklyWorkoutCheckThird.isSelected = false
			}
		case 2:
			weaklyWorkouts = 3
			if sender.isSelected{
				weeklyWorkoutCheckFirst.isSelected = false
				weeklyWorkoutCheckThird.isSelected = false
			}
		case 3:
			weaklyWorkouts = 4
			if sender.isSelected{
				weeklyWorkoutCheckFirst.isSelected = false
				weeklyWorkoutCheckSecond.isSelected = false
			}
		case 4:
			weaklyWorkouts = 5
			if sender.isSelected{
				weeklyWorkoutCheckFirst.isSelected = false
				weeklyWorkoutCheckSecond.isSelected = false
				weeklyWorkoutCheckThird.isSelected = false
			}
		default:
			return
		}
		if !sender.isSelected {
			weaklyWorkouts = 0
		}
	}
}

extension QuestionnaireFitnessLevelViewController {
    
    func setupCheckMarks() {
        let userData = UserProfile.defaults
        
        if let fitnessLevel = userData.fitnessLevel {
			self.fitnessLevel = fitnessLevel
			weeklyWorkoutStack.isHidden = false
			
            switch fitnessLevel {
            case 1:
				weaklyWorkouts = 2
                beginnerButton.isSelected = true
            case 2:
                intermediateButton.isSelected = true
            case 3:
                advancedButton.isSelected = true
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
        hideUnnecessaryWeeklySelectionOptions()
    }
    func hideUnnecessaryWeeklySelectionOptions() {
        
        if beginnerButton.isSelected {
            weeklyWorkoutFirst.isHidden = false
            weeklyWorkoutSecond.isHidden = true
            weeklyWorkoutThird.isHidden = true
        } else if intermediateButton.isSelected {
            weeklyWorkoutFirst.isHidden = false
            weeklyWorkoutSecond.isHidden = false
            weeklyWorkoutThird.isHidden = true
        } else if advancedButton.isSelected {
            weeklyWorkoutFirst.isHidden = true
            weeklyWorkoutSecond.isHidden = false
            weeklyWorkoutThird.isHidden = false
        }
    }
}
