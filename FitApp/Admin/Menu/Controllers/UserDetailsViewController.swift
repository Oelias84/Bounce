//
//  UserDetailsViewController.swift
//  FitApp
//
//  Created by Ofir Elias on 25/05/2022.
//

import UIKit

final class UserDetailsViewController: UIViewController {
	
	private enum cellsTitle: String, CaseIterable {
		
		case weights = "משקלים"
		case meals = "ארוחות"
		case calorieProgress = "חישוב נתונים"
		case orders = "רכישות"
	}
	
	var viewModel: UserDetailsViewModel!
	
	@IBOutlet weak private var detailsView: UIView!
	@IBOutlet weak private var gender: UILabel!
	@IBOutlet weak private var birthDate: UILabel!
	@IBOutlet weak private var startWeight: UILabel!
	@IBOutlet weak private var averageCurrentWeight: UILabel!
	@IBOutlet weak private var weeklyNumberOfTraining: UILabel!
	@IBOutlet weak private var weaklyNumberOfExternalTraining: UILabel!
	@IBOutlet weak private var fatPercentage: UILabel!
	@IBOutlet weak private var activityLevelLabel: UILabel!
	@IBOutlet weak private var activityLevel: UILabel!
	@IBOutlet weak private var dailyNumberOfMeals: UILabel!
	@IBOutlet weak private var fitnessLevel: UILabel!
	@IBOutlet weak private var mostHungry: UILabel!
	
	@IBOutlet weak private var tableView: UITableView!
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == K.SegueId.moveToAdminComment {
			if let userAdminCommentsVC = segue.destination as? UserAdminCommentsTableViewController {
				
				userAdminCommentsVC.modalPresentationStyle = .fullScreen
				userAdminCommentsVC.navigationItem.largeTitleDisplayMode = .always
				
				userAdminCommentsVC.viewModel = UserAdminCommentsViewModel(userUID: viewModel.getUserId)
			}
		}
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		
		setupView()
		registerCell()
		navigationItem.largeTitleDisplayMode = .always
	}
	
	@IBAction func chatButtonAction(_ sender: UIBarButtonItem) {
		moveToChatContainerVC()
	}
}

//MARK: - Functions
extension UserDetailsViewController {
	
	private func setupView() {
		Spinner.shared.show(detailsView)
		detailsView.dropShadow()
		
		self.viewModel.userDetails.bind {
			[weak self] data in
			guard let data = data, let self = self else { return }
			
			DispatchQueue.main.async {
				self.gender.text = String(data.gender ?? "")
				self.birthDate.text = data.birthDate ?? ""
				self.startWeight.text = String(data.weight ?? 0)
				self.averageCurrentWeight.text = String(format: "%.2f",data.currentAverageWeight ?? 0)
				self.weeklyNumberOfTraining.text = String(data.weaklyWorkouts ?? 0)
				self.weaklyNumberOfExternalTraining.text = String(data.externalWorkout ?? 0)
				self.fatPercentage.text = String(data.fatPercentage ?? 0)
				self.fitnessLevel.text = self.viewModel.getFitnessLevelTitle
				self.activityLevelLabel.text = self.viewModel.getActivityTitle.0
				self.activityLevel.text = self.viewModel.getActivityTitle.1
				self.dailyNumberOfMeals.text = String(data.mealsPerDay ?? 0)
				self.mostHungry.text = self.viewModel.getMostHungryTitle
			}
			Spinner.shared.stop()
		}
	}
	private func registerCell() {
		let cell = UINib(nibName: K.NibName.userDetailTableViewCell, bundle: nil)
		tableView.register(cell, forCellReuseIdentifier: K.CellId.userDetailCell)
	}
	
	private func moveToChatContainerVC() {
		let chatVC = ChatViewController(viewModel: ChatViewModel(chat: viewModel.getUserChat))
		navigationController?.pushViewController(chatVC, animated: true)
	}
	private func moveToWeightProgressVC() {
		let storyboard = UIStoryboard(name: K.StoryboardName.weightProgress, bundle: nil)
		let weightProgressVC = storyboard.instantiateViewController(identifier: K.ViewControllerId.weightsViewController) as WeightsViewController
		
		weightProgressVC.userID = viewModel.getUserId
		weightProgressVC.isFromAdmin = true
		weightProgressVC.modalPresentationStyle = .fullScreen
		present(weightProgressVC, animated: true)
	}
	private func moveToUserMealsVC() {
		let storyboard = UIStoryboard(name: K.StoryboardName.adminMeal, bundle: nil)
		let userMealsVC = storyboard.instantiateViewController(identifier: K.ViewControllerId.userMealViewController) as UserMealsViewController
		
		userMealsVC.viewModel = UserMealsViewModel(userID: viewModel.getUserId)
		userMealsVC.modalPresentationStyle = .fullScreen
		navigationController?.show(userMealsVC, sender: nil)
	}
	private func moveToUserCalorieCalculationList() {
		let storyboard = UIStoryboard(name: K.StoryboardName.adminUserCalorieProgress, bundle: nil)
		let userColorieProgressVC = storyboard.instantiateViewController(identifier: K.ViewControllerId.userCalorieProgressViewController) as UserCalorieProgressViewController
		
		userColorieProgressVC.viewModel = UserCalorieProgressViewModel(userID: viewModel.getUserId)
		userColorieProgressVC.modalPresentationStyle = .fullScreen
		navigationController?.show(userColorieProgressVC, sender: nil)
	}
}

//MARK: - Delegates
extension UserDetailsViewController: UITableViewDelegate, UITableViewDataSource  {
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		cellsTitle.allCases.count
	}
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: K.CellId.userDetailCell) as! UserDetailTableViewCell
		
		cell.label.text = cellsTitle.allCases[indexPath.row].rawValue
		return cell
	}
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let row = indexPath.row
		
		switch row {
		case 0:
			moveToWeightProgressVC()
		case 1:
			moveToUserMealsVC()
		case 2:
			moveToUserCalorieCalculationList()
		default:
			return
		}
	}
}