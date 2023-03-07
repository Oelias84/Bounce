//
//  WorkoutManager.swift
//  FitApp
//
//  Created by Ofir Elias on 20/02/2023.
//

import Foundation

enum WorkoutType: Codable {
	case home
	case gym
}
enum ExerciseType: String {
	case warmup
	case legs
	case chest
	case back
	case shoulders
	case stomach
	case none
}

class HomeExercisesByType {
	
	let type: ExerciseType
	var exercises: [Exercise]
	
	init(type: ExerciseType, exercises: [Exercise]) {
		self.type = type
		self.exercises = exercises
	}
}

class WorkoutManager {
	
	static let shared = WorkoutManager()
	
//	private var userPreferredWorkout: UserPreferredWorkout?
		
	private var currentWorkoutType: WorkoutType = .home

	private var gymExercises: [Exercise]!
	private var homeExercises: [Exercise]!

	private var gymWorkouts: [Workout] = []
	private var homeWorkouts: [Workout] = []
	
	private var homeExercisesByType: [HomeExercisesByType] = []
	private var gymExercisesByType: [HomeExercisesByType] = []

	private var workoutsStates: [WorkoutStates]? = [WorkoutStates]()

	private let googleManager = GoogleApiManager()

	public var finishFetching: ProjectObservableObject<Bool?> = ProjectObservableObject(nil)

	private init() {
		let group = DispatchGroup()
		
		group.enter()
		fetchWorkoutsState {
			group.leave()
		}
		group.enter()
		fetchExercise {
			group.leave()
		}
		group.enter()
		fetchWorkout {
			group.leave()
		}
		group.enter()
		fetchGymExercise {
			group.leave()
		}
		group.enter()
		fetchGymWorkout {
			group.leave()
		}
		group.notify(queue: .main) {
			self.addGymExerciseDataToWorkout()
			self.addExerciseDataToWorkout()
		}
	}
	
	func addWarmup(_ type: WorkoutType) -> WorkoutExercise {
		switch type {
		case .home:
			return WorkoutExercise(exercise: "13", repeats: "10", sets: "3", exerciseToPresent: nil)
		case .gym:
			return WorkoutExercise(exercise: "17", repeats: "10", sets: "3", exerciseToPresent: nil)
		}
	}
	
	// Getters
	var getCurrentWorkoutType: WorkoutType {
		currentWorkoutType
	}
	var getHomeWorkout: [Workout] {
		homeWorkouts
	}
	var getGymWorkout: [Workout] {
		gymWorkouts
	}
	var getHomeExercise: [Exercise] {
		homeExercises
	}

	func getCurrentWorkout(by type: WorkoutType, for index: Int) -> Workout? {
		switch type {
		case .home:
			return getHomeWorkout[index]
		case .gym:
			return getGymWorkout[index]
		}
	}
	func getWorkoutState(by type: WorkoutType, for index: Int) -> WorkoutState {
		guard let workoutsState = workoutsStates?.first(where: {$0.workoutType == type}) else {
			let firstWorkoutsState = WorkoutStates(workoutType: type)
			let firstWorkoutState = WorkoutState(index: 0)

			firstWorkoutsState.workoutStates.append(firstWorkoutState)
			workoutsStates?.append(firstWorkoutsState)

			let workoutState = workoutsStates?.first?.workoutStates.first
			return workoutState ?? WorkoutState(index: 0)
		}
		
		if let workoutState = workoutsState.workoutStates.first(where: {$0.index == index }) {
			return workoutState
		} else {
			let newWorkoutState = WorkoutState(index: index)
			workoutsState.workoutStates.append(newWorkoutState)
			return workoutsState.workoutStates[index]
		}
	}
	func getExercisesState(by type: WorkoutType, index: Int) -> [ExerciseState] {
		guard let workoutState = workoutsStates?.first(where: {$0.workoutType == type}) else { return [] }
		
		if workoutState.workoutStates[index].exercisesStates.isEmpty {
			getCurrentWorkout(by: type, for: index)?.exercises.forEach {
				if let exerciseNumber = $0.exerciseToPresent?.exerciseNumber  {
					workoutState.workoutStates[index].exercisesStates.append(ExerciseState(index: exerciseNumber))
				}
			}
			return workoutState.workoutStates[index].exercisesStates
		}
		return workoutState.workoutStates[index].exercisesStates
	}
	
