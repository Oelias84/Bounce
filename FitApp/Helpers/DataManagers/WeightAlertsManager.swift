//
//  WeightNotificationsManager.swift
//  FitApp
//
//  Created by Ofir Elias on 11/09/2021.
//

import UIKit
import Foundation

enum CaloriesAlertsState: String {
	
	case smallerThen
	case inRange
	case biggerThen
	case notEnoughData
}

class WeightAlertsManager {
	
	private var userWeights: [Weight]!
	private var userDailyMeals: [DailyMeal]!
	
	private var userConsumedCalories: Double!
	private var userCaloriesBetweenConsumedAndGiven: Double!
	private var userExpectedDailyCalories: Double!
	
	private var shouldShowAlertToUser: Bool!
	private var shouldShowNotEnoughDataAlert = false
	
	private var todayDate: Date!
	private var lastCaloriesCheckDateString: Date? {
		didSet {
			UserProfile.defaults.lastCaloriesCheckDateString = lastCaloriesCheckDateString?.dateStringForDB
			UserProfile.updateServer()
		}
	}
	
	private var firstWeekWeightsArray: [Weight]! {
		didSet {
			shouldShowNotEnoughDataAlert = firstWeekWeightsArray.count < 3
			firstWeekAverageWeight = (firstWeekWeightsArray.reduce(0) { $0 + $1.weight }) / Double(firstWeekWeightsArray.count)
		}
	}
	private var secondWeekWeightsArray: [Weight]! {
		didSet {
			shouldShowNotEnoughDataAlert = secondWeekWeightsArray.count < 3
			secondWeekAverageWeight = (secondWeekWeightsArray.reduce(0) { $0 + $1.weight}) / Double(secondWeekWeightsArray.count)
		}
	}
	
	private var firstWeekAverageWeight: Double!
	private var secondWeekAverageWeight: Double!
	
	private let messagesManager = MessagesManager.shared
	
	required init() {
		if UserProfile.defaults.getIsManager ?? false { return }
		
		setUserData() {
			self.configureData() {
				self.presentAlertForUserState()
			}
		}
	}
}

//MARK: - Functions
extension WeightAlertsManager {
	
	//MARK: - Configuration
	private func setUserData(completion: @escaping (() -> ())) {
		let group = DispatchGroup()
		todayDate = Date().onlyDate
		ConsumptionManager.shared.calculateUserData()
		
//		UserProfile.defaults.lastCaloriesCheckDateString = nil
//		UserProfile.defaults.shouldShowCaloriesCheckAlert = nil

		lastCaloriesCheckDateString = UserProfile.defaults.lastCaloriesCheckDateString?.dateFromString
		shouldShowAlertToUser = UserProfile.defaults.shouldShowCaloriesCheckAlert
		
		if let lastCheck = lastCaloriesCheckDateString, todayDate >= lastCheck.add(1.weeks) {
			UserProfile.defaults.shouldShowCaloriesCheckAlert = true
		}
		
		group.enter()
		self.getWeights {
			group.leave()
		}
		group.enter()
		self.getAllMeals {
			group.leave()
		}
		group.notify(queue: .global()) {
			completion()
		}
	}
	private func configureData(completion: @escaping (() -> ())) {
		let today = Date().onlyDate
		guard let firstUserWeightDate = userWeights.first?.date.onlyDate else { return }
		
		//If user didn't change shouldShowAlertToUser to false
		if lastCaloriesCheckDateString?.onlyDate != nil ,shouldShowAlertToUser == true {
			
			//Fill the arrays with weight data
			calculateWeights()
			
			//Calculate calories consumed over the last week
			calculateConsumedCaloriesFormPastWeek()
			
			completion()
			//First time check
		} else if lastCaloriesCheckDateString == nil, today.isLaterThanOrEqual(to: firstUserWeightDate.add(2.weeks)) {
			
			//Set true on show alert
			shouldShowAlertToUser = true
			UserProfile.defaults.shouldShowCaloriesCheckAlert = true
			
			//Fill the arrays with weight data
			calculateWeights()
			
			//Update last check date
			lastCaloriesCheckDateString = firstUserWeightDate.add(2.weeks)
			
			//Calculate calories consumed over the last week
			calculateConsumedCaloriesFormPastWeek()
			
			completion()
			
		} else if let lastCheck = lastCaloriesCheckDateString?.onlyDate, today.isLaterThanOrEqual(to: lastCheck.add(1.weeks)) {
			
			//Set true on show alert
			shouldShowAlertToUser = true
			UserProfile.defaults.shouldShowCaloriesCheckAlert = true
			
			//Fill the arrays with weight data
			calculateWeights()
			
			//Update last check date
			lastCaloriesCheckDateString = today
			
			//Calculate calories consumed over the last week
			calculateConsumedCaloriesFormPastWeek()
			
			completion()
		}
	}
	
