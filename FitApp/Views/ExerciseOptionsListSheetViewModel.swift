//
//  ExerciseOptionsListSheetViewModel.swift
//  FitApp
//
//  Created by Ofir Elias on 07/03/2023.
//

import UIKit
import SwiftUI

class ExerciseOptionsListSheetViewModel: ObservableObject {
	
	let workoutIndex: Int
	let exerciseType: ExerciseType
	
	var exerciseToReplace: Exercise?
	
	let workoutManager = WorkoutManager.shared

	init(exerciseType: ExerciseType, workoutIndex: Int) {
		self.exerciseType = exerciseType
		self.workoutIndex = workoutIndex
		
	}
	
	var getExerciseOptionCount: Int {
		workoutManager.getExerciseOptions(workoutIndex: workoutIndex, exerciseType: exerciseType).count
	}
	func getExerciseOptions(at index: Int) -> Exercise {
		workoutManager.getExerciseOptions(workoutIndex: workoutIndex, exerciseType: exerciseType)[index]
	}
//	func replaceExercise(with selectedExerciseIndex: Int) {
//		let exercise = getExerciseOptions(at: selectedExerciseIndex)
//
//		workoutManager.replaceExercise(exercise, with: exercise.exerciseNumber, workoutIndex: workoutIndex, workoutType: workoutType, exerciseType: exerciseType)
//	}
}
