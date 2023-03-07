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
	var workoutIndex: Int!
    var selectedExercise: Exercise?
	var exercisesState: [ExerciseState]!
	
	@IBOutlet weak var topBarView: BounceNavigationBarView!
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
		
		setupTopBar()
		addSwiftUIView(content: ExerciseListView(exerciseListViewModel: ExerciseListViewModel(workoutIndex: self.workoutIndex, workout: self.workout, exercisesState: self.exercisesState)) { index in
			// User tapped details button
			self.detailButtonTapped(index: index)
		} endEditing: {
			// Update server
			WorkoutManager.shared.updateWorkoutStates()
		})
    }
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		topBarView.setImage()
	}
}



//MARK: - Delegates
extension ExercisesTableViewController: BounceNavigationBarDelegate {

	func backButtonTapped() {
		navigationController?.popViewController(animated: true)
	}
}

//MARK: - Functions
extension ExercisesTableViewController {
	
	private func setupTopBar() {
		
		topBarView.delegate = self
		topBarView.nameTitle = workout.name
		topBarView.isBackButtonHidden = false
		topBarView.isDayWelcomeHidden = true
		topBarView.isMotivationHidden = true
	}
	private func addSwiftUIView(content: some View) {
		let child = UIHostingController(rootView: content)
		
		addChild(child)
		swiftUIContainer.addSubview(child.view)
		
		child.view.translatesAutoresizingMaskIntoConstraints = false
		child.view.topAnchor.constraint(equalTo: swiftUIContainer.topAnchor).isActive = true
		child.view.bottomAnchor.constraint(equalTo: swiftUIContainer.bottomAnchor).isActive = true
		child.view.leftAnchor.constraint(equalTo: swiftUIContainer.leftAnchor).isActive = true
		child.view.rightAnchor.constraint(equalTo: swiftUIContainer.rightAnchor).isActive = true
	}
	private func detailButtonTapped(index: Int) {
		selectedExercise = workout.exercises[index].exerciseToPresent
		performSegue(withIdentifier: K.SegueId.moveToExerciseDetailViewController , sender: self)
	}
}
