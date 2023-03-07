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
	
	var getIndex: Int {
		index
	}
	var getExercisePresentNumber: Int {
		index + 1
	}
	var exerciseNumber: Int? {
		workoutExercise.exerciseToPresent?.exerciseNumber
	}
	var getType: String {
		workoutExercise.exerciseToPresent?.type ?? ""
	}
	var getName: String {
		workoutExercise.exerciseToPresent?.name ?? ""
	}
	var getNumberOfSets: String {
		workoutExercise.sets
	}
	var getNumberOfRepeats: String {
		workoutExercise.repeats
	}
}
