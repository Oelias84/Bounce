//
//  UserProfile.swift
//  FitApp
//
//  Created by Ofir Elias on 24/11/2020.
//

import Foundation

enum Gender: String, Codable {
	case male
	case female
}

struct UserProfile {
    
    static var defaults = UserProfile()
	
	@UserDefault(key: .checkedTermsOfUse)
	var checkedTermsOfUse: Bool?
	
	@UserDefault(key: .permissionsLevel)
	var permissionsLevel: Int?
	
	@UserDefault(key: .gander)
	var gander: String?
	
	@UserDefault(key: .hasRunBefore)
	var hasRunBefore: Bool?
	
	@UserDefault(key: .showQaAlert)
	var showQaAlert: Bool?
	
	@UserDefault(key: .showMealNotFinishedAlert)
	var showMealNotFinishedAlert: Bool?
	
	@UserDefault(key: .shouldShowCaloriesCheckAlert)
	var shouldShowCaloriesCheckAlert: Bool?
	
	@UserDefault(key: .lastCaloriesCheckDateString)
	var lastCaloriesCheckDateString: String?
	
	@UserDefault(key: .motivationText)
	var motivationText: String?
	
	@UserDefault(key: .lastMotivationDate)
	var lastMotivationDate: Date?
	
	@UserDefault(key: .finishOnboarding)
	var finishOnboarding: Bool?
	
	@UserDefault(key: .id)
	var id: String?
	
	@UserDefault(key: .fcmToken)
	var fcmToken: String?
	
	@UserDefault(key: .email)
	var email: String?
	
	@UserDefault(key: .profileImageImageUrl)
	var profileImageImageUrl: String?
	
	@UserDefault(key: .lastWightImageUrl)
	var lastWightImageUrl: String?
	
    //UserBasicDetails
    @UserDefault(key: .name)
    var name: String?
    
    @UserDefault(key: .birthDate)
    var birthDate: Date?
    
    @UserDefault(key: .weight)
    var weight: Double?
    
	@UserDefault(key: .currentAverageWeight)
	var currentAverageWeight: Double?
	
    @UserDefault(key: .height)
    var height: Int?
	
	@UserDefault(key: .lifeStyle)
	var lifeStyle: Double?
    
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
	
	@UserDefault(key: .externalWorkout)
	var externalWorkout: Int?
	
	//MealData
	@UserDefault(key: .otherDishes)
	var otherDishes: [String]?
}

extension UserProfile {
	
	var getGender: Gender? {
		get {
			switch gander {
			case "female":
				return .female
			case "male":
				return .male
			default:
				return nil
			}
		}
	}
	var getIsManager: Bool? {
		get {
			switch permissionsLevel {
			case 1:
				return false
			case 2:
				return true
			default:
				return nil
			}
		}
	}
	static func getLifeStyleText() -> String {
		
		switch defaults.lifeStyle {
		case 1.2:
			return "אורח חיים יושבני"
		case 1.3:
			return "אורח חיים פעיל מתון"
		case 1.5:
			return "אורח חיים פעיל"
		case 1.6:
			return "אורח חיים פעיל מאוד"
		default:
			return ""
		}
	}
	static func updateServer() {
		let googleManager = GoogleApiManager()
		
		let data = ServerUserData (
			permissionsLevel: defaults.permissionsLevel,
			checkedTermsOfUse: defaults.checkedTermsOfUse,
			gander: defaults.gander,
			lastCaloriesCheckDateString: defaults.lastCaloriesCheckDateString,
			birthDate: defaults.birthDate?.dateStringForDB,
			email: defaults.email,
			name: defaults.name,
			weight: defaults.weight,
			currentAverageWeight: defaults.currentAverageWeight,
			height: defaults.height,
			fatPercentage: defaults.fatPercentage,
			steps: defaults.steps,
			kilometer: defaults.kilometer,
			lifeStyle: defaults.lifeStyle,
			mealsPerDay: defaults.mealsPerDay,
			mostHungry: defaults.mostHungry,
			fitnessLevel: defaults.fitnessLevel,
			weaklyWorkouts: defaults.weaklyWorkouts,
			externalWorkout: defaults.externalWorkout,
			finishOnboarding: defaults.finishOnboarding
		)
		googleManager.updateUserData(userData: data)
	}
	func updateUserProfileData(_ data: ServerUserData, id: String) {
		var userProfile = self
		
		userProfile.permissionsLevel = data.permissionsLevel
		userProfile.checkedTermsOfUse = data.checkedTermsOfUse
		userProfile.gander = data.gander
		userProfile.lastCaloriesCheckDateString = data.lastCaloriesCheckDateString
		userProfile.id = id
		userProfile.name = data.name
		userProfile.email = data.email
		userProfile.finishOnboarding = data.finishOnboarding
		userProfile.birthDate = data.birthDate?.dateFromString
		userProfile.weight = data.weight
		userProfile.currentAverageWeight = data.currentAverageWeight
		userProfile.height = data.height
		userProfile.fatPercentage = data.fatPercentage
		userProfile.kilometer = data.kilometer
		userProfile.mealsPerDay = data.mealsPerDay
		userProfile.lifeStyle = data.lifeStyle
		userProfile.mostHungry = data.mostHungry
		userProfile.fitnessLevel = data.fitnessLevel
		userProfile.weaklyWorkouts = data.weaklyWorkouts
		userProfile.externalWorkout = data.externalWorkout
	}
	func resetUserProfileData() {
		var userProfile = UserProfile.defaults
		
		userProfile.permissionsLevel = nil
		userProfile.checkedTermsOfUse = nil
		userProfile.gander = nil
		userProfile.lastCaloriesCheckDateString = nil
		userProfile.id = nil
		userProfile.name = nil
		userProfile.email = nil
		userProfile.finishOnboarding = nil
		userProfile.birthDate = nil
		userProfile.weight = nil
		userProfile.currentAverageWeight = nil
		userProfile.height = nil
		userProfile.fatPercentage = nil
		userProfile.kilometer = nil
		userProfile.mealsPerDay = nil
		userProfile.lifeStyle = nil
		userProfile.mostHungry = nil
		userProfile.fitnessLevel = nil
		userProfile.weaklyWorkouts = nil
		userProfile.externalWorkout = nil
	}
}

