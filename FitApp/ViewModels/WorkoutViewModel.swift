//
//  WorkoutViewModel.swift
//  FitApp
//
//  Created by iOS Bthere on 17/01/2021.
//

import Foundation

enum workoutType {
	case home
	case gym
}

class WorkoutViewModel: NSObject {
	
	var type: workoutType = .home
	
	private var homeExercises: [Exercise]!
	private var homeWorkout: [Workout] = []
	
	private var gymExercises: [Exercise]!
	private var gymWorkout: [Workout] = []
	
	private let googleManager = GoogleApiManager()

	var bindWorkoutViewModelToController : (() -> ()) = {}
	
	override init() {
		super.init()
	}
	
	func getWorkoutsCount() -> Int {
		switch type {
		case .home:
			return homeWorkout.count
		case .gym:
			return gymWorkout.count
		}
	}
	func getWorkout(for index: Int) -> Workout {
		switch type {
		case .home:
			return homeWorkout[index]
		case .gym:
			return gymWorkout[index]
		}
	}
	
	func refreshDate() {

		let group = DispatchGroup()
		
		group.enter()
		fetchExercise {
			self.fetchWorkout {
				self.addExerciseDataToWorkout()
				group.leave()
			}
		}
		group.enter()
		fetchGymExercise {
			self.fetchGymWorkout {
				self.addGymExerciseDataToWorkout()
				group.leave()
			}
		}
	}
	func addWarmup(_ type: workoutType) -> WorkoutExercise {
		switch type {
		case .home:
			return WorkoutExercise(exercise: "13", repeats: "10", sets: "3", exerciseToPresent: nil)
		case .gym:
			return WorkoutExercise(exercise: "17", repeats: "10", sets: "3", exerciseToPresent: nil)
		}
	}
	private func addExerciseDataToWorkout() {
		homeWorkout.forEach {
			$0.exercises.forEach {
				$0.exerciseToPresent = self.homeExercises[Int($0.exercise)!]
			}
		}
		self.bindWorkoutViewModelToController()
	}
	private func addGymExerciseDataToWorkout() {
		gymWorkout.forEach {
			$0.exercises.forEach {
				$0.exerciseToPresent = self.gymExercises[Int($0.exercise)!]
			}
		}
		self.bindWorkoutViewModelToController()
	}
	
	private func fetchWorkout(completion: @escaping () -> Void) {
		homeWorkout.removeAll()
        if let level = UserProfile.defaults.fitnessLevel,
           let weeklyWorkout = UserProfile.defaults.weaklyWorkouts {
            self.googleManager.getWorkouts(forFitnessLevel: level) {
				[weak self] result in
				guard let self = self else { return }
				
                switch result {
                case .success(let workouts):
					workouts.forEach {
						$0.exercises.insert(self.addWarmup(.home), at: 0)
					}
					self.homeWorkout.append(contentsOf: workouts.filter {$0.type == weeklyWorkout})
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
		googleManager.getExerciseBy {
			[weak self] result in
			guard let self = self else { return }
			
			switch result {
			case .success(let exercisesData):
				self.homeExercises = exercisesData
				completion()
			case .failure(let error):
				print("Error fetching Exercises: ", error )
			}
		}
	}
	
	private func fetchGymWorkout(completion: @escaping () -> Void) {
		gymWorkout.removeAll()
		if let level = UserProfile.defaults.fitnessLevel,
		   let weeklyWorkout = UserProfile.defaults.weaklyWorkouts {
			self.googleManager.getGymWorkouts(forFitnessLevel: level) {
				[weak self] result in
				guard let self = self else { return }
				
				switch result {
				case .success(let workouts):
					workouts.forEach {
						$0.exercises.insert(self.addWarmup(.gym), at: 0)
					}
					self.gymWorkout.append(contentsOf: workouts.filter {$0.type == weeklyWorkout})
				case .failure(let error):
					print("There was an issue getting workouts: ", error )
				}
				completion()
			}
		} else {
			print("Missing fitness user level")
		}
		
	}
	private func fetchGymExercise(completion: @escaping () -> Void) {
		googleManager.getGymExerciseBy {
			[weak self] result in
			guard let self = self else { return }
			
			switch result {
			case .success(let exercisesData):
				self.gymExercises = exercisesData
				for gymExercise in self.gymExercises {
					print(gymExercise.name)
				}
				completion()
			case .failure(let error):
				print("Error fetching Exercises: ", error )
			}
		}
	}
}