	//MARK: - Server Handeling
	private func getWeights(completion: @escaping () -> ()) {
		
		WeightsManager.shared.fetchWeight() {
			[weak self] weights in
			guard let self = self else { return }
			
			self.userWeights = weights.sorted()
			completion()
		}
	}
	private func getAllMeals(completion: @escaping () -> ()) {
		
		GoogleApiManager.shared.getAllMeals {
			[weak self] result in
			guard let self = self else { return }
			
			switch result {
			case .success(let dailyMeals):
				guard let dailyMeals = dailyMeals else { return }
				self.userDailyMeals = dailyMeals
				completion()
			case .failure(let error):
				print(error)
				completion()
			}
		}
	}
	private func updateUserCaloriesProgress() {
		let data = CaloriesProgressState(date: lastCaloriesCheckDateString!, userCaloriesBetweenConsumedAndGiven: userCaloriesBetweenConsumedAndGiven, userWeekConsumedCalories: userConsumedCalories, userWeekExpectedCalories: userExpectedDailyCalories, firstWeekAverageWeight: firstWeekAverageWeight, secondWeekAverageWeight: secondWeekAverageWeight)
		
		GoogleApiManager.shared.updateCaloriesProgressState(data: data)
	}
	private func updateAverageWeight() {
		//Update the week average weights for calories consumption update
		UserProfile.defaults.currentAverageWeight = secondWeekAverageWeight
		UserProfile.updateServer()
	}
	
	//MARK: - Calculation
	private func calculateWeights() {
		
		if Date().onlyDate.isEarlier(than: userWeights.first!.date.onlyDate.add(3.weeks)) {
			guard let firstWeekDate = userWeights.first?.date.onlyDate else { return }
			
			firstWeekWeightsArray = userWeights.filter {
				$0.date.onlyDate.isLaterThanOrEqual(to: firstWeekDate) &&
				$0.date.onlyDate.isEarlierThanOrEqual(to: firstWeekDate.add(1.weeks))
			}
			secondWeekWeightsArray = userWeights.filter {
				$0.date.onlyDate.isLaterThanOrEqual(to: firstWeekDate.add(1.weeks)) &&
				$0.date.onlyDate.isEarlierThanOrEqual(to: firstWeekDate.add(2.weeks))
			}
			
		} else {
			guard let firstWeekDate = lastCaloriesCheckDateString else { return }
			
			firstWeekWeightsArray = userWeights.filter {
				$0.date.onlyDate.isLaterThanOrEqual(to: firstWeekDate.subtract(1.weeks)) &&
				$0.date.onlyDate.isEarlierThanOrEqual(to: firstWeekDate)
			}
			secondWeekWeightsArray = userWeights.filter {
				$0.date.onlyDate.isLaterThanOrEqual(to: firstWeekDate) &&
				$0.date.onlyDate.isEarlierThanOrEqual(to: firstWeekDate.add(1.weeks))
			}
		}
	}
	private func calculateConsumedCaloriesFormPastWeek() {
		guard let lastCaloriesCheckDateString = lastCaloriesCheckDateString else { return }
		
		//If first check the take today and subtract a week else add take
		let firstDayForCalculatedWeek = lastCaloriesCheckDateString.subtract(1.weeks).start(of: .day)
		
		let mealsConsumedInPeriod = userDailyMeals.filter {
			$0.meals.first!.date.onlyDate.isLater(than: firstDayForCalculatedWeek) &&
			$0.meals.first!.date.onlyDate.isEarlier(than: firstDayForCalculatedWeek.add(1.weeks).start(of: .day))
		}
		
		let consumedCalories = DailyMealManager.calculateMealAverageCalories(meals: mealsConsumedInPeriod)
		
		userExpectedDailyCalories = DailyMealManager.calculateMealExpectedCalories(meals: mealsConsumedInPeriod)
		userCaloriesBetweenConsumedAndGiven = consumedCalories - userExpectedDailyCalories
		userConsumedCalories = consumedCalories
	}
	
