//
//  Workout.swift
//  FitApp
//
//  Created by iOS Bthere on 17/01/2021.
//

import Firebase

class Workout: Codable {
    
    var exercises: [WorkoutExercise]
    var name: String
	var time: String
    var type: Int
}

struct Workouts: Codable {
	
	let advance: [Workout]
	let beginner: [Workout]
	let intermediate: [Workout]
}

class WorkoutExercise: Codable {
	
	let exercise: String
	let repeats: String
	let sets: String
	var exerciseToPresent: Exercise?
	
	init(exercise: String, repeats: String, sets: String, exerciseToPresent: Exercise?) {
		self.exercise = exercise
		self.repeats = repeats
		self.sets = sets
		self.exerciseToPresent = exerciseToPresent
	}
}

class WorkoutStates: Codable {
	
	private var stateDate: String?
	var workoutType: workoutType?
	var workoutStates = [WorkoutState]()
	
	init(workoutType: workoutType?) {
		self.workoutType = workoutType
		self.resetIsChecked()
	}
	
	private func resetIsChecked() {
		if let date = stateDate?.dateFromString?.onlyDate {
			if let endOfTheWeek = date.endOfWeek {
				if Date().isLater(than: endOfTheWeek) {
					workoutStates.forEach { $0.isChecked = false }
				}
			}
		} else {
			stateDate = Date().onlyDate.dateStringForDB
		}
	}
}

class WorkoutState: Codable {
	
	var index: Int?
	var isChecked: Bool = false
}

struct WorkoutStatesData: Codable {
	
	let WorkoutStatesData: [WorkoutStates]
}
