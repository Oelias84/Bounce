//
//  UserPreferredWorkout.swift
//  FitApp
//
//  Created by Ofir Elias on 15/03/2023.
//

import Foundation

struct UserPreferredWorkouts: Codable {
    
    var homeWorkouts: [Workout]
    var gymWorkouts: [Workout]
}