	//MARK: - Notification
	private func sendMessageToManager(title: String, text: String) {
		
		//If chat exist send message and notification to support
		if let supportChat = self.messagesManager.userChats?.first(where: { $0.otherUserEmail == "support-mail-com" }) {
			self.messagesManager.postMassageToSupport(existingChatId: supportChat.id, otherUserEmail: supportChat.otherUserEmail, messageText: title + "\n" + text, chatOtherTokens: nil)
			
			//Chat dose not exist generate new support chat and send message and notification
		} else {
			self.messagesManager.generateUserSupportChat(completion: {
				newSupportChat in
				
				if let newChat = newSupportChat, let recipientTokens = newChat.otherUserTokens {
					self.messagesManager.postMassageToSupport(existingChatId: nil, otherUserEmail: newSupportChat?.otherUserEmail, messageText: title + "\n" + text, chatOtherTokens: recipientTokens)
				}
			})
		}
	}
	private func getManagerTokens(completion: @escaping ([String]) -> ()) {
		let database = GoogleDatabaseManager.shared
		
		DispatchQueue.global(qos: .background).async {
			database.getChatUsers { result in
				switch result {
				case .success(let users):
					
					for user in users {
						if user.email == "support-mail-com" {
							if let tokens = user.tokens {
								completion(tokens)
							}
						}
					}
				case .failure(let error):
					print(error.localizedDescription)
				}
			}
		}
	}
	
