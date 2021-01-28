//
//  WorkoutViewModel.swift
//  FitApp
//
//  Created by iOS Bthere on 17/01/2021.
//

import Foundation

class WorkoutViewModel: NSObject {
    
    private var workouts: [Workout] = []
    private var exercises: [Exercise]!
    let googleManager = GoogleApiManager()
	
    
    var bindWorkoutViewModelToController : (() -> ()) = {}

    override init() {
        super.init()
        
        fetchExercise {
            self.fetchWorkout {
                self.addExerciseDataToWorkout()
            }
        }
    }
    
    var workoutsCount: Int {
        self.workouts.count
    }
    func getWorkout(for index: Int) -> Workout {
        self.workouts[index]
    }
    
    func fetchWorkout(completion: @escaping () -> Void) {
		workouts.removeAll()
        if let level = UserProfile.defaults.fitnessLevel,
           let weeklyWorkout = UserProfile.defaults.weaklyWorkouts {
            self.googleManager.getWorkouts(forFitnessLevel: level) { result in
                
                switch result {
                case .success(let workouts):
					workouts.forEach {
						$0.exercises.insert(self.addWarmup(), at: 0)
					}
					
					self.workouts.append(contentsOf: workouts.filter { $0.type == weeklyWorkout})
                    completion()
                case .failure(let error):
                    print("There was an issue getting workouts: ", error )
                }
            }
        } else {
            print("Missing fitness user level")
        }
            
    }
    func fetchExercise(completion: @escaping () -> Void) {
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
    func addExerciseDataToWorkout(){
        workouts.forEach {
            $0.exercises.forEach {
                $0.exerciseToPresent = self.exercises[Int($0.exercise)!]
            }
        }
        self.bindWorkoutViewModelToController()
    }
	
	
	func addWarmup() -> WorkoutExercise {
		return WorkoutExercise(exercise: "13", repeats: "10", sets: "3", exerciseToPresent: nil)
	}
}
