//
//  ExerciseListViewModel.swift
//  FitApp
//
//  Created by Ofir Elias on 29/11/2022.
//

import SwiftUI
import Foundation

class ExerciseListViewModel: ObservableObject {
	
	private let workoutIndex: Int
	@Published var workout: Workout!
	@Published var exercisesState: [ExerciseState]
	
	var exerciseNumberToReplace: Int?
	
	init(workoutIndex: Int,workout: Workout, exercisesState: [ExerciseState]) {
		self.workout = workout
		self.workoutIndex = workoutIndex
		self.exercisesState = exercisesState
	}
	
	var getExercisesCount: Int {
		workout.exercises.count
	}
	func getWorkoutExercise(at index: Int) -> WorkoutExercise {
		workout.exercises[index]
	}
	var getWorkoutIndex: Int {
		workoutIndex
	}
	var getSelectedExerciseType: ExerciseType {
		guard let exerciseNumberToReplace = exerciseNumberToReplace,
			  let selectedExercise = workout.exercises.first(where: { $0.exerciseToPresent?.exerciseNumber == exerciseNumberToReplace }),
			  let type = selectedExercise.exerciseToPresent?.type else { return .none }
		
		return ExerciseType(rawValue: type) ?? .none
	}
//	var getSelectedExerciseToReplace: Exercise? {
//		guard let selectedExerciseNumber = exerciseToReplaceNumber,
//			  let selectedExercise = workout.exercises.first(where: {Int($0.exercise) == selectedExerciseNumber})  else { return nil }
//		return selectedExercise.exerciseToPresent
//	}
//	var getExerciseType: ExerciseType {
//		guard let selectedExerciseNumber = exerciseToReplaceNumber,
//			  let selectedExercise = workout.exercises.first(where: {Int($0.exercise) == selectedExerciseNumber})  else { return .chest }
//
//		return ExerciseType(rawValue: selectedExercise.exerciseToPresent?.type ?? "") ?? .chest
//	}
}
