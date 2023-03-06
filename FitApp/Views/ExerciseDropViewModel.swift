//
//  ExerciseViewModel.swift
//  FitApp
//
//  Created by Ofir Elias on 26/11/2022.
//

import UIKit
import SwiftUI
import Foundation

class ExerciseDropViewModel: ObservableObject {
	
	private let index: Int
	var exerciseViewModel: ExerciseListViewModel!

	init(index: Int, exerciseViewModel: ExerciseListViewModel) {
		self.index = index
		self.exerciseViewModel = exerciseViewModel
	}
	
	func getIndex() -> Int {
		index
	}
	func getExercisePresentNumber() -> Int {
		index + 1
	}
	
	func getType() -> String {
		currentExercise().exerciseToPresent?.type ?? ""
	}
	func getName() -> String {
		currentExercise().exerciseToPresent?.name ?? ""
	}
	func getNumberOfSets() -> String {
		currentExercise().sets
	}
	func getNumberOfRepeats() -> String {
		currentExercise().repeats
	}
	
	private func currentExercise() -> WorkoutExercise {
		exerciseViewModel.workout.exercises[index]
	}
}
