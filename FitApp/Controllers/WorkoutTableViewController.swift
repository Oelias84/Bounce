//
//  WorkoutTableViewController.swift
//  FitApp
//
//  Created by iOS Bthere on 17/01/2021.
//

import UIKit
import BetterSegmentedControl

class WorkoutTableViewController: UIViewController {
	
	private var viewModel: WorkoutViewModel = WorkoutViewModel()
	
	@IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var topBarView: BounceNavigationBarView!
	@IBOutlet weak var segmentedControl: BetterSegmentedControl!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		Spinner.shared.show()		
		viewModel.finishHomeWorkoutConfiguringData.bind { didFinish in
			
			if didFinish == true {
				Spinner.shared.stop()
				DispatchQueue.main.async {
					self.tableView.reloadData()
				}
			}
		}
		
		setupView()
		setUpTableView()
	}
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		topBarView.setImage()
	}
	
	@IBAction func segmentedControlAction(_ sender: BetterSegmentedControl) {
		switch sender.index {
		case 0:
			viewModel.type = .home
		case 1:
			viewModel.type = .gym
		default:
			break
		}
		
		DispatchQueue.main.async {
			self.tableView.reloadData()
		}
	}
}

//MARK: Delegates
extension WorkoutTableViewController: UITableViewDelegate, UITableViewDataSource {
	
	// MARK: - Table view data source
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return viewModel.getWorkoutsCount()
	}
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cellData = viewModel.getWorkout(for: indexPath.row)
		let cell = tableView.dequeueReusableCell(withIdentifier: K.CellId.workoutCell, for: indexPath) as! WorkoutTableViewCell
		
		cell.delegate = self
		cell.indexPathForCell = indexPath
		cell.workoutState = viewModel.getWorkoutState(for: indexPath.row)
		cell.workoutType = viewModel.type
		cell.workoutNumber = indexPath.row + 1
		cell.workout = cellData
		return cell
	}
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		guard let workout = viewModel.getWorkout(for: indexPath.row) else { return }
		
		moveToExercisesView(for: workout)
	}
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		146
	}
}
extension WorkoutTableViewController: BounceNavigationBarDelegate {
	
	func backButtonTapped() {}
}
extension WorkoutTableViewController: WorkoutTableViewCellDelegate {

	func workoutCheckboxAction(state: WorkoutState) {
		
		viewModel.updateWorkoutStates(workoutState: state) {
			let storyboard = UIStoryboard(name: K.ViewControllerId.congratsConfettiViewController, bundle: nil)
			let vc = storyboard.instantiateViewController(withIdentifier: K.ViewControllerId.congratsConfettiViewController) as! CongratsConfettiViewController
			vc.modalPresentationStyle = .overFullScreen
			self.present(vc, animated: true)
		}
	}
}

//MARK: Functions
extension WorkoutTableViewController {
	
	private func setupView() {
		segmentedControl.backgroundColor = .projectBackgroundColor
		segmentedControl.borderColorV = .projectGray.withAlphaComponent(0.2)
		segmentedControl.borderWidthV = 1
		
		segmentedControl.options = [
			.cornerRadius(20),
			.indicatorViewBackgroundColor(.projectTail),
		]
		
		segmentedControl.segments =  [LabelSegment(text: "בית", normalFont: UIFont(name: "Assistant-SemiBold", size: 18), normalTextColor: .black, selectedTextColor: .white),
									  LabelSegment(text: "חדר כושר", normalFont: UIFont(name: "Assistant-SemiBold", size: 18), normalTextColor: .black, selectedTextColor: .white)]
		
		segmentedControl.indicatorViewBorderWidth = 1
		segmentedControl.indicatorViewBorderColor = .projectTail
		
		topBarView.delegate = self
		topBarView.nameTitle = "אימונים"
		topBarView.isMotivationHidden = true
		topBarView.isDayWelcomeHidden = true
		topBarView.isBackButtonHidden = true
		topBarView.isProfileButtonHidden = false
	}
	private func setUpTableView() {
		tableView.delegate = self
		tableView.dataSource = self
		tableView.register(UINib(nibName: K.NibName.workoutTableViewCell, bundle: nil), forCellReuseIdentifier: K.CellId.workoutCell)
	}
	private func moveToExercisesView(for workout: Workout) {
		let storyboard = UIStoryboard(name: K.StoryboardName.workout, bundle: nil)
		let workoutVC = storyboard.instantiateViewController(identifier: K.ViewControllerId.exercisesTableViewController) as ExercisesTableViewController
		
		workoutVC.workout = workout
		navigationController?.pushViewController(workoutVC, animated: true)
	}
}
