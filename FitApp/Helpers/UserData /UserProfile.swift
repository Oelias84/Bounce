//
//  UserProfile.swift
//  FitApp
//
//  Created by Ofir Elias on 24/11/2020.
//

import UIKit
import Foundation

enum Gender: String, Codable {
	case male
	case female
}

struct UserProfile {
	
	static var defaults = UserProfile()
	
	var userProfileImage: UIImage?
	
	var termsApproval: TermsAgreeDataModel? {
		set {
			self.encodeTermAndSet(name: "termsApproval", newValue)
		}
		get {
			self.getTermsAndDecode(name: "termsApproval")
		}
	}
	var healthApproval: TermsAgreeDataModel? {
		set {
			self.encodeTermAndSet(name: "healthApproval", newValue)
		}
		get {
			self.getTermsAndDecode(name: "healthApproval")
		}
	}

	@UserDefault(key: .expirationDate)
	var expirationDate: String?
	
	@UserDefault(key: .currentAppVersion)
	var currentAppVersion: String?
	
	@UserDefault(key: .currentWeight)
	var currentWeight: Double?
	
	@UserDefault(key: .permissionLevel)
	var permissionLevel: Int?
	
	@UserDefault(key: .gender)
	var gender: String?
	
	@UserDefault(key: .hasRunBefore)
	var hasRunBefore: Bool?
	
	@UserDefault(key: .showQaAlert)
	var showQaAlert: Bool?
    
    @UserDefault(key: .showWeightAlertNotification)
    var showWeightAlertNotification: Bool?
    
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
    
    @UserDefault(key: .naturalMenu)
    var naturalMenu: Bool?

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
	
	@UserDefault(key: .lastWeightAlertPresentedDate)
	var lastWeightAlertPresentedDate: Date?

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
	@UserDefault(key: .otherCatrbDishes)
	var otherCarbDishes: [String]?
    
    @UserDefault(key: .otherFatDishes)
    var otherFatDishes: [String]?
    
    @UserDefault(key: .otherProtainDishes)
    var otherProtainDishes: [String]?
	
	func encodeTermAndSet(name: String,_ data: TermsAgreeDataModel?) {
		let userDefaults = UserDefaults.standard
		
		do {
			try userDefaults.setObject(data, forKey: name)
		} catch {
			print(error.localizedDescription)
		}
	}
	func getTermsAndDecode(name: String) -> TermsAgreeDataModel? {
		let userDefaults = UserDefaults.standard
		
		do {
			let termsAgreeData = try userDefaults.getObject(forKey: name, castTo: TermsAgreeDataModel.self)
			return termsAgreeData
		} catch {
			print(error.localizedDescription)
			return nil
		}
	}
}

extension UserProfile {
		
	var getGender: Gender? {
		get {
			switch gender {
			case "female":
				return .female
			case "male":
				return .male
			default:
				return nil
			}
		}
	}
	var getIsManager: Bool {
		get {
			return permissionLevel == 99
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
        let googleManager = GoogleApiManager.shared
		
		let data = ServerUserData (
			termsApproval: defaults.termsApproval,
			healthApproval: defaults.termsApproval,
			gender: defaults.gender,
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
            naturalMenu: defaults.naturalMenu,
			finishOnboarding: defaults.finishOnboarding
		)
		googleManager.updateUserData(userData: data)
	}
	func updateUserProfileData(_ data: ServerUserData, id: String) {
		var userProfile = self
		
		userProfile.expirationDate = data.expirationDate
		userProfile.currentAppVersion = data.currentAppVersion
		userProfile.currentWeight = data.currentWeight
		userProfile.permissionLevel = data.permissionLevel
		userProfile.termsApproval = data.termsApproval
		userProfile.healthApproval = data.healthApproval
		userProfile.gender = data.gender
		userProfile.lastCaloriesCheckDateString = data.lastCaloriesCheckDateString
		userProfile.id = id
		userProfile.name = data.name
		userProfile.email = data.email
        userProfile.naturalMenu = data.naturalMenu
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
		
		userProfile.expirationDate = nil
		userProfile.currentAppVersion = nil
		userProfile.currentWeight = nil
		userProfile.userProfileImage = nil
		userProfile.permissionLevel = nil
		userProfile.healthApproval = nil
		userProfile.termsApproval = nil
		userProfile.gender = nil
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
		userProfile.lastWeightAlertPresentedDate = nil
	}
	func resetUserData() {
		UserDefaults.resetDefaults()
		UserProfile.defaults.resetUserProfileData()
		ConsumptionManager.shared.resetConsumptionManager()
		GoogleDatabaseManager.shared.removeUserPushTokenFromChat()
	}
}

struct ServerUserData: Codable {
	
