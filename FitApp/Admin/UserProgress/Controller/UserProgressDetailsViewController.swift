//
//  UserProgressDetailsViewController.swift
//  FitApp
//
//  Created by Ofir Elias on 06/06/2022.
//

import UIKit

class UserProgressDetailsViewController: UIViewController {
	
	var viewModel: UserProgressDetailsViewModel!
	
	@IBOutlet weak private var detailsView: UIView!
	@IBOutlet weak private var date: UILabel!
	@IBOutlet weak private var differenceBetweenAverageWeight: UILabel!
	@IBOutlet weak private var differenceBetweenAverageWeightPercentage: UILabel!
	@IBOutlet weak private var userCaloriesBetweenConsumedAndGiven: UILabel!
	@IBOutlet weak private var userWeekConsumedCalories: UILabel!
	@IBOutlet weak private var userWeekExpectedCalories: UILabel!
	@IBOutlet weak private var firstWeekAverageWeight: UILabel!
	@IBOutlet weak private var secondWeekAverageWeight: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
		
		setupView()
    }
}
 
//MARK: - Functions
extension UserProgressDetailsViewController {
	
	fileprivate func setupView() {
		date.text = viewModel.getDate
		differenceBetweenAverageWeight.text = viewModel.getDifferenceBetweenAverageWeight
		differenceBetweenAverageWeightPercentage.text = viewModel.getDifferenceBetweenAverageWeightPercentage
		userCaloriesBetweenConsumedAndGiven.text = viewModel.getUserCaloriesBetweenConsumedAndGiven
		userWeekConsumedCalories.text = viewModel.getUserWeekConsumedCalories
		userWeekExpectedCalories.text = viewModel.getUserWeekExpectedCalories
		firstWeekAverageWeight.text = viewModel.getFirstWeekAverageWeight
		secondWeekAverageWeight.text = viewModel.getSecondWeekAverageWeight
	}
}
