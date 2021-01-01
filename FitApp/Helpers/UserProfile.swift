//
//  UserProfile.swift
//  FitApp
//
//  Created by Ofir Elias on 24/11/2020.
//

import Foundation

class UserProfile {
	
	private let standard = UserDefaults.standard
	static var shared = UserProfile()
	
	var id: String?{
		didSet{
			standard.set(id, forKey: K.User.id)
		}
	}
    //UserBasicDetails
	var name: String?{
		didSet{
			standard.set(name, forKey: K.User.name)
		}
	}
    var birthDate: Date? {
        didSet {
            standard.set(birthDate, forKey: K.User.UserBasicDetails.birthDate)
        }
    }
    var weight: Double? {
        didSet {
            standard.set(weight, forKey: K.User.UserBasicDetails.weight)
        }
    }
    var height: Int? {
        didSet {
            standard.set(height, forKey: K.User.UserBasicDetails.height)
        }
    }
    //UserFatPercentage
    var fatPercentage: Double? {
        didSet {
            standard.set(fatPercentage, forKey: K.User.UserFatPercentage.fatPercentage)
        }
    }
    //UserActivity
    var kilometer: Double? {
        didSet {
            standard.set(kilometer, forKey: K.User.UserActivity.kilometers)
        }
    }
    var steps: Int? {
        didSet {
            standard.set(steps, forKey: K.User.UserActivity.steps)
        }
    }
    //UserNutrition
    var mealsPerDay: Int? {
        didSet {
            standard.set(mealsPerDay, forKey: K.User.UserNutrition.mealsPerDay)
        }
    }
    var mostHungry: Int? {
        didSet {
            standard.set(mostHungry, forKey: K.User.UserNutrition.mostHungry)
        }
    }
    var leastHungry: Int? {
        didSet {
            standard.set(leastHungry, forKey: K.User.UserNutrition.leastHungry)
        }
    }
    //UserFitnessLevel
    var fitnessLevel: Int? {
        didSet {
            standard.set(fitnessLevel, forKey: K.User.UserFitnessLevel.fitnessLevel)
        }
    }
    var weaklyWorkouts: Int? {
        didSet {
            standard.set(weaklyWorkouts, forKey: K.User.UserFitnessLevel.weaklyWorkouts)
        }
    }
}
