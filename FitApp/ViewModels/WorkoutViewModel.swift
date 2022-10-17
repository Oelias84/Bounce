//
//  WorkoutViewModel.swift
//  FitApp
//
//  Created by iOS Bthere on 17/01/2021.
//

import Foundation

enum workoutType: Codable {
	case home
	case gym
}

class WorkoutViewModel: NSObject {
	
	var type: workoutType = .home
	
	private var homeExercises: [Exercise]!
	private var homeWorkout: [Workout] = []
	
	private var gymExercises: [Exercise]!
	private var gymWorkout: [Workout] = []
	
	private var workoutsStates: [WorkoutStates]!
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
	func getWorkoutState(for index: Int) -> WorkoutState {
		guard let workoutsState = workoutsStates.first(where: {$0.workoutType == type}) else { return WorkoutState() }
		
		if !workoutsState.workoutStates.isEmpty && workoutsState.workoutStates.count-1 >= index {
			return workoutsState.workoutStates[index]
		} else {
			return WorkoutState()
		}
	}
	
	func refreshDate() {
		let group = DispatchGroup()
		
		group.enter()
		fetchWorkoutsState {
			group.leave()
		}
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
		group.notify(queue: .main) {
			self.bindWorkoutViewModelToController()
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
	
	func updateWorkoutStates(workoutState: WorkoutState) {
		guard let workoutsState = workoutsStates.first(where: {$0.workoutType == type}) else { return }

		if let containWorkoutState = workoutsState.workoutStates.first(where: {$0.index == workoutState.index}) {
			containWorkoutState.isChecked = workoutState.isChecked
		} else {
			workoutsState.workoutStates.append(workoutState)
		}
		googleManager.updateWorkoutState(workoutsStates)
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
	private func fetchWorkoutsState(completion: @escaping () -> Void) {
		homeWorkout.removeAll()
		self.googleManager.getWorkoutsState() {
			[weak self] result in
			guard let self = self else { return }
			
			switch result {
			case .success(let workoutsState):
				if let workoutsState = workoutsState {
					workoutsState.forEach { $0.resetIsChecked() }
					self.workoutsStates = workoutsState
				} else {
					let homeStateWorkout = WorkoutStates(workoutType: .home)
					let gymStateWorkout = WorkoutStates(workoutType: .gym)
					self.workoutsStates = [homeStateWorkout, gymStateWorkout]
				}
			case .failure(let error):
				print("There was an issue getting workouts: ", error )
			}
			completion()
		}
	}
}
