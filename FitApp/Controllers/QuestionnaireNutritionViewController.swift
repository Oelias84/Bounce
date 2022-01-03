//
//  QuestionnaireNutritionViewController.swift
//  FitApp
//
//  Created by iOS Bthere on 10/12/2020.
//

import UIKit

class QuestionnaireNutritionViewController: UIViewController {
	
	var numberOfMeals = 0
	var mostHunger = 0
	var leastHunger = 0
	
	@IBOutlet weak var mealCheckFirst: UIButton!
	@IBOutlet weak var mealCheckSecond: UIButton!
	@IBOutlet weak var mealCheckThird: UIButton!
	
	@IBOutlet weak var mostHungerCheckFirst: UIButton!
	@IBOutlet weak var mostHungerCheckSecond: UIButton!
	@IBOutlet weak var mostHungerCheckThird: UIButton!
	@IBOutlet weak var mostHungerCheckForth: UIButton!
	
	@IBOutlet weak var nextButton: UIButton!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		navigationItem.setHidesBackButton(true, animated: false)

		setupCheckCheckMark()
	}
	@IBAction func backButtonAction(_ sender: Any) {
		navigationController?.popViewController(animated: true)
	}
	@IBAction func nextButtonAction(_ sender: Any) {
		
		if numberOfMeals != 0 && mostHunger != 0 {
			UserProfile.defaults.mealsPerDay = numberOfMeals
			UserProfile.defaults.mostHungry = mostHunger
			performSegue(withIdentifier: K.SegueId.moveToFitnessLevel, sender: self)
		} else if numberOfMeals == 0 {
			presentOkAlert(withTitle: "אופס",withMessage: "נראה כי לא נעשתה בחירה של מספר ארוחות, יש לבחור כמה ארוחות תרצי לאכול ביום", buttonText: "הבנתי") {
				return
			}
		} else {
			presentOkAlert(withTitle: "אופס",withMessage: "נראה כי לא נעשתה בחירה של הזמן ביום שבו את הכי רעבה, יש לבחור באחת מהאפשרויות", buttonText: "הבנתי") {
				return
			}
		}
	}
	@IBAction func mealsCheckBoxes(sender: UIButton) {
		sender.backgroundColor = .projectTail
		sender.borderColorV = .projectTail
		
		switch sender {
		case mealCheckFirst:
			mealCheckSecond.borderColorV = .white
			mealCheckThird.borderColorV = .white
			mealCheckSecond.backgroundColor = .clear
			mealCheckThird.backgroundColor = .clear
			numberOfMeals = 3
		case mealCheckSecond:
			mealCheckFirst.borderColorV = .white
			mealCheckThird.borderColorV = .white
			mealCheckFirst.backgroundColor = .clear
			mealCheckThird.backgroundColor = .clear
			numberOfMeals = 4
		case mealCheckThird:
			mealCheckFirst.borderColorV = .white
			mealCheckSecond.borderColorV = .white
			mealCheckFirst.backgroundColor = .clear
			mealCheckSecond.backgroundColor = .clear
			numberOfMeals = 5
		default:
			mostHunger = 0
			return
		}
	}
	@IBAction func mostHungryCheckBoxes(sender: UIButton) {
		sender.backgroundColor = .projectTail
		sender.borderColorV = .projectTail
		
		switch sender {
		case mostHungerCheckFirst:
			mostHunger = 1

			mostHungerCheckSecond.borderColorV = .white
			mostHungerCheckThird.borderColorV = .white
			mostHungerCheckForth.borderColorV = .white
			mostHungerCheckSecond.backgroundColor = .clear
			mostHungerCheckThird.backgroundColor = .clear
			mostHungerCheckForth.backgroundColor = .clear
		case mostHungerCheckSecond:
			mostHunger = 2

			mostHungerCheckFirst.borderColorV = .white
			mostHungerCheckThird.borderColorV = .white
			mostHungerCheckForth.borderColorV = .white
			mostHungerCheckFirst.backgroundColor = .clear
			mostHungerCheckThird.backgroundColor = .clear
			mostHungerCheckForth.backgroundColor = .clear
		case mostHungerCheckThird:
			mostHunger = 3

			mostHungerCheckFirst.borderColorV = .white
			mostHungerCheckSecond.borderColorV = .white
			mostHungerCheckForth.borderColorV = .white
			mostHungerCheckFirst.backgroundColor = .clear
			mostHungerCheckSecond.backgroundColor = .clear
			mostHungerCheckForth.backgroundColor = .clear
		case mostHungerCheckForth:
			mostHunger = 4
			
			mostHungerCheckFirst.borderColorV = .white
			mostHungerCheckSecond.borderColorV = .white
			mostHungerCheckThird.borderColorV = .white
			mostHungerCheckFirst.backgroundColor = .clear
			mostHungerCheckSecond.backgroundColor = .clear
			mostHungerCheckThird.backgroundColor = .clear
		default:
			mostHunger = 0
			return
		}
	}
}

extension QuestionnaireNutritionViewController {
	
	private func setupCheckCheckMark() {
		let userData = UserProfile.defaults
		
		if let meals = userData.mealsPerDay {
			
			switch meals {
			case 3:
				mealCheckFirst.backgroundColor = .projectTail
				mealCheckFirst.borderColorV = .projectTail
			case 4:
				mealCheckSecond.backgroundColor = .projectTail
				mealCheckSecond.borderColorV = .projectTail
			case 5:
				mealCheckThird.backgroundColor = .projectTail
				mealCheckThird.borderColorV = .projectTail
			default:
				break
			}
		}
		if let mostHungry = userData.mostHungry {
			switch mostHungry {
			case 1:
				mostHungerCheckFirst.backgroundColor = .projectTail
				mostHungerCheckFirst.borderColorV = .projectTail
			case 2:
				mostHungerCheckSecond.backgroundColor = .projectTail
				mostHungerCheckSecond.borderColorV = .projectTail
			case 3:
				mostHungerCheckSecond.backgroundColor = .projectTail
				mostHungerCheckSecond.borderColorV = .projectTail
			case 4:
				mostHungerCheckForth.backgroundColor = .projectTail
				mostHungerCheckForth.borderColorV = .projectTail
			default:
				break
			}
		}
		if let meals = userData.mealsPerDay, let hunger = userData.mostHungry{
			self.mostHunger = hunger
			self.numberOfMeals = meals
		}
	}
}
