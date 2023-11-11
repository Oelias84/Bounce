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
    
	init(exercises: [WorkoutExercise], name: String, time: String, type: Int) {
		self.exercises = exercises
		self.name = name
		self.time = time
		self.type = type
	}
    
    func removeExerciseData() {
        exercises.forEach {
            $0.exerciseToPresent = nil
        }
    }
}

struct Workouts: Codable {
	
	let advance: [Workout]
	let beginner: [Workout]
	let intermediate: [Workout]
}

class WorkoutExercise: Codable {
	
	var exercise: String
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

	var workoutType: WorkoutType!
	var workoutStates = [WorkoutState]()
	
	init(workoutType: WorkoutType?) {
		self.workoutType = workoutType
		self.resetIsChecked()
	}
	
	func resetIsChecked() {
		if let date = stateDate?.dateFromString?.onlyDate {
			if let endOfTheWeek = date.endOfWeek {
				if Date().isLater(than: endOfTheWeek) {
					// Reset Data
					stateDate = Date().dateStringForDB
					workoutStates.forEach {
						$0.isChecked = false
					}
				}
			}
		} else {
			stateDate = Date().onlyDate.dateStringForDB
		}
	}
}

class ExerciseState: Codable {
	
	var exerciseNumber: Int
	var setsState: [SetModel]
	
	init(exerciseNumber: Int, setsState: [SetModel] = []) {
		self.exerciseNumber = exerciseNumber
		self.setsState = setsState
	}
}

class WorkoutState: Codable {
	
	var index: Int
	var isChecked: Bool = false
    
	init(index: Int) {
		self.index = index
	}
}

struct WorkoutStatesData: Codable {
	
	let workoutStatesData: [WorkoutStates]
}
struct ExercisesStatesData: Codable {
    
    let exercisesStatesData: [ExerciseState]
}
struct SetModel: Codable, Identifiable, Equatable {
	
	var id = UUID()
	var setIndex: Int!
	var repeats: Int?
	var weight: Double?
	
	init(setIndex: Int) {
		self.setIndex = setIndex
	}
}
