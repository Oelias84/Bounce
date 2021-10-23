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
