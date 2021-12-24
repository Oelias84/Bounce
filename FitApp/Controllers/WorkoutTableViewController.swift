//
//  WorkoutTableViewController.swift
//  FitApp
//
//  Created by iOS Bthere on 17/01/2021.
//

import UIKit
import BetterSegmentedControl

class WorkoutTableViewController: UIViewController {
	
	private var workoutViewModel: WorkoutViewModel!
	
	@IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var topBarView: BounceNavigationBarView!
	@IBOutlet weak var segmentedControl: BetterSegmentedControl!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		if let navView = navigationController?.view {
			Spinner.shared.show(navView)
		}
		setupView()
		setUpTableView()
		workoutViewModel = WorkoutViewModel()
	}
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		workoutViewModel.refreshDate()
		workoutViewModel.bindWorkoutViewModelToController = {
			Spinner.shared.stop()
			DispatchQueue.main.async {
				[weak self] in
				guard let self = self else { return }
				self.tableView.reloadData()
			}
		}
	}
	
	@IBAction func segmentedControlAction(_ sender: BetterSegmentedControl) {
		switch sender.index {
		case 0:
			workoutViewModel.type = .home
		case 1:
			workoutViewModel.type = .gym
		default:
			break
		}
		
		DispatchQueue.main.async {
			
			[weak self] in
			guard let self = self else { return }
			self.tableView.reloadData()
		}
	}
}

//MARK: Delegates
extension WorkoutTableViewController: UITableViewDelegate, UITableViewDataSource {
	
	// MARK: - Table view data source
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		workoutViewModel.getWorkoutsCount()
	}
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cellData = workoutViewModel.getWorkout(for: indexPath.row)
		let cell = tableView.dequeueReusableCell(withIdentifier: K.CellId.workoutCell, for: indexPath) as! WorkoutTableViewCell
		
		cell.workoutNumber = indexPath.row + 1
		cell.workout = cellData
		return cell
	}
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let workout = workoutViewModel.getWorkout(for: indexPath.row)
		
		moveToExercisesView(for: workout)
	}
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		146
	}
}
extension WorkoutTableViewController: BounceNavigationBarDelegate {
	
	func backButtonTapped() {}
	func todayButtonTapped() {}
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
