//
//  QuestionnaireSumUpViewController.swift
//  FitApp
//
//  Created by Ofir Elias on 11/12/2020.
//

import UIKit
import Foundation

class QuestionnaireSumUpViewController: UIViewController {
	
    private let manager = GoogleApiManager()
    private var userData = UserProfile.defaults

	@IBOutlet weak var ageLabel: UITextField!
	@IBOutlet weak var weightLabel: UITextField!
	@IBOutlet weak var heightLabel: UITextField!
	@IBOutlet weak var activityLevelLabel: UITextField!
	@IBOutlet weak var numberOfMealsLabel: UITextField!
	@IBOutlet weak var numberOfWorkoutsLabel: UITextField!
	@IBOutlet weak var numberOfExternalWorkoutsLabel: UITextField!
	@IBOutlet weak var numberOfExternalWorkoutsStack: UIStackView!
	

	override func viewDidLoad() {
		super.viewDidLoad()
		navigationItem.setHidesBackButton(true, animated: false)
		
		configureLabels()
		addScreenTappGesture()
	}

	@IBAction func backButtonAction(_ sender: Any) {
		navigationController?.popViewController(animated: true)
	}
	@IBAction func nextButtonAction(_ sender: Any) {

        UserProfile.defaults.finishOnboarding = true
		
		if let steps = userData.steps, let height = userData.height {
			let stepsLengthForMeter = (Double(height) * 0.413) / 100
			let stepsForOneKilometer = 1000 / stepsLengthForMeter
			let Kilometer = Double(steps) / stepsForOneKilometer
			
			userData.kilometer = Kilometer
		}
		
		let data = ServerUserData(permissionsLevel: userData.permissionsLevel, checkedTermsOfUse: userData.checkedTermsOfUse, gander: userData.gander,
								  lastCaloriesCheckDateString: userData.lastCaloriesCheckDateString,
								  birthDate: userData.birthDate!.dateStringForDB, email: userData.email!, name: userData.name!, weight: userData.weight, currentAverageWeight: nil,
								  height: userData.height, fatPercentage: userData.fatPercentage, steps: userData.steps, kilometer: userData.kilometer,
								  lifeStyle: userData.lifeStyle, mealsPerDay: userData.mealsPerDay!, mostHungry: userData.mostHungry, fitnessLevel: userData.fitnessLevel,
								  weaklyWorkouts: userData.weaklyWorkouts, externalWorkout: userData.externalWorkout, finishOnboarding: userData.finishOnboarding)
        
        manager.updateUserData(userData: data)
		moveToHomeViewController()
	}
}
extension QuestionnaireSumUpViewController: UITextFieldDelegate {
//
//	func textFieldDidBeginEditing(_ textField: UITextField) {
//
//		let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController]
//
//		switch textField {
//		case ageLabel:
//			print(textField.text)
//		case weightLabel:
//			print(textField.text)
//		case heightLabel:
//			print(textField.text)
//		case activityLevelLabel:
//			if userData.kilometer != nil || UserProfile.defaults.steps != nil  {
//				if let vc = viewControllers.filter({ $0 is QuestionnaireActivityViewController }).first {
//					navigationController!.popToViewController(vc, animated: true)
//				}
//			} else {
//				if let vc = viewControllers.filter({ $0 is QuestionnaireSecondActivityViewController }).first {
//					navigationController!.popToViewController(vc, animated: true)
//				}
//			}
//		case numberOfMealsLabel:
//			print("")
//		case numberOfWorkoutsLabel:
//			print("")
//		case numberOfExternalWorkoutsLabel:
//			print("")
//		case numberOfExternalWorkoutsStack:
//			print("")
//		default:
//			break
//		}
//	}
//	func textFieldDidEndEditing(_ textField: UITextField) {
//
//		switch textField {
//		case ageLabel:
//
//		case weightLabel:
//			print(textField.text)
//		case heightLabel:
//			print(textField.text)
//		case activityLevelLabel:
//			print(textField.text)
//		case numberOfMealsLabel:
//			print("")
//		case numberOfWorkoutsLabel:
//			print("")
//		case numberOfExternalWorkoutsLabel:
//			print("")
//		case numberOfExternalWorkoutsStack:
//			print("")
//		default:
//			break
//		}
//	}
}

extension QuestionnaireSumUpViewController {
	
	private func moveToHomeViewController() {
		let storyboard = UIStoryboard(name: K.StoryboardName.home, bundle: nil)
		let homeVC = storyboard.instantiateViewController(identifier: K.ViewControllerId.HomeTabBar)
		
		homeVC.modalPresentationStyle = .fullScreen
		self.present(homeVC, animated: true)
	}
	
	private func configureLabels() {
		
		if let weight = userData.weight, let birthDate = userData.birthDate,
		   let height = userData.height, let mealsPerDay = userData.mealsPerDay,
		   let weaklyWorkouts = userData.weaklyWorkouts {
			
			ageLabel.text = birthDate.age
			weightLabel.text = "\(weight) " + K.Units.Kilograms
			heightLabel.text = "\(height) " + K.Units.centimeter
			numberOfMealsLabel.text = "\(mealsPerDay)"
			numberOfWorkoutsLabel.text = "\(weaklyWorkouts)"
		}
		
		if let externalWorkout = userData.externalWorkout, externalWorkout != 0 {
			numberOfExternalWorkoutsStack.isHidden = false
			numberOfExternalWorkoutsLabel.text = "\(externalWorkout)"
		}
		
		if let kilometer = userData.kilometer {
			activityLevelLabel.text = "\(kilometer) " + K.Units.kilometers
		} else if let steps = UserProfile.defaults.steps {
			activityLevelLabel.text = "\(steps) " + K.Units.steps
		} else {
			if let lifeStyle = UserProfile.defaults.lifeStyle {
				switch lifeStyle {
				case 1.2:
					activityLevelLabel.text = "אורח חיים יושבני"
				case 1.3:
					activityLevelLabel.text = "אורח חיים פעיל מתון"
				case 1.5:
					activityLevelLabel.text = "אורח חיים פעיל"
				case 1.6:
					activityLevelLabel.text = "אורח חיים פעיל מאוד"
				default:
					activityLevelLabel.text = K.Units.unknown
				}
			}
		}
	}
}
