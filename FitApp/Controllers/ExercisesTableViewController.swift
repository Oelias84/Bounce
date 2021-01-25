//
//  ExercisesTableViewController.swift
//  FitApp
//
//  Created by iOS Bthere on 30/11/2020.
//

import UIKit

class ExercisesTableViewController: UITableViewController {
    
    var workout: Workout!
    var selectedExercise: Exercise?
    
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
        
		title = workout.name
        tableView.register(UINib(nibName: K.NibName.exerciseTableViewCell, bundle: nil), forCellReuseIdentifier: K.CellId.exerciseCell)
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        workout.exercises.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let exercise = workout.exercises[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: K.CellId.exerciseCell, for: indexPath) as! ExerciseTableViewCell
        
        cell.exerciseNumber = indexPath.row
        cell.exerciseData = exercise
        cell.indexPath = indexPath
        cell.delegate = self
        return cell
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        146
    }
}

extension ExercisesTableViewController: ExerciseTableViewCellDelegate {
    
    func detailButtonTapped(indexPath: IndexPath) {
        selectedExercise = workout.exercises[indexPath.row].exerciseToPresent
        performSegue(withIdentifier: K.SegueId.moveToExerciseDetailViewController , sender: self)
    }
}
