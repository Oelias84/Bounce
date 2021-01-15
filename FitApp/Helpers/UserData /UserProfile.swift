//
//  UserProfile.swift
//  FitApp
//
//  Created by Ofir Elias on 24/11/2020.
//

import Foundation


struct UserProfile {
    
    static var defaults = UserProfile()
    
    @UserDefault(key: .finishOnboarding)
    var finishOnboarding: Bool?
    
    @UserDefault(key: .id)
	var id: String?
    
    //UserBasicDetails
    @UserDefault(key: .name)
    var name: String?
    
    @UserDefault(key: .birthDate)
    var birthDate: Date?
    
    @UserDefault(key: .weight)
    var weight: Double?
    
    @UserDefault(key: .height)
    var height: Int?
    
    //UserFatPercentage
    @UserDefault(key: .fatPercentage)
    var fatPercentage: Double?
    
    //UserActivity
    @UserDefault(key: .kilometer)
    var kilometer: Double?
    
    @UserDefault(key: .steps)
    var steps: Int?
    
    //UserNutrition
    @UserDefault(key: .mealsPerDay)
    var mealsPerDay: Int?
    
    @UserDefault(key: .mostHungry)
    var mostHungry: Int?
    
    //UserFitnessLevel
    @UserDefault(key: .fitnessLevel)
    var fitnessLevel: Int?
    
    @UserDefault(key: .weaklyWorkouts)
    var weaklyWorkouts: Int?
}

extension UserProfile {
    
    func updateUserProfileData(_ data: ServerUserData, id: String) {
        var userProfile = self
        
        userProfile.id = id
        userProfile.finishOnboarding = data.finishOnboarding
        userProfile.name = data.name
        userProfile.birthDate = data.birthDate.dateFromString
        userProfile.weight = data.weight
        userProfile.height = data.height
        userProfile.fatPercentage = data.fatPercentage
        userProfile.kilometer = data.kilometer
        userProfile.mealsPerDay = data.mealsPerDay
        userProfile.mostHungry = data.mostHungry
        userProfile.fitnessLevel = data.fitnessLevel
        userProfile.weaklyWorkouts = data.weaklyWorkouts
    }
}

struct ServerUserData: Codable {
    
    let name: String
    let birthDate: String
    let weight: Double
    let height: Int
    let fatPercentage: Double
    let steps: Int?
    let kilometer: Double?
    let mealsPerDay: Int
    let mostHungry: Int
    let fitnessLevel: Int
    let weaklyWorkouts: Int
    let finishOnboarding: Bool
}

//MARK: - UserDate Keys
extension Key {
    
    static let id: Key = "id"
    static let name: Key = "name"
    static let birthDate: Key = "birthDate"
    static let weight: Key = "weight"
    static let height: Key = "height"
    static let fatPercentage: Key = "fatPercentage"
    static let kilometer: Key = "kilometer"
    static let steps: Key = "steps"
    static let mealsPerDay: Key = "mealsPerDay"
    static let mostHungry: Key = "mostHungry"
    static let fitnessLevel: Key = "fitnessLevel"
    static let weaklyWorkouts: Key = "weaklyWorkouts"
    static let finishOnboarding: Key = "finishOnboarding"
}


