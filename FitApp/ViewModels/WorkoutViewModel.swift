//
//  WorkoutViewModel.swift
//  FitApp
//
//  Created by iOS Bthere on 17/01/2021.
//

import Foundation

class WorkoutViewModel {
    
    var finishHomeWorkoutConfiguringData: ProjectObservableObject<Bool?> = ProjectObservableObject(nil)
    
    private let workoutManager = WorkoutManager.shared
    
    init() {
        workoutManager.finishFetching.bind { hasData in
            self.finishHomeWorkoutConfiguringData.value = hasData
        }
    }
    
    var type: WorkoutType {
        workoutManager.getCurrentWorkoutType
    }
    
    func setWorkoutType(_ type: WorkoutType) {
        workoutManager.setCurrentWorkoutType(type)
    }
    
    func getWorkoutsCount() -> Int {
        switch type {
        case .home:
            return workoutManager.getHomeWorkout.count
        case .gym:
            return workoutManager.getGymWorkout.count
        }
    }
    
    func getWorkout(for index: Int) -> Workout? {
        workoutManager.getCurrentWorkout(for: index)
    }
    
    func getWorkoutState(for index: Int) -> WorkoutState {
        workoutManager.getWorkoutState(by: type, for: index)
    }
    
    func updateWorkoutStates(isChecked: Bool, completion: ((WorkoutCongratsPopupType) -> Void)? = nil) {
        workoutManager.updateWorkoutStates(isChecked: isChecked, for: type) { workoutCongratsPopupType in
            completion?(workoutCongratsPopupType)
        }
    }
}
