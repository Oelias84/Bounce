//
//  ExerciseListViewModel.swift
//  FitApp
//
//  Created by Ofir Elias on 29/11/2022.
//

import SwiftUI
import Foundation

class ExerciseListViewModel: ObservableObject {
	
	@Published private var workout: Workout!
	@Published var exercisesState: [ExerciseState]
	
	init(workout: Workout, exercisesState: [ExerciseState]) {
		self.workout = workout
		self.exercisesState = exercisesState
	}
	
	var getExercisesCount: Int {
		workout.exercises.count
	}
	func getWorkoutExercise(at index: Int) -> WorkoutExercise {
		workout.exercises[index]
	}
}
