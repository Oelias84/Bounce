//
//  QuestionnaireSumUpViewController.swift
//  FitApp
//
//  Created by Ofir Elias on 11/12/2020.
//

import UIKit

class QuestionnaireSumUpViewController: UIViewController {
	
    let manager = GoogleApiManager()
    
	@IBOutlet weak var ageLabel: UILabel!
	@IBOutlet weak var weightLabel: UILabel!
	@IBOutlet weak var heightLabel: UILabel!
	@IBOutlet weak var activityLevelLabel: UILabel!
	@IBOutlet weak var numberOfMealsLabel: UILabel!
	@IBOutlet weak var numberOfWorkoutsLabel: UILabel!
	

	override func viewDidLoad() {
		super.viewDidLoad()
		
		configureLabels()
	}

	@IBAction func nextButtonAction(_ sender: Any) {
        let userData = UserProfile.defaults
        UserProfile.defaults.finishOnboarding = true
        let data = ServerUserData(name: userData.name!, birthDate: userData.birthDate!, weight: userData.weight!, height: userData.height!, fatPercentage: userData.fatPercentage!, kilometer: userData.kilometer!, mealsPerDay: userData.mealsPerDay!, mostHungry: userData.mostHungry!, fitnessLevel: userData.fitnessLevel!, weaklyWorkouts: userData.weaklyWorkouts!, finishOnboarding: true)
        
        manager.updateUserData(userData: data)
		dismiss(animated: true)
	}
}

extension QuestionnaireSumUpViewController {
	
	private func configureLabels() {
		if let weight = UserProfile.defaults.weight, let birthDate = UserProfile.defaults.birthDate,
		   let height = UserProfile.defaults.height, let mealsPerDay = UserProfile.defaults.mealsPerDay, let weaklyWorkouts = UserProfile.defaults.weaklyWorkouts {
			
			ageLabel.text = birthDate.age
			weightLabel.text = "\(weight) " + K.Units.kilometers
			heightLabel.text = "\(height) " + K.Units.centimeter
			numberOfMealsLabel.text = "\(mealsPerDay)"
			numberOfWorkoutsLabel.text = "\(weaklyWorkouts)"
		}
		if let kilometer = UserProfile.defaults.kilometer {
			activityLevelLabel.text = "\(kilometer) " + K.Units.kilometers
		} else if let steps = UserProfile.defaults.steps {
			activityLevelLabel.text = "\(steps) " + K.Units.steps
		} else {
			activityLevelLabel.text = K.Units.unknown
		}
	}
}
