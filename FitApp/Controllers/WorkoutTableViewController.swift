//
//  WorkoutTableViewController.swift
//  FitApp
//
//  Created by iOS Bthere on 17/01/2021.
//

import UIKit

class WorkoutTableViewController: UITableViewController {
    
    private var workoutViewModel: WorkoutViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
		workoutViewModel = WorkoutViewModel()
        tableView.register(UINib(nibName: K.NibName.workoutTableViewCell, bundle: nil), forCellReuseIdentifier: K.CellId.workoutCell)
    }
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		self.showSpinner()
		workoutViewModel.refreshDate()
		workoutViewModel.bindWorkoutViewModelToController = {
			self.stopSpinner()
			self.tableView.reloadData()
		}
	}

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        workoutViewModel.workoutsCount
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellData = workoutViewModel.getWorkout(for: indexPath.row)
        let cell = tableView.dequeueReusableCell(withIdentifier: K.CellId.workoutCell, for: indexPath) as! WorkoutTableViewCell
        
        cell.workoutNumber = indexPath.row + 1
        cell.workout = cellData
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let workout = workoutViewModel.getWorkout(for: indexPath.row)
        
        moveToExercisesView(for: workout)
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        146
    }
}

extension WorkoutTableViewController {
    
    private func moveToExercisesView(for workout: Workout) {
        let storyboard = UIStoryboard(name: K.StoryboardName.workout, bundle: nil)
        let workoutVC = storyboard.instantiateViewController(identifier: K.ViewControllerId.exercisesTableViewController) as ExercisesTableViewController

        workoutVC.workout = workout
        navigationController?.pushViewController(workoutVC, animated: true)
    }
}