	//MARK: - Alerts
	private func presentAlertForUserState() {
		guard shouldShowAlertToUser != false, firstWeekAverageWeight != nil, secondWeekAverageWeight != nil else { return }
		
		//Weight Calculation
		let expectedWeightRange = 0.5...1.5
		let differenceBetweenWeight = firstWeekAverageWeight - secondWeekAverageWeight
		let differenceBetweenWeightPercentage = (differenceBetweenWeight / firstWeekAverageWeight) * 100
		
		
		updateUserCaloriesProgress()
		
		let newMeals = MealViewModel.shared.createMealsForNewUserData()
		let newCalories = DailyMealManager.getCurrentMealsCalories(meals: newMeals)
		
		if (shouldShowNotEnoughDataAlert || differenceBetweenWeight.isNaN) {
			//present an alert that the user dose not have enough data to calculate calories
			let message = MessagesTextManager().notEnoughDataAlert()
			self.presentAlert(title: "", message: message)
		} else if shouldShowAlertToUser ?? false {
			updateAverageWeight()
			
			//present an alert depending on the calories calculation
			if differenceBetweenWeightPercentage < expectedWeightRange.lowerBound {
				//Check average calories consumed from the last week
				if userConsumedCalories < userExpectedDailyCalories {
					//Send Message 1
					let message = MessagesTextManager(weightState: .lowerThenExpected, calorieState: .smallerThenAverage, newCalories: Double(newCalories) ?? 0).composeMessage()
					self.presentAlert(title: message.0, message: message.1)
//					userLostWeightAlert(caloriesConsumed: .smallerThen)
				} else if userConsumedCalories > userExpectedDailyCalories {
					//Send Message 2
					let message = MessagesTextManager(weightState: .lowerThenExpected, calorieState: .higherThenAverage, newCalories: Double(newCalories) ?? 0).composeMessage()
					self.presentAlert(title: message.0, message: message.1)
					
//					userLostWeightAlert(caloriesConsumed: .biggerThen)
				} else {
					//Send Message 3
					let message = MessagesTextManager(weightState: .lowerThenExpected, calorieState: .average, newCalories: Double(newCalories) ?? 0).composeMessage()
					self.presentAlert(title: message.0, message: message.1)

//					userLostWeightAlert(caloriesConsumed: .inRange)
				}
			} else if differenceBetweenWeightPercentage > expectedWeightRange.upperBound {
				updateAverageWeight()

				//Check average calories consumed from the last week
				if userConsumedCalories < userExpectedDailyCalories {
					//Send Message 1
					let message = MessagesTextManager(weightState: .gainWeight, calorieState: .higherThenAverage, newCalories: Double(newCalories) ?? 0).composeMessage()
					self.presentAlert(title: message.0, message: message.1)

//					userGainedWeightAlert(caloriesConsumed: .smallerThen)
				} else if userConsumedCalories > userExpectedDailyCalories {
					//Send Message 2
					let message = MessagesTextManager(weightState: .gainWeight, calorieState: .higherThenAverage, newCalories: Double(newCalories) ?? 0).composeMessage()
					self.presentAlert(title: message.0, message: message.1)

//					userGainedWeightAlert(caloriesConsumed: .biggerThen)
				} else {
					//Send Message 3
					let message = MessagesTextManager(weightState: .gainWeight, calorieState: .average, newCalories: Double(newCalories) ?? 0).composeMessage()
					self.presentAlert(title: message.0, message: message.1)
//					userGainedWeightAlert(caloriesConsumed: .inRange)
				}
			} else if expectedWeightRange.contains(differenceBetweenWeightPercentage) {
				updateAverageWeight()

				//Check average calories consumed from the last week
				if userConsumedCalories < userExpectedDailyCalories {

					//Send Message 1
					let message = MessagesTextManager(weightState: .asExpected, calorieState: .smallerThenAverage, newCalories: Double(newCalories) ?? 0).composeMessage()
					presentAlert(title: message.0, message: message.1)
//					userInRangeAlert(caloriesConsumed: .smallerThen)
				} else if userConsumedCalories > userExpectedDailyCalories {
					//Send Message 2
					let message = MessagesTextManager(weightState: .asExpected, calorieState: .higherThenAverage, newCalories: Double(newCalories) ?? 0).composeMessage()
					presentAlert(title: message.0, message: message.1)
//					userInRangeAlert(caloriesConsumed: .biggerThen)
				} else {
					//Send Message 3
					let message = MessagesTextManager(weightState: .asExpected, calorieState: .average, newCalories: Double(newCalories) ?? 0).composeMessage()
					presentAlert(title: message.0, message: message.1)
//					userInRangeAlert(caloriesConsumed: .inRange)
				}
			}
		}
	}
	private func presentAlert(title: String, message: String) {
		let weightAlert = UIAlertController(title: title ,message: message, preferredStyle: .alert)
		
		weightAlert.addAction(UIAlertAction(title: "הבנתי, תודה", style: .default) { _ in
			self.shouldShowAlertToUser = false
			UserProfile.defaults.shouldShowCaloriesCheckAlert = self.shouldShowAlertToUser
			
			if let text = weightAlert.message, self.lastCaloriesCheckDateString != Date().onlyDate {
				self.sendMessageToManager(title: title, text: text)
			}
		})
		weightAlert.showAlert()
	}
}