	func setCurrentWorkoutType(_ type: WorkoutType) {
		currentWorkoutType = type
	}
	
	func getExerciseOptions(workoutIndex: Int, exerciseType: ExerciseType) -> [Exercise] {
		// Get the current workout by workout type and index
		var currentWorkout: Workout {
			switch self.currentWorkoutType {
			case .home:
				return homeWorkouts[workoutIndex]
			case .gym:
				return gymWorkouts[workoutIndex]
			}
		}
		// Get all exercises by type
		var exercisesOptions: [Exercise] {
			switch self.currentWorkoutType {
			case .home:
				return homeExercisesByType.first(where: {$0.type == exerciseType})?.exercises ?? []
			case .gym:
				return gymExercisesByType.first(where: {$0.type == exerciseType})?.exercises ?? []
			}
		}
		// Map used exercise to exerciseNumbers
		let exercisesToRemove = currentWorkout.exercises.compactMap{ $0.exerciseToPresent?.exerciseNumber }

		
		// Filter used exercises from exercises options list
		let flitteredOptions = exercisesOptions.filter {
			guard let exercise = $0.exerciseNumber else { return false }
			return !exercisesToRemove.contains(exercise)
		}
		
		
//		exercisesOptions.filter {
//			guard let exerciseNumber = $0.exerciseToPresent?.exerciseNumber else { return false }
//			return !exercisesToRemove.contains(exerciseNumber)
//		}

		// Return filtered exercises
		return flitteredOptions
	}
	func replaceExercise(_ exerciseNumber: Int, with: Int, workoutIndex: Int) {
		
//		if let userPreferredWorkout = userPreferredWorkout {
//
//
//		} else {
//			// Get the current workout by workout type and index
//			var currentWorkout: Workout {
//				switch workoutType {
//				case .home:
//					return homeWorkouts[workoutIndex]
//				case .gym:
//					return gymWorkouts[workoutIndex]
//				}
//			}
//
//			let exerciseIndex = currentWorkout.exercises.first(where: {$0.exerciseToPresent?.exerciseNumber == with})
////			self.userPreferredWorkout = UserPreferredWorkout(homeWorkout: [UserWorkout()], gymWorkout: [UserWorkout])
//		}
	}
	// Fetch
	/// Workouts
	private func fetchWorkout(completion: @escaping () -> Void) {
		homeWorkouts.removeAll()
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
					self.homeWorkouts.append(contentsOf: workouts.filter {$0.type == weeklyWorkout})
				case .failure(let error):
					print("There was an issue getting workouts: ", error )
				}
				completion()
			}
		} else {
			print("Missing fitness user level")
		}
		
	}
	private func fetchGymWorkout(completion: @escaping () -> Void) {
		gymWorkouts.removeAll()
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
					self.gymWorkouts.append(contentsOf: workouts.filter {$0.type == weeklyWorkout})
				case .failure(let error):
					print("There was an issue getting workouts: ", error )
				}
				completion()
			}
		} else {
			print("Missing fitness user level")
		}
		
	}
	/// Exercise
	private func fetchExercise(completion: @escaping () -> Void) {
		googleManager.getExerciseBy {
			[weak self] result in
			guard let self = self else { return }
			
			switch result {
			case .success(let exercisesData):
				self.homeExercises = exercisesData
				
				self.homeExercisesByType = self.filterExerciseByType(exercisesData: exercisesData)
				completion()
			case .failure(let error):
				print("Error fetching Exercises: ", error )
			}
		}
	}
	private func fetchGymExercise(completion: @escaping () -> Void) {
		googleManager.getGymExerciseBy {
			[weak self] result in
			guard let self = self else { return }
			
			switch result {
			case .success(let exercisesData):
				self.gymExercises = exercisesData
				
				self.gymExercisesByType = self.filterExerciseByType(exercisesData: exercisesData)
				completion()
			case .failure(let error):
				print("Error fetching Exercises: ", error )
			}
		}
	}
	/// Workout state
	private func fetchWorkoutsState(completion: @escaping () -> Void) {
		homeWorkouts.removeAll()
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

	private func addExerciseDataToWorkout() {
		for index in 0..<homeWorkouts.count {
			let workout = homeWorkouts[index]
//			workout.workoutNumber = index
//
//			// If user has
//			if let userWorkoutPlan = userPreferredWorkout {
//				if let savedWorkout = userWorkoutPlan.homeWorkout.first(where: {$0.workoutNumber == workout.workoutNumber}) {
//					workout.exercises = savedWorkout.exercises
//					workout.exercises.forEach {
//						let exercise = $0
//
//						exercise.exerciseToPresent = self.homeExercises.first(where: { homeExercise in
//							return homeExercise.exerciseNumber == Int(exercise.exercise)
//						})
//					}
//				} else {
//					workout.exercises.forEach {
//						let exercise = $0
//
//						exercise.exerciseToPresent = self.homeExercises.first(where: { homeExercise in
//							return homeExercise.exerciseNumber == Int(exercise.exercise)
//						})
//					}
//				}
//			} else {
				workout.exercises.forEach {
					let exercise = $0
					
					exercise.exerciseToPresent = self.homeExercises.first(where: { homeExercise in
						return homeExercise.exerciseNumber == Int(exercise.exercise)
					})
				}
//			}
		}
		finishFetching.value = true
	}
	private func addGymExerciseDataToWorkout() {
		gymWorkouts.forEach {
			$0.exercises.forEach {
				$0.exerciseToPresent = self.gymExercises[Int($0.exercise)!]
			}
		}
	}
	
	private func filterExerciseByType(exercisesData: [Exercise]) -> [HomeExercisesByType] {
		var exercisesByType: [HomeExercisesByType] = []

		for i in 0..<exercisesData.count {
			let exercise = exercisesData[i]
			guard let exerciseType = ExerciseType(rawValue: exercise.type) else { return exercisesByType }

			if exercisesByType.contains(where: {$0.type == exerciseType}) {
				let containedExerciseType = exercisesByType.first(where: {$0.type == exerciseType})
				containedExerciseType?.exercises.append(exercise)
			} else {
				let exerciseByType = HomeExercisesByType(type: exerciseType, exercises: [exercise])
				exercisesByType.append(exerciseByType)
			}
		}
		return exercisesByType
	}

	//MARK: - Update
	func saveUserPreferredWorkout() {
		
	}
	func updateWorkoutStates(isChecked: Bool, for type: WorkoutType, completion: (WorkoutCongratsPopupType)->()) {
		guard let workoutsStates = workoutsStates,
			  let userWorkoutNumber = UserProfile.defaults.weaklyWorkouts,
			  let workoutState = workoutsStates.first(where: { $0.workoutType == type }) else { return }
		
		googleManager.updateWorkoutState(workoutsStates)
		
		if !isChecked { return }
		let checkedWorkoutsCount = workoutState.workoutStates.filter({ $0.isChecked }).count
		
		if checkedWorkoutsCount == userWorkoutNumber {
			completion(.finishedAll)
		} else {
			completion(.finishedOne)
		}
	}
	func updateWorkoutStates() {
		guard let workoutsStates = workoutsStates else { return }
		googleManager.updateWorkoutState(workoutsStates)
	}
}
