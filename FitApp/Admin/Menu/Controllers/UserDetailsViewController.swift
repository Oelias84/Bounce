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
		case orders = "רכישות"
		case meals = "ארוחות"
		case calorieProgress = "חישוב נתונים"
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
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		setupView()
		registerCell()
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
		let storyboard = UIStoryboard(name: K.StoryboardName.chat, bundle: nil)
		let chatContainerVC = storyboard.instantiateViewController(identifier: K.ViewControllerId.ChatContainerViewController) as ChatContainerViewController
		
		chatContainerVC.chatViewController = ChatViewController(viewModel: ChatViewModel(chat: viewModel.getUserChat))
		chatContainerVC.modalPresentationStyle = .fullScreen
		present(chatContainerVC, animated: true)
	}
	private func moveToWeightProgressVC() {
		let storyboard = UIStoryboard(name: K.StoryboardName.weightProgress, bundle: nil)
		let weightProgressVC = storyboard.instantiateViewController(identifier: K.ViewControllerId.weightViewController) as WeightProgressViewController
		
		weightProgressVC.isFromAdmin = true
		weightProgressVC.weightViewModel = WeightViewModel(userUID: viewModel.getUserChat.userId)
		weightProgressVC.modalPresentationStyle = .fullScreen
		present(weightProgressVC, animated: true)
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
		default:
			return
		}
	}
}
