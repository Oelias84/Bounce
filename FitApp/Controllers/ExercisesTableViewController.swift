//
//  ExercisesTableViewController.swift
//  FitApp
//
//  Created by iOS Bthere on 30/11/2020.
//

import UIKit

class ExercisesTableViewController: UITableViewController {
    
    var exercises: [Exercise]!
    var selectedExercise: Exercise?
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == K.SegueId.moveToExerciseViewController {
            let controller = (segue.destination as! UINavigationController).viewControllers[0] as! ExerciseViewController
            if let exercise = selectedExercise {
                controller.exercise = exercise
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: K.NibName.exerciseTableViewCell, bundle: nil), forCellReuseIdentifier: K.CellId.exerciseCell)
        
        exercises = [Exercise(name: "Ex 1", exerciseDescription: "bla bla bla bla"), Exercise(name: "Ex 2", exerciseDescription: "bla bla bla bla"), Exercise(name: "Ex 3", exerciseDescription: "bla bla bla bla"), Exercise(name: "Ex 4", exerciseDescription: "bla bla bla bla"), Exercise(name: "Ex 5", exerciseDescription: "bla bla bla bla")]
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        exercises.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let exercise = exercises[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: K.CellId.exerciseCell, for: indexPath) as! ExerciseTableViewCell
        cell.exerciseData = exercise
        cell.indexPath = indexPath
        cell.delegate = self
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        164
    }
}

extension ExercisesTableViewController: ExerciseTableViewCellDelegate {
    
    func detailButtonTapped(indexPath: IndexPath) {
        selectedExercise = exercises[indexPath.row]
        performSegue(withIdentifier: K.SegueId.moveToExerciseDetailViewController , sender: self)
    }
}
