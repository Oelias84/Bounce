//
//  ExercisesTableViewController.swift
//  FitApp
//
//  Created by iOS Bthere on 30/11/2020.
//

import UIKit

class ExercisesTableViewController: UIViewController {
    
    var workout: Workout!
    var selectedExercise: Exercise?
	var numberOfExerciseSection: [String:Int] = ["legs":0, "chest":0, "stomach":0, "shoulders":0, "back":0]
	var sectionCount: Int!
	
	@IBOutlet weak var topBarView: BounceNavigationBarView!
	@IBOutlet weak var tableView: UITableView!
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == K.SegueId.moveToExerciseDetailViewController {
            let controller = segue.destination as! ExerciseViewController
            if let exercise = selectedExercise {
                controller.exercise = exercise
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
		
		for exercise in workout.exercises {
			numberOfExerciseSection.updateValue(+1, forKey: exercise.exerciseToPresent!.type)
		}
		sectionCount = numberOfExerciseSection.filter { $0.value != 0 }.count-1
		tableView.register(UINib(nibName: K.NibName.exerciseTableViewCell, bundle: nil), forCellReuseIdentifier: K.CellId.exerciseCell)
		setupTopBar()
    }
}

extension ExercisesTableViewController {
	
	private func setupTopBar() {
		
		topBarView.nameTitle = workout.name
		topBarView.isBackButtonHidden = false
		topBarView.isMotivationHidden = true
	}
}
extension ExercisesTableViewController: UITableViewDelegate, UITableViewDataSource {

    // MARK: - Table view data source
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        workout.exercises.count
    }
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let exercise = workout.exercises[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: K.CellId.exerciseCell, for: indexPath) as! ExerciseTableViewCell
        
        cell.exerciseNumber = indexPath.row
        cell.exerciseData = exercise
        cell.indexPath = indexPath
        cell.delegate = self
        return cell
    }
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        146
    }
}

extension ExercisesTableViewController: ExerciseTableViewCellDelegate {
    
    func detailButtonTapped(indexPath: IndexPath) {
        selectedExercise = workout.exercises[indexPath.row].exerciseToPresent
        performSegue(withIdentifier: K.SegueId.moveToExerciseDetailViewController , sender: self)
    }
}