struct ServerUserData: Codable {
	
	let permissionsLevel: Int?
	let checkedTermsOfUse: Bool?
	let gander: String?
	let lastCaloriesCheckDateString: String?
	let birthDate: String?
	let email: String?
	let name: String?
    let weight: Double?
	let currentAverageWeight: Double?
    let height: Int?
    let fatPercentage: Double?
    let steps: Int?
    let kilometer: Double?
	let lifeStyle: Double?
	let mealsPerDay: Int?
	let mostHungry: Int?
	let fitnessLevel: Int?
	let weaklyWorkouts: Int?
	let externalWorkout: Int?
	let finishOnboarding: Bool?
}

//MARK: - UserData Keys
extension Key {
	
	//check if app been used before
	static let hasRunBefore: Key = "hasRunBefore"
	
	//show alerts
	static let showQaAlert: Key = "showQaAlert"
	static let showMealNotFinishedAlert: Key = "showMealNotFinishedAlert"
	static let shouldShowCaloriesCheckAlert: Key = "shouldShowCaloriesCheckAlert"
	
	//motivations
	static let lastMotivationDate: Key = "lastMotivationDate"
	static let motivationText: Key = "motivationText"
	
	//User Calories Check Data
	static let lastCaloriesCheckDateString: Key = "lastCaloriesCheckDateString"
	
	//user data
	static let permissionsLevel: Key = "permissionsLevel"
	static let checkedTermsOfUse: Key = "checkedTermsOfUse"
	static let gander: Key = "gander"
	static let fcmToken: Key = "fcmToken"
	static let id: Key = "id"
	static let name: Key = "name"
	static let email: Key = "email"
	static let lastWightImageUrl: Key = "lastWightImageUrl"
	static let profileImageImageUrl: Key = "profileImageImageUrl"
	static let birthDate: Key = "birthDate"
	static let weight: Key = "weight"
	static let currentAverageWeight: Key = "currentAverageWeight"
	static let height: Key = "height"
	static let fatPercentage: Key = "fatPercentage"
	static let kilometer: Key = "kilometer"
	static let lifeStyle: Key = "lifeStyle"
	static let steps: Key = "steps"
	static let mealsPerDay: Key = "mealsPerDay"
	static let mostHungry: Key = "mostHungry"
	static let fitnessLevel: Key = "fitnessLevel"
	static let weaklyWorkouts: Key = "weaklyWorkouts"
	static let externalWorkout: Key = "externalWorkout"
	static let finishOnboarding: Key = "finishOnboarding"
	static let otherDishes: Key = "otherDishes"
}