	var expirationDate: String?
	var currentAppVersion: String?
	var currentWeight: Double?
	var permissionLevel: Int?
	var termsApproval: TermsAgreeDataModel?
	var healthApproval: TermsAgreeDataModel?
	var gender: String?
	var lastCaloriesCheckDateString: String?
	var birthDate: String?
	var email: String?
	var name: String?
	var weight: Double?
	var currentAverageWeight: Double?
	var height: Int?
	var fatPercentage: Double?
	var steps: Int?
	var kilometer: Double?
	var lifeStyle: Double?
	var mealsPerDay: Int?
	var mostHungry: Int?
	var fitnessLevel: Int?
	var weaklyWorkouts: Int?
	var externalWorkout: Int?
    var naturalMenu: Bool?
	var finishOnboarding: Bool?
	
	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(termsApproval, forKey: .termsApproval)
		try container.encode(healthApproval, forKey: .healthApproval)
		try container.encode(gender, forKey: .gender)
		try container.encode(lastCaloriesCheckDateString, forKey: .lastCaloriesCheckDateString)
		try container.encode(birthDate, forKey: .birthDate)
		try container.encode(email, forKey: .email)
		try container.encode(name, forKey: .name)
		try container.encode(weight, forKey: .weight)
		try container.encode(currentAverageWeight, forKey: .currentAverageWeight)
		try container.encode(height, forKey: .height)
		try container.encode(fatPercentage, forKey: .fatPercentage)
		try container.encode(steps, forKey: .steps)
		try container.encode(kilometer, forKey: .kilometer)
		try container.encode(lifeStyle, forKey: .lifeStyle)
		try container.encode(mealsPerDay, forKey: .mealsPerDay)
		try container.encode(mostHungry, forKey: .mostHungry)
		try container.encode(fitnessLevel, forKey: .fitnessLevel)
		try container.encode(weaklyWorkouts, forKey: .weaklyWorkouts)
		try container.encode(externalWorkout, forKey: .externalWorkout)
        try container.encode(naturalMenu, forKey: .naturalMenu)
		try container.encode(finishOnboarding, forKey: .finishOnboarding)

	}
}
class TermsAgreeDataModel: Codable {
	
	var appVersion: String = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
	var date: String = "\(Date().dateStringForDB)"
	var platform: String = "IOS"
}

//MARK: - UserData Keys
extension Key {
	
	//check if app been used before
	static let hasRunBefore: Key = "hasRunBefore"
	
	//show alerts
	static let showQaAlert: Key = "showQaAlert"
	static let showMealNotFinishedAlert: Key = "showMealNotFinishedAlert"
    static let showWeightAlertNotification: Key = "showWeightAlertNotification"
	static let shouldShowCaloriesCheckAlert: Key = "shouldShowCaloriesCheckAlert"
	
	//motivations
	static let lastMotivationDate: Key = "lastMotivationDate"
	static let motivationText: Key = "motivationText"
	
	//User Calories Check Data
	static let lastCaloriesCheckDateString: Key = "lastCaloriesCheckDateString"
	
	//user data
	static let expirationDate: Key = "expirationDate"
	static let currentAppVersion: Key = "currentAppVersion"
	static let currentWeight: Key = "currentWeight"
	static let lastWeightAlertPresentedDate: Key = "lastWeightAlertPresentedDate"
	static let permissionLevel: Key = "permissionLevel"
	static let termsApproval: Key = "termsApproval"
	static let healthApproval: Key = "healthApproval"
	static let gender: Key = "gender"
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
    static let naturalMenu: Key = "naturalMenu"
	static let finishOnboarding: Key = "finishOnboarding"
	static let otherCatrbDishes: Key = "otherCatrbDishes"
    static let otherFatDishes: Key = "otherFatDishes"
    static let otherProtainDishes: Key = "otherProtainDishes"
}

