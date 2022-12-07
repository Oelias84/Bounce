//
//  ExerciseListViewModel.swift
//  FitApp
//
//  Created by Ofir Elias on 29/11/2022.
//

import SwiftUI
import Foundation

class ExerciseListViewModel: ObservableObject {
	
	@Published var workout: Workout!
	@Published var exercisesState: [ExerciseState]
	
	init(workout: Workout, exercisesState: [ExerciseState]) {
		self.workout = workout
		self.exercisesState = exercisesState
		print(exercisesState)
	}
	
	var getExercisesCount: Int {
		workout.exercises.count
	}
//	func getExercise(for index: Int) -> WorkoutExercise {
//		workout.exercises[index]
//	}
	
//	var getExerciseStateCount: Int {
//		exercisesState?.count ?? 0
//	}
//	func getExerciseState(for index: Int) -> ExerciseState {
//		if let exerciseState = exercisesState.first(where: {$0.index == index}) {
//			return exerciseState
//		} else {
//			let exerciseState = ExerciseState(index: index)
//			exercisesState.append(exerciseState)
//			return exercisesState[index]
//		}
//	}
}
