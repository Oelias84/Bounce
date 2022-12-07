//
//  ExerciseViewModel.swift
//  FitApp
//
//  Created by Ofir Elias on 26/11/2022.
//

import UIKit
import SwiftUI
import Foundation

class ExerciseViewModel: ObservableObject {
	
	let index: Int
	@Published var exercise: Binding<WorkoutExercise>
	
	init(index: Int, exercise: Binding<WorkoutExercise>) {
		self.index = index
		self.exercise = exercise
	}

	var getIndex: Int {
		index
	}
	var getName: String {
		exercise.wrappedValue.exerciseToPresent?.name ?? ""
	}
	var getExercisePresentNumber: Int {
		index + 1
	}
	var getNumberOfSets: String {
		exercise.wrappedValue.sets
	}
	var getNumberOfRepeats: String {
		exercise.wrappedValue.repeats
	}
	
	var getTag: (String, UIColor) {
		switch exercise.wrappedValue.exerciseToPresent?.type {
		case "legs":
			return ("רגליים", #colorLiteral(red: 0.3882352941, green: 0.6392156863, blue: 0.2941176471, alpha: 1))
		case "chest":
			return ("חזה", #colorLiteral(red: 0.1863320172, green: 0.6013119817, blue: 0.9211298823, alpha: 1))
		case "back":
			return ("גב", #colorLiteral(red: 1, green: 0.5763723254, blue: 0, alpha: 1))
		case "shoulders":
			return ("כתפיים", #colorLiteral(red: 0.9686274529, green: 0.78039217, blue: 0.3450980484, alpha: 1))
		case "stomach":
			return ("בטן", #colorLiteral(red: 0.5791940689, green: 0.1280144453, blue: 0.5726861358, alpha: 1))
		case "warmup":
			return ("חימום", #colorLiteral(red: 0.7058823529, green: 0.8549019608, blue: 0.7529411765, alpha: 1))
		default:
			return ("", UIColor.white)
		}
	}
}
