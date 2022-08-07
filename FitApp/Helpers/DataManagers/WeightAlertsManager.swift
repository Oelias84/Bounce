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
	private var lastCaloriesCheckDateString: Date?
	
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
	
	required init() {
#if DEBUG
		return
#endif
		if !UserProfile.defaults.getIsManager {
			setUserData() {
				self.configureData() {
					self.presentAlertForUserState()
				}
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
			UserProfile.defaults.lastCaloriesCheckDateString = lastCaloriesCheckDateString?.dateStringForDB
			
			//Calculate calories consumed over the last week
			calculateConsumedCaloriesFormPastWeek()
			
			completion()
		} else if let lastCheck = lastCaloriesCheckDateString?.onlyDate, today.isLaterThanOrEqual(to: lastCheck.add(1.weeks)) {
			
			//Set true on show alert
			shouldShowAlertToUser = true
			UserProfile.defaults.shouldShowCaloriesCheckAlert = true
			
			//Fill the arrays with weight data
			calculateWeights()
			
			//Calculate calories consumed over the last week
			calculateConsumedCaloriesFormPastWeek()
			
			completion()
		}
	}
	
	//MARK: - Server Handeling
	private func getWeights(completion: @escaping () -> ()) {
		
//		WeightsManager.shared.fetchWeight() {
//			[weak self] weights in
//			guard let self = self else { return }
//
//			self.userWeights = weights.sorted()
//			completion()
//		}
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
		guard let lastCaloriesCheckDateString = UserProfile.defaults.lastCaloriesCheckDateString?.dateFromString else { return }
		
		//Update the update calories progress state
		let data = CaloriesProgressState(date: lastCaloriesCheckDateString, userCaloriesBetweenConsumedAndGiven: userCaloriesBetweenConsumedAndGiven, userWeekConsumedCalories: userConsumedCalories, userWeekExpectedCalories: userExpectedDailyCalories, firstWeekAverageWeight: firstWeekAverageWeight, secondWeekAverageWeight: secondWeekAverageWeight)
		
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
			$0.meals.first!.date.onlyDate.isLaterThanOrEqual(to: firstDayForCalculatedWeek) &&
			$0.meals.first!.date.onlyDate.isEarlier(than: firstDayForCalculatedWeek.add(1.weeks).start(of: .day))
		}
		
		let consumedCalories = DailyMealManager.calculateMealAverageCalories(meals: mealsConsumedInPeriod)
		userExpectedDailyCalories = DailyMealManager.calculateMealExpectedCalories(meals: mealsConsumedInPeriod)
		userCaloriesBetweenConsumedAndGiven = consumedCalories - userExpectedDailyCalories
		userConsumedCalories = consumedCalories
	}
	
	//MARK: - Alerts
	private func presentAlertForUserState() {
		guard shouldShowAlertToUser != false, firstWeekAverageWeight != nil, secondWeekAverageWeight != nil else { return }
		
		//Weight Calculation
		let expectedWeightRange = 0.5...1.5
		let differenceBetweenWeight = Double(String(format: "%.2f", firstWeekAverageWeight))! - Double(String(format: "%.2f", secondWeekAverageWeight))!
		let differenceBetweenWeightPercentage = (differenceBetweenWeight / firstWeekAverageWeight) * 100
		
		if (shouldShowNotEnoughDataAlert || differenceBetweenWeight.isNaN) {
			//Present an alert that the user dose not have enough data to calculate calories
			let message = MessagesTextManager().notEnoughDataAlert()
			self.presentAlert(title: nil, message: message)
		} else if shouldShowAlertToUser ?? false {
			updateAverageWeight()
			
			let newMeals = MealViewModel.shared.createMealsForNewUserData()
			let newCalories = DailyMealManager.getCurrentMealsCalories(meals: newMeals)
			
			//Present an alert depending on the calories calculation
			//Check smaller calories consumed from the last week
			if differenceBetweenWeightPercentage < expectedWeightRange.lowerBound {
				
				if userConsumedCalories < userExpectedDailyCalories {
					//Send Message 1
					let message = MessagesTextManager(weightState: .gainWeight, calorieState: .smallerThenAverage, newCalories: Double(newCalories) ?? 0).composeMessage()
					self.presentAlert(title: message.0, message: message.1)
				} else if userConsumedCalories > userExpectedDailyCalories {
					//Send Message 2
					let message = MessagesTextManager(weightState: .gainWeight, calorieState: .higherThenAverage, newCalories: Double(newCalories) ?? 0).composeMessage()
					self.presentAlert(title: message.0, message: message.1)
				} else {
					//Send Message 3
					let message = MessagesTextManager(weightState: .gainWeight, calorieState: .average, newCalories: Double(newCalories) ?? 0).composeMessage()
					self.presentAlert(title: message.0, message: message.1)
				}
				
				//Check bigger calories consumed from the last week
			} else if differenceBetweenWeightPercentage > expectedWeightRange.upperBound {
				
				if userConsumedCalories < userExpectedDailyCalories {
					//Send Message 1
					let message = MessagesTextManager(weightState: .lowerThenExpected, calorieState: .smallerThenAverage, newCalories: Double(newCalories) ?? 0).composeMessage()
					self.presentAlert(title: message.0, message: message.1)
				} else if userConsumedCalories > userExpectedDailyCalories {
					//Send Message 2
					let message = MessagesTextManager(weightState: .lowerThenExpected, calorieState: .higherThenAverage, newCalories: Double(newCalories) ?? 0).composeMessage()
					self.presentAlert(title: message.0, message: message.1)
				} else {
					//Send Message 3
					let message = MessagesTextManager(weightState: .lowerThenExpected, calorieState: .average, newCalories: Double(newCalories) ?? 0).composeMessage()
					self.presentAlert(title: message.0, message: message.1)
				}
				
				//Check average calories consumed from the last week
			} else if expectedWeightRange.contains(differenceBetweenWeightPercentage) {
				
				if userConsumedCalories < userExpectedDailyCalories {
					//Send Message 1
					let message = MessagesTextManager(weightState: .asExpected, calorieState: .smallerThenAverage, newCalories: Double(newCalories) ?? 0).composeMessage()
					presentAlert(title: message.0, message: message.1)
				} else if userConsumedCalories > userExpectedDailyCalories {
					//Send Message 2
					let message = MessagesTextManager(weightState: .asExpected, calorieState: .higherThenAverage, newCalories: Double(newCalories) ?? 0).composeMessage()
					presentAlert(title: message.0, message: message.1)
				} else {
					//Send Message 3
					let message = MessagesTextManager(weightState: .asExpected, calorieState: .average, newCalories: Double(newCalories) ?? 0).composeMessage()
					presentAlert(title: message.0, message: message.1)
				}
			}
		}
	}
	private func presentAlert(title: String?, message: String) {
		let weightAlert = UIAlertController(title: title ,message: message, preferredStyle: .alert)
		
		weightAlert.addAction(UIAlertAction(title: "הבנתי, תודה", style: .default) { _ in
			//Update User Data
			self.shouldShowAlertToUser = false
			
			UserProfile.defaults.shouldShowCaloriesCheckAlert = self.shouldShowAlertToUser
			UserProfile.defaults.lastCaloriesCheckDateString = self.todayDate.dateStringForDB
			
			self.updateUserCaloriesProgress()
			UserProfile.updateServer()
			
			if let text = weightAlert.message {
				self.sendMessageToManager(title: title, text: text)
			}
		})
		weightAlert.showAlert()
	}
	
	//MARK: - Notification
	private func sendMessageToManager(title: String?, text: String) {
		
		DispatchQueue.global(qos: .background).async {
			MessagesManager.shared.bindMessageManager = {
				MessagesManager.shared.sendMassageToSupport(messageText: (title ?? "") + "\n\n" + text)
			}
		}
	}
}
