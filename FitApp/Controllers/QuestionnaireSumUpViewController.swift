//
//  QuestionnaireSumUpViewController.swift
//  FitApp
//
//  Created by Ofir Elias on 11/12/2020.
//

import UIKit

class QuestionnaireSumUpViewController: UIViewController {
	
    private let manager = GoogleApiManager()
    private var userData = UserProfile.defaults

	@IBOutlet weak var ageLabel: UITextField!
	@IBOutlet weak var weightLabel: UITextField!
	@IBOutlet weak var heightLabel: UITextField!
	@IBOutlet weak var activityLevelLabel: UITextField!
	@IBOutlet weak var numberOfMealsLabel: UITextField!
	@IBOutlet weak var numberOfWorkoutsLabel: UITextField!
	

	override func viewDidLoad() {
		super.viewDidLoad()
		
		configureLabels()
	}

	@IBAction func nextButtonAction(_ sender: Any) {

        UserProfile.defaults.finishOnboarding = true
		
		if let steps = userData.steps, let height = userData.height {
			let stepsLengthForMeter = (Double(height) * 0.413) / 100
			let stepsForOneKilometer = 1000 / stepsLengthForMeter
			let Kilometer = Double(steps) / stepsForOneKilometer
			userData.kilometer = Kilometer
		}
		
		let data = ServerUserData(birthDate: userData.birthDate!.dateStringForDB, email: userData.email!, name: userData.name!,
								  weight: userData.weight!, height: userData.height!, fatPercentage: userData.fatPercentage!,
								  steps: userData.steps, kilometer: userData.kilometer, lifeStyle: userData.lifeStyle, mealsPerDay: userData.mealsPerDay!,
								  mostHungry: userData.mostHungry!, fitnessLevel: userData.fitnessLevel!,
								  weaklyWorkouts: userData.weaklyWorkouts!, finishOnboarding: userData.finishOnboarding!)
        
        manager.updateUserData(userData: data)
		dismiss(animated: true)
	}
}

extension QuestionnaireSumUpViewController {
	
	private func configureLabels() {
		if let weight = userData.weight, let birthDate = userData.birthDate,
		   let height = userData.height, let mealsPerDay = userData.mealsPerDay, let weaklyWorkouts = userData.weaklyWorkouts {
			
			ageLabel.text = birthDate.age
			weightLabel.text = "\(weight) " + K.Units.Kilograms
			heightLabel.text = "\(height) " + K.Units.centimeter
			numberOfMealsLabel.text = "\(mealsPerDay)"
			numberOfWorkoutsLabel.text = "\(weaklyWorkouts)"
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
