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
    #warning("remove")
    case legs
    case chest
    case back
    case shoulders
    case stomach
    case hamstring
    case quad
    case glutes
    case none
}

class ExercisesByType {
    
    let type: ExerciseType
    var exercises: [Exercise]
    
    init(type: ExerciseType, exercises: [Exercise]) {
        self.type = type
        self.exercises = exercises
    }
}

class WorkoutManager {
    
    static let shared = WorkoutManager()
    
    private var currentWorkoutType: WorkoutType = .home
    
    private var gymExercises: [Exercise]!
    private var homeExercises: [Exercise]!
    
    private var gymWorkouts: [Workout] = []
    private var homeWorkouts: [Workout] = []
    
    private var homeExercisesByType: [ExercisesByType] = []
    private var gymExercisesByType: [ExercisesByType] = []
    
    private var userPreferredWorkout: UserPreferredWorkouts?
    
    private var workoutsStates: [WorkoutStates]? = [WorkoutStates]()
    private var exercisesStates: [ExerciseState]? = [ExerciseState]()

    private let googleManager = GoogleApiManager()
    
    public var finishFetching: ProjectObservableObject<Bool?> = ProjectObservableObject(nil)
    
    private init() {
        loadData()
    }
    
    func loadData() {
        let group = DispatchGroup()
        
        group.enter()
        fetchPreferredWorkout {
            group.leave()
        }
        group.enter()
        fetchWorkoutsState {
            group.leave()
        }
        group.enter()
        fetchExercisesState {
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
            self.addHomeExerciseDataToWorkout()
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
    
    //MARK: - Getters
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
    
    func getCurrentWorkout(for index: Int) -> Workout? {
        switch self.currentWorkoutType {
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
    func getExercisesState(exerciseNumber: Int) -> ExerciseState {
        if let exerciseState = exercisesStates?.first(where: {$0.exerciseNumber == exerciseNumber}) {
            return exerciseState
        } else {
            let exerciseState = ExerciseState(exerciseNumber: exerciseNumber)
            exercisesStates?.append(exerciseState)
            return exerciseState
        }
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
        let exercisesToRemove = currentWorkout.exercises.compactMap { $0.exerciseToPresent?.exerciseNumber }
        
        // Filter used exercises from exercises options list
        let flitteredOptions = exercisesOptions.filter {
            return !exercisesToRemove.contains($0.exerciseNumber)
        }
        
        // Return filtered exercises
        return flitteredOptions
    }
    func replaceExercise(exercise exerciseNumber: Int, with exerciseOption: Exercise, workoutIndex: Int, completion: ()->()) {
        // Get the current workout by workout type and index
        var currentWorkout: Workout {
            switch self.currentWorkoutType {
            case .home:
                return homeWorkouts[workoutIndex]
            case .gym:
                return gymWorkouts[workoutIndex]
            }
        }
        guard let exerciseIndex = currentWorkout.exercises.firstIndex(where: {$0.exerciseToPresent?.exerciseNumber == exerciseNumber}) else { return }

        let exercise = currentWorkout.exercises[Int(exerciseIndex)]
        exercise.exercise = String(exerciseOption.exerciseNumber)
        exercise.exerciseToPresent = exerciseOption
        
        // If user has Preferred workout
        if var userPreferredWorkout = userPreferredWorkout {
            switch currentWorkoutType {
            case .home:
                userPreferredWorkout.homeWorkouts = homeWorkouts
            case .gym:
                userPreferredWorkout.gymWorkouts = gymWorkouts
            }
            self.updatePreferredWorkouts {
                self.userPreferredWorkout = userPreferredWorkout
            }
        } else {
            
            let preferredWorkoutData = UserPreferredWorkouts(homeWorkouts: homeWorkouts, gymWorkouts: gymWorkouts)
            self.userPreferredWorkout = preferredWorkoutData
            self.updatePreferredWorkouts {
                
            }
        }
        completion()
    }

    private func filterExerciseByType(exercisesData: [Exercise]) -> [ExercisesByType] {
        var exercisesByType: [ExercisesByType] = []
        
        for i in 0..<exercisesData.count {
            let exercise = exercisesData[i]
            guard let exerciseType = ExerciseType(rawValue: exercise.type) else { return exercisesByType }
            
            if let containedExerciseType = exercisesByType.first(where: {$0.type == exerciseType}) {
                containedExerciseType.exercises.append(exercise)
            } else {
                let exerciseByType = ExercisesByType(type: exerciseType, exercises: [exercise])
                exercisesByType.append(exerciseByType)
            }
        }
        return exercisesByType
    }

    //MARK: - Fetch
    // Workouts
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
    private func fetchPreferredWorkout(completion: @escaping () -> Void) {
        googleManager.getPreferredWorkouts { data in
            self.userPreferredWorkout = data
            completion()
        }
    }
    // Exercise
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
    // Workout state
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
    // Exercises state
    private func fetchExercisesState(completion: @escaping () -> Void) {
        self.googleManager.getExercisesState() {
            [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let data):
                self.exercisesStates = data
            case .failure(let error):
                print("There was an issue getting workouts: ", error )
            }
            completion()
        }
    }
    // Adding exercise to workout
    private func addHomeExerciseDataToWorkout() {
        if let userPreferredWorkout {
            homeWorkouts = userPreferredWorkout.homeWorkouts
        }
        homeWorkouts.forEach { workout in
            workout.exercises.forEach {
                let exercise = $0
                exercise.exerciseToPresent = self.homeExercises.first(where: { homeExercise in
                    return homeExercise.exerciseNumber == Int(exercise.exercise)
                })
            }
        }
        finishFetching.value = true
    }
    private func addGymExerciseDataToWorkout() {
        if let userPreferredWorkout {
            gymWorkouts = userPreferredWorkout.gymWorkouts
        }
        gymWorkouts.forEach {
            $0.exercises.forEach {
                $0.exerciseToPresent = self.gymExercises[Int($0.exercise)!]
            }
        }
    }
        
    //MARK: - Update
    func updatePreferredWorkouts(completion: @escaping () -> Void) {
        var preferredHomeWorkout: [Workout] {
            return homeWorkouts.map { mapWorkout($0) }
        }
        var preferredGymWorkout: [Workout] {
            return gymWorkouts.map { mapWorkout($0) }
        }
        // Update server with preferred data
        let data = UserPreferredWorkouts(homeWorkouts: preferredHomeWorkout, gymWorkouts: preferredGymWorkout)
        googleManager.updatePreferredWorkouts(data, completion: completion)
        
        
        func mapWorkout(_ workout: Workout) -> Workout {
            let exercises = workout.exercises.compactMap { exercise in
                return WorkoutExercise(exercise: exercise.exercise, repeats: exercise.repeats, sets: exercise.sets, exerciseToPresent: nil)
            }
            return Workout(exercises: exercises, name: workout.name, time: workout.time, type: workout.type)
        }
    }
    func updateWorkoutStates(isChecked: Bool, for type: WorkoutType, completion: (WorkoutCongratsPopupType)->()) {
        guard let workoutsStates = workoutsStates,
              let userWorkoutNumber = UserProfile.defaults.weaklyWorkouts,
              let workoutState = workoutsStates.first(where: { $0.workoutType == type }) else {
            return
        }
        
        googleManager.updateWorkoutState(workoutsStates)
        
        guard isChecked else { return }
        
        let checkedWorkoutsCount = workoutState.workoutStates.lazy.filter({ $0.isChecked }).count

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
    func updateExercisesStates() {
        guard let exercisesStates = exercisesStates else { return }
        googleManager.updateExercisesState(exercisesStates)
    }
    //MARK: - Remove
    func removePreferredWorkoutData(completion: @escaping () -> Void) {
        googleManager.removeUserWorkoutData(completion: completion)
    }
}
