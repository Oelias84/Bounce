//
//  Exercise.swift
//  FitApp
//
//  Created by iOS Bthere on 02/12/2020.
//

import Foundation


class WorkoutExercise: Codable {
    
    let exercise: String
    let repeats: String
    let sets: String
    var exerciseToPresent: Exercise?
}

class Exercise: Codable {
    
    let name: String
    let videos: [String]
	let title: String
	let text: String
}
