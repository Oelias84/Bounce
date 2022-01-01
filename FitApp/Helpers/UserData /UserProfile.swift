//
//  UserProfile.swift
//  FitApp
//
//  Created by Ofir Elias on 24/11/2020.
//

import Foundation


struct UserProfile {
    
    static var defaults = UserProfile()
	
	@UserDefault(key: .checkedTermsOfUse)
	var checkedTermsOfUse: Bool?
	
	@UserDefault(key: .isManager)
	var isManager: Bool?
	
	@UserDefault(key: .userGander)
	var userGander: Int?

	@UserDefault(key: .hasRunBefore)
	var hasRunBefore: Bool?
	
	@UserDefault(key: .showQaAlert)
	var showQaAlert: Bool?
	
	@UserDefault(key: .showMealNotFinishedAlert)
	var showMealNotFinishedAlert: Bool?
	
	@UserDefault(key: .shouldShowCaloriesCheckAlert)
	var shouldShowCaloriesCheckAlert: Bool?
	
	@UserDefault(key: .lastCaloriesCheckDate)
	var lastCaloriesCheckDate: Date?
	
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
    
	static func updateServer() {
		let googleManager = GoogleApiManager()
		
		let data = ServerUserData (
			isManager: defaults.isManager,
			checkedTermsOfUse: defaults.checkedTermsOfUse,
			userGander: defaults.userGander,
			lastCaloriesCheckDate: defaults.lastCaloriesCheckDate,
			birthDate: defaults.birthDate?.dateStringForDB,
			email: defaults.email!,
			name: defaults.name!,
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
	func updateUserProfileData(_ data: ServerUserData, id: String) {
		var userProfile = self
		
		userProfile.isManager = data.isManager
		userProfile.checkedTermsOfUse = data.checkedTermsOfUse
		userProfile.userGander = data.userGander
		userProfile.lastCaloriesCheckDate = data.lastCaloriesCheckDate
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
		
		userProfile.isManager = nil
		userProfile.checkedTermsOfUse = nil
		userProfile.userGander = nil
		userProfile.lastCaloriesCheckDate = nil
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
	
	let isManager: Bool?
	let checkedTermsOfUse: Bool?
	let userGander: Int?
	let lastCaloriesCheckDate: Date?
	let birthDate: String?
	let email: String
	let name: String
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

//MARK: - UserDate Keys
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
	static let lastCaloriesCheckDate: Key = "lastCaloriesCheckDate"
	
	//user data
	static let isManager: Key = "isManager"
	static let checkedTermsOfUse: Key = "checkedTermsOfUse"
	static let userGander: Key = "userGander"
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


