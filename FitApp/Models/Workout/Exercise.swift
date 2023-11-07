//
//  Exercise.swift
//  FitApp
//
//  Created by iOS Bthere on 02/12/2020.
//

import Foundation

struct Exercise: Codable {
	
	let name: String
	let videos: [String]
	let title: String
	let text: String
	let maleText: String?
	let type: String
	let exerciseNumber: Int
    let repeats: String?
    
	var getExerciseText: String {
		let userGender = UserProfile.defaults.getGender
		switch userGender {
		case .male:
			return maleText ?? text
		default:
			return text
		}
	}
}

struct ExerciseData: Codable {
	
	let exercises: [Exercise]
	
	enum CodingKeys: String, CodingKey {
		case exercises = "exercise-data"
	}
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(exercises, forKey: .exercises)
    }
}
