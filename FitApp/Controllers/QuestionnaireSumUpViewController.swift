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

		
    }

	private func configureLabels(){
		let data = UserProfile.shared
		
		
		ageLabel.text = data.birthDate?.age
		weightLabel.text = "\(data.weight)"
		heightLabel.text = "\(data.height)"
		activityLevelLabel.text = "\(data.kilometre)"
		numberOfMealsLabel.text = "\(data.mealsPerDay)"
		numberOfWorkoutsLabel.text = "\(data.weaklyWorkouts)"
	}
}
