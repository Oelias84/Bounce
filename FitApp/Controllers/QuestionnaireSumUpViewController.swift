//
//  QuestionnaireSumUpViewController.swift
//  FitApp
//
//  Created by Ofir Elias on 11/12/2020.
//

import UIKit

class QuestionnaireSumUpViewController: UIViewController {
	
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
		//send data to server
		dismiss(animated: true)
	}
}

extension QuestionnaireSumUpViewController {
	
	private func configureLabels(){
		let data = UserProfile.shared
		if let weight = data.weight, let birthDate = data.birthDate,
		   let height = data.height, let mealsPerDay = data.mealsPerDay, let weaklyWorkouts = data.weaklyWorkouts {
			
			ageLabel.text = birthDate.age
			weightLabel.text = "\(weight) " + K.Units.kilometers
			heightLabel.text = "\(height) " + K.Units.centimeter
			numberOfMealsLabel.text = "\(mealsPerDay)"
			numberOfWorkoutsLabel.text = "\(weaklyWorkouts)"
		}
		if let kilometer = data.kilometer {
			activityLevelLabel.text = "\(kilometer) " + K.Units.kilometers
		} else if let steps = data.steps {
			activityLevelLabel.text = "\(steps) " + K.Units.steps
		} else {
			activityLevelLabel.text = K.Units.unknown
		}
	}
}
