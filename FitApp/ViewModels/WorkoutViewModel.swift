//
//  WorkoutViewModel.swift
//  FitApp
//
//  Created by iOS Bthere on 17/01/2021.
//

import Foundation

class WorkoutViewModel: NSObject {
    
    private var workouts: [Workout]! {
        didSet {
            bindWorkoutViewModelToController()
        }
    }
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
    
    func fetchWorkout(completion: @escaping () -> Void) {
        if let level = UserProfile.defaults.fitnessLevel,
           let weeklyWorkout = UserProfile.defaults.weaklyWorkouts {
            self.googleManager.getWorkouts(forFitnessLevel: level) { result in
                
                switch result {
                case .success(let workouts):
                    switch level {
                    case 1:
                        var count = 0
                        while count < 2 {
                            self.workouts.append(contentsOf: workouts.filter { $0.type == weeklyWorkout})
                            count += 1
                        }
                    case 2:
                        switch weeklyWorkout {
                        case 2:
                            var count = 0
                            while count < 2 {
                                self.workouts.append(contentsOf: workouts.filter { $0.type == weeklyWorkout})
                                count += 1
                            }
                        case 3:
                            self.workouts.append(contentsOf: workouts.filter { $0.type == weeklyWorkout})
                        default:
                            break
                        }
                    case 3:
                        self.workouts.append(contentsOf: workouts.filter { $0.type == weeklyWorkout})
                    default:
                        break
                    }
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
    }
}
