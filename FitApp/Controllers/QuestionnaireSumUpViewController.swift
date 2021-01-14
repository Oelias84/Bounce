//
//  QuestionnaireSumUpViewController.swift
//  FitApp
//
//  Created by Ofir Elias on 11/12/2020.
//

import UIKit

class QuestionnaireSumUpViewController: UIViewController {
	
    private let manager = GoogleApiManager()
    private let userData = UserProfile.defaults

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
        let data = ServerUserData(name: userData.name!, birthDate: userData.birthDate!.dateStringForDB, weight: userData.weight!, height: userData.height!, fatPercentage: userData.fatPercentage!, kilometer: userData.kilometer!, mealsPerDay: userData.mealsPerDay!, mostHungry: userData.mostHungry!, fitnessLevel: userData.fitnessLevel!, weaklyWorkouts: userData.weaklyWorkouts!, finishOnboarding: true)
        
        manager.updateUserData(userData: data)
		dismiss(animated: true)
	}
}

extension QuestionnaireSumUpViewController {
	
	private func configureLabels() {
		if let weight = userData.weight, let birthDate = userData.birthDate,
		   let height = userData.height, let mealsPerDay = userData.mealsPerDay, let weaklyWorkouts = userData.weaklyWorkouts {
			
			ageLabel.text = birthDate.age
			weightLabel.text = "\(weight) " + K.Units.kilometers
			heightLabel.text = "\(height) " + K.Units.centimeter
			numberOfMealsLabel.text = "\(mealsPerDay)"
			numberOfWorkoutsLabel.text = "\(weaklyWorkouts)"
		}
		if let kilometer = userData.kilometer {
			activityLevelLabel.text = "\(kilometer) " + K.Units.kilometers
		} else if let steps = UserProfile.defaults.steps {
			activityLevelLabel.text = "\(steps) " + K.Units.steps
		} else {
			activityLevelLabel.text = K.Units.unknown
		}
	}
    
    func updateUserData() {
        
    }
}
