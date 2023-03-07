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
	private let workoutExercise: WorkoutExercise

	init(index: Int, workoutExercise: WorkoutExercise) {
		self.index = index
		self.workoutExercise = workoutExercise
	}
	
	func getIndex() -> Int {
		index
	}
	func getExercisePresentNumber() -> Int {
		index + 1
	}
	
	func getType() -> String {
		workoutExercise.exerciseToPresent?.type ?? ""
	}
	func getName() -> String {
		workoutExercise.exerciseToPresent?.name ?? ""
	}
	func getNumberOfSets() -> String {
		workoutExercise.sets
	}
	func getNumberOfRepeats() -> String {
		workoutExercise.repeats
	}
}
