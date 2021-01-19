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
