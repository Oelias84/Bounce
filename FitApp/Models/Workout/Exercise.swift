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
	let maleText: String?
	let type: String
	
	init(name: String, videos: [String], title: String, text: String, maleText: String?, type: String) {
		self.name = name
		self.videos = videos
		self.title = title
		self.text = text
		self.maleText = maleText
		self.type = type
	}
	
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
}
