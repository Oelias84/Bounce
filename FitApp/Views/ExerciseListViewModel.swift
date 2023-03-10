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
	
	init(workoutIndex: Int, workout: Workout) {
		self.workoutIndex = workoutIndex
		self.workout = WorkoutManager.shared.getCurrentWorkout(for: workoutIndex)
		self.exercisesState = WorkoutManager.shared.getExercisesState(index: workoutIndex)
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
	
	func replaceExercise(with execiseOption: Exercise) {
		guard let exerciseNumberToReplace else { return }
		
		WorkoutManager.shared.replaceExercise(exercise: exerciseNumberToReplace, with: execiseOption, workoutIndex: workoutIndex) {
			self.exercisesState = WorkoutManager.shared.getExercisesState(index: workoutIndex)
			objectWillChange.send()
		}
	}
}
