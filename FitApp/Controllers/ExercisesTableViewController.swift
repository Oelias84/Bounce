//
//  ExercisesTableViewController.swift
//  FitApp
//
//  Created by iOS Bthere on 30/11/2020.
//

import UIKit
import SwiftUI

class ExercisesTableViewController: UIViewController {
    
    var workout: Workout!
    var selectedExercise: Exercise?
	var numberOfExerciseSection: [String:Int] = ["legs":0, "chest":0, "stomach":0, "shoulders":0, "back":0]
	var sectionCount: Int!
	
	@IBOutlet weak var topBarView: BounceNavigationBarView!
	@IBOutlet weak var tableView: UITableView!
	
	@IBOutlet weak var swiftUIContainer: UIView!
	
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
		addSwiftUIView(content: ExerciseListView(workout: workout))

		for exercise in workout.exercises {
			numberOfExerciseSection.updateValue(+1, forKey: exercise.exerciseToPresent!.type)
		}
		sectionCount = numberOfExerciseSection.filter { $0.value != 0 }.count-1
		tableView.register(UINib(nibName: K.NibName.exerciseTableViewCell, bundle: nil), forCellReuseIdentifier: K.CellId.exerciseCell)
		setupTopBar()
    }
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		topBarView.setImage()
	}
}

extension ExercisesTableViewController {
	
	private func setupTopBar() {
		
		topBarView.delegate = self
		topBarView.nameTitle = workout.name
		topBarView.isBackButtonHidden = false
		topBarView.isDayWelcomeHidden = true
		topBarView.isMotivationHidden = true
	}
	private func addSwiftUIView(content: some View) {
		var child = UIHostingController(rootView: content)
		
		addChild(child)
		swiftUIContainer.addSubview(child.view)
		
		child.view.translatesAutoresizingMaskIntoConstraints = false
		child.view.topAnchor.constraint(equalTo: swiftUIContainer.topAnchor).isActive = true
		child.view.bottomAnchor.constraint(equalTo: swiftUIContainer.bottomAnchor).isActive = true
		child.view.leftAnchor.constraint(equalTo: swiftUIContainer.leftAnchor).isActive = true
		child.view.rightAnchor.constraint(equalTo: swiftUIContainer.rightAnchor).isActive = true
	}
}

//MARK: - Delegates
extension ExercisesTableViewController: BounceNavigationBarDelegate {
	
	func backButtonTapped() {
		navigationController?.popViewController(animated: true)
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

//MARK: - Functions
extension ExercisesTableViewController: ExerciseTableViewCellDelegate {
    
    func detailButtonTapped(indexPath: IndexPath) {
        selectedExercise = workout.exercises[indexPath.row].exerciseToPresent
        performSegue(withIdentifier: K.SegueId.moveToExerciseDetailViewController , sender: self)
    }
}
