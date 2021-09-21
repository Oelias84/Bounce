//
//  WorkoutViewModel.swift
//  FitApp
//
//  Created by iOS Bthere on 17/01/2021.
//

import Foundation

class WorkoutViewModel: NSObject {
	
	private var exercises: [Exercise]!
	private var workouts: [Workout] = []
	private let googleManager = GoogleApiManager()

	var workoutsCount: Int {
		self.workouts.count
	}
	var bindWorkoutViewModelToController : (() -> ()) = {}
	
	override init() {
		super.init()
	}
	
	func refreshDate() {
		fetchExercise {
			self.fetchWorkout {
				self.addExerciseDataToWorkout()
			}
		}
	}
	func addWarmup() -> WorkoutExercise {
		return WorkoutExercise(exercise: "13", repeats: "10", sets: "3", exerciseToPresent: nil)
	}
	func getWorkout(for index: Int) -> Workout {
		self.workouts[index]
	}
	
	private func addExerciseDataToWorkout(){
		workouts.forEach {
			$0.exercises.forEach {
				$0.exerciseToPresent = self.exercises[Int($0.exercise)!]
			}
		}
		self.bindWorkoutViewModelToController()
	}
	private func fetchWorkout(completion: @escaping () -> Void) {
		workouts.removeAll()
        if let level = UserProfile.defaults.fitnessLevel,
           let weeklyWorkout = UserProfile.defaults.weaklyWorkouts {
            self.googleManager.getWorkouts(forFitnessLevel: level) { result in
                
                switch result {
                case .success(let workouts):
					workouts.forEach {
						$0.exercises.insert(self.addWarmup(), at: 0)
					}
					switch level {
					case 2:
						if weeklyWorkout == 2 {
							var count = 0
							while count < 2 {
								self.workouts.append(contentsOf: workouts.filter { $0.type == weeklyWorkout})
								count += 1
							}
						} else {
							self.workouts.append(contentsOf: workouts.filter { $0.type == weeklyWorkout})
						}
					default:
						self.workouts.append(contentsOf: workouts.filter { $0.type == weeklyWorkout})
					}
				case .failure(let error):
					print("There was an issue getting workouts: ", error )
				}
				completion()
			}
		} else {
			print("Missing fitness user level")
		}
		
	}
	private func fetchExercise(completion: @escaping () -> Void) {
		googleManager.getExerciseBy { resualt in
			switch resualt {
			case .success(let exercisesData):
				self.exercises = exercisesData
				completion()
			case .failure(let error):
				print("Error fetching Exercises: ", error )
			}
		}
	}
}
