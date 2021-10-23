//
//  Exercise.swift
//  FitApp
//
//  Created by iOS Bthere on 02/12/2020.
//

import Foundation

class Exercise: Codable {

	let name: String
    let videos: [String]
	let title: String
	let text: String
	let type: String
}

struct ExerciseData: Codable {
	
	let exercises: [Exercise]
	
	enum CodingKeys: String, CodingKey {
		
		case exercises = "exercise-data"
	}
}
