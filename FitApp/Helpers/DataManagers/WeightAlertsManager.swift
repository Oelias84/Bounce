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
	private var lastCaloriesCheckDate: Date? {
		didSet {
			UserProfile.defaults.lastCaloriesCheckDate = lastCaloriesCheckDate
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
		
//		UserProfile.defaults.lastCaloriesCheckDate = nil
//		UserProfile.defaults.shouldShowCaloriesCheckAlert = nil

		lastCaloriesCheckDate = UserProfile.defaults.lastCaloriesCheckDate
		shouldShowAlertToUser = UserProfile.defaults.shouldShowCaloriesCheckAlert
		
		if let lastCheck = lastCaloriesCheckDate, todayDate >= lastCheck.add(1.weeks) {
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
		if lastCaloriesCheckDate?.onlyDate != nil ,shouldShowAlertToUser == true {
			
			//Fill the arrays with weight data
			calculateWeights()
			
			//Calculate calories consumed over the last week
			calculateConsumedCaloriesFormPastWeek()
			
			completion()
		 //First time check
		} else if lastCaloriesCheckDate == nil, today.isLaterThanOrEqual(to: firstUserWeightDate.add(2.weeks)) {
			
			//Set true on show alert
			shouldShowAlertToUser = true
			UserProfile.defaults.shouldShowCaloriesCheckAlert = true
			
			//Fill the arrays with weight data
			calculateWeights()
			
			//Update last check date
			lastCaloriesCheckDate = firstUserWeightDate.add(2.weeks)
			
			//Calculate calories consumed over the last week
			calculateConsumedCaloriesFormPastWeek()
			
			completion()
			
		} else if let lastCheck = lastCaloriesCheckDate?.onlyDate, today.isLaterThanOrEqual(to: lastCheck.add(1.weeks)) {
			
			//Set true on show alert
			shouldShowAlertToUser = true
			UserProfile.defaults.shouldShowCaloriesCheckAlert = true
			
			//Fill the arrays with weight data
			calculateWeights()
			
			//Update last check date
			lastCaloriesCheckDate = today
			
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
		let data = CaloriesProgressState(date: lastCaloriesCheckDate!, userCaloriesBetweenConsumedAndGiven: userCaloriesBetweenConsumedAndGiven, userWeekConsumedCalories: userConsumedCalories, userWeekExpectedCalories: userExpectedDailyCalories, firstWeekAverageWeight: firstWeekAverageWeight, secondWeekAverageWeight: secondWeekAverageWeight)
		
		GoogleApiManager.shared.updateCaloriesProgressState(data: data)
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
			guard let firstWeekDate = lastCaloriesCheckDate else { return }

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
		guard let lastCaloriesCheckDate = lastCaloriesCheckDate else { return }
		
		//If first check the take today and subtract a week else add take
		let firstDayForCalculatedWeek = lastCaloriesCheckDate.subtract(1.weeks).start(of: .day)
		
		let mealsConsumedInPeriod = userDailyMeals.filter {
			$0.meals.first!.date.onlyDate.isLater(than: firstDayForCalculatedWeek) &&
			$0.meals.first!.date.onlyDate.isEarlierThanOrEqual(to: firstDayForCalculatedWeek.add(1.weeks).start(of: .day))
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
		
		if (shouldShowNotEnoughDataAlert || differenceBetweenWeight.isNaN) {
			
			//present an alert that the user dose not have enough data to calculate calories
			notEnoughDataAlert()
		} else if shouldShowAlertToUser ?? false {
			//present an alert depending on the calories calculation
			if differenceBetweenWeightPercentage < expectedWeightRange.lowerBound {
				
				//Check average calories consumed from the last week
				if userConsumedCalories < userExpectedDailyCalories {
					//Send Message 1
					userLostWeightAlert(caloriesConsumed: .smallerThen)
				} else if userConsumedCalories > userExpectedDailyCalories {
					//Send Message 2
					userLostWeightAlert(caloriesConsumed: .biggerThen)
				} else {
					//Send Message 3
					userLostWeightAlert(caloriesConsumed: .inRange)
				}
			} else if differenceBetweenWeightPercentage > expectedWeightRange.upperBound {
				
				//Check average calories consumed from the last week
				if userConsumedCalories < userExpectedDailyCalories {
					//Send Message 1
					userGainedWeightAlert(caloriesConsumed: .smallerThen)
				} else if userConsumedCalories > userExpectedDailyCalories {
					//Send Message 2
					userGainedWeightAlert(caloriesConsumed: .biggerThen)
				} else {
					//Send Message 3
					userGainedWeightAlert(caloriesConsumed: .inRange)
				}
			} else if expectedWeightRange.contains(differenceBetweenWeightPercentage) {
				
				//Check average calories consumed from the last week
				if userConsumedCalories < userExpectedDailyCalories {
					//Send Message 1
					userInRangeAlert(caloriesConsumed: .smallerThen)
				} else if userConsumedCalories > userExpectedDailyCalories {
					//Send Message 2
					userInRangeAlert(caloriesConsumed: .biggerThen)
				} else {
					//Send Message 3
					userInRangeAlert(caloriesConsumed: .inRange)
				}
			}
		}
	}
	
	private func notEnoughDataAlert() {
		let weightAlert = UIAlertController(title: nil ,message: nil, preferredStyle: .alert)
		weightAlert.message =

"""

 איזה באסה 😑,
 לא הזנת 3 שקילות השבוע ולכן לא נוכל לבצע את הניתוח השבועי.
 מחכים לשקילות של השבוע הנוכחי! 💪🏼


"""
		
		weightAlert.addAction(UIAlertAction(title: "הבנתי, אל תציג לי שוב", style: .default) { _ in
			self.shouldShowAlertToUser = false
			self.updateUserCaloriesProgress()
			UserProfile.defaults.shouldShowCaloriesCheckAlert = self.shouldShowAlertToUser
		})
		weightAlert.addAction(UIAlertAction(title: "לא כרגע", style: .cancel) { _ in
			return
		})
		if let title = weightAlert.title, let text = weightAlert.message, lastCaloriesCheckDate != Date().onlyDate {
			self.sendMessageToManager(title: title, text: text)
		}
		weightAlert.showAlert()
	}
	private func userLostWeightAlert(caloriesConsumed: CaloriesAlertsState) {
		let weightAlert = UIAlertController(title: "לא ירדת לפי המתוכנן, לא קרה כלום- מתחילים שבוע חדש!", message: nil, preferredStyle: .alert)
		
		//Calorie State
		switch caloriesConsumed {
		case .smallerThen:
			
			weightAlert.message =
"""

שמנו לב שכמות הקק״ל שדיווחת בתפריט התזונה קטנה יותר מזו שניתנה לך.

אנא בדקי האם:

1. תת הערכה קלורית- יכול להיות שהערכה הקלורית של המזון אותו המרת נמוכה מהערך הקלורי האמיתי שלו.
לדוגמה: הערכת המזון עם הין, המרות לא מדויקות.

2. אי סימון ארוחות שנאכלו.

4. שכחת לדווח על ארוחות חריגות.

"""
		case .inRange:
			
			weightAlert.message =
"""
שמנו לב שכמות הקק״ל שדיווחת בתפריט התזונה זהה לזו שניתנה לך.

אנא בדקי האם:
1. תת הערכה קלורית- יכול להיות שהערכה הקלורית של המזון אותו המרת נמוכה מהערך הקלורי האמיתי שלו.
לדוגמה: הערכת המזון עם העין, המרות לא מדויקות) .

2. שכחת לדווח על ארוחות חריגות.

3. ההוצאה האנרגטית (הפעילות היומית) שלך קטנה.
משמע את זקוקה לכמות קלוריות

קטנה יותר ולכן לא ירדת כמצופה.

"""
		case .biggerThen:
			
			weightAlert.message =
"""

שמנו לב שכמות הקק״ל שדיווחת בתפריט התזונה גדולה יותר מזו שניתנה לך.

השבוע תנסי לשמור על כמות הקלוריות היומית כדי להגיע ליעדים שהצבנו.
זה קטן עליך!

"""
		default:
			break
		}
		
		weightAlert.addAction(UIAlertAction(title: "הבנתי, אל תציג לי שוב", style: .default) { _ in
			self.updateUserCaloriesProgress()
			self.shouldShowAlertToUser = false

			UserProfile.defaults.shouldShowCaloriesCheckAlert = self.shouldShowAlertToUser
		})
		weightAlert.addAction(UIAlertAction(title: "לא כרגע", style: .cancel) { _ in
			return
		})
		if let title = weightAlert.title, let text = weightAlert.message, lastCaloriesCheckDate != Date().onlyDate {
			self.sendMessageToManager(title: title, text: text)
		}
		weightAlert.showAlert()
	}
	private func userInRangeAlert(caloriesConsumed: CaloriesAlertsState) {
		
		let weightAlert = UIAlertController(title: "כל הכבוד עמדת ביעדים! עבודה יפה, המשיכי ככה!", message: nil, preferredStyle: .alert)
		let neutralMessage =
			"""

אנו רואים שגופך מגיב מעולה לכן לא נעשה שינוי בכמות הקלוריות.

"""
		//Calorie State
		switch caloriesConsumed {
		case .smallerThen:
			
			weightAlert.message =
				"""

אבל שמנו לב שכמות הקק״ל שדיווחת בתפריט התזונה קטנה יותר מזו שניתנה לך.

אנא בדקי האם:

1. שכחת לסמן ארוחות שנאכלו.

2. ההוצאה האנרגטית (הפעילות היומית) שלך ירדה.

"""
		case .inRange:
			
			weightAlert.message = neutralMessage
		case .biggerThen:
			
			weightAlert.message =
				"""

אבל שמנו לב שכמות הקק״ל שדיווחת בתפריט התזונה גדולה יותר מזו שניתנה לך.

אנא בדקי האם:

1. ההוצאה האנרגטית (הפעילות היומית) שלך עלתה.

2. יתר הערכה קלורית בהמרות- יתכן והערכת את המזון המומר בכמות קלוריות גדולה יותר מהערך האמיתי של המזון.

"""
		default:
			break
		}
		
		weightAlert.addAction(UIAlertAction(title: "הבנתי, אל תציג לי שוב", style: .default) { _ in
			self.updateUserCaloriesProgress()
			self.shouldShowAlertToUser = false
			UserProfile.defaults.shouldShowCaloriesCheckAlert = self.shouldShowAlertToUser
		})
		weightAlert.addAction(UIAlertAction(title: "לא כרגע", style: .cancel) { _ in
			return
		})
		if let title = weightAlert.title, let text = weightAlert.message, lastCaloriesCheckDate != Date().onlyDate {
			self.sendMessageToManager(title: title, text: text)
		}
		weightAlert.showAlert()
	}
	private func userGainedWeightAlert(caloriesConsumed: CaloriesAlertsState) {
		
		let weightAlert = UIAlertController(title: "כל הכבוד ירדת במשקל!", message: nil, preferredStyle: .alert)
		
		//Calorie State
		switch caloriesConsumed {
		case .smallerThen:
			
			weightAlert.message =
				"""

אבל ירדת מעל המצופה, משמע יש סיכון לפגיעה במסת שריר.
שמנו לב שלמרות זאת דיווחת בתפריט תזונה על כמות קקל נמוכה יותר מזו שניתנה לך.

אנא בדקי האם:

1. אי סימון ארוחות- במידה ואינך מפתחת תאבון נבצע שינוי קלורי בהתאם, במידה ולא ,תנסי לאכול את כמות הקק״ל ולא להמנע במידה ומתפתח רעב על מנת שלא תאבדי מסת שריר.


"""
		case .inRange:
			
			weightAlert.message =
				"""

אבל ירדת מעל המצופה, משמע יש סיכון לפגיעה במסת שריר.
שמנו לב שלמרות זאת דיווחת בתפריט תזונה על כמות קקל זהה לזו שניתנה לך.

אנא בדקי האם:

1. ההוצאה האנרגטית (הפעילות היומית) שלך עלתה.

2. יתר הערכה קלורית.

3. סימון ארוחות שלא נאכלו בטעות.


"""
		case .biggerThen:
			
			weightAlert.message =
				"""

אבל ירדת מעל המצופה, משמע יש סיכון לפגיעה במסת שריר.
שמנו לב שלמרות זאת דיווחת בתפריט תזונה על כמות קקל גדולה יותר מזו שניתנה לך.

אנא בדקי האם:

1. ההוצאה האנרגטית (הפעילות היומית) שלך עלתה משמעותית- ולכן נצטרך להרים את כמות הקק״ל כי הדרישה הקלורית שלך עלתה.

2. יתר הערכה קלורית בהמרות- יתכן והערכת את המזון המומר בכמות קלוריות גדולה יותר מהערך האמיתי של המזון.

3. הוספת ארוחה חריגה בטעות.

"""
		default:
			break
		}
		
		weightAlert.addAction(UIAlertAction(title: "הבנתי, אל תציג לי שוב", style: .default) { _ in
			self.updateUserCaloriesProgress()
			self.shouldShowAlertToUser = false
			UserProfile.defaults.shouldShowCaloriesCheckAlert = self.shouldShowAlertToUser
		})
		weightAlert.addAction(UIAlertAction(title: "לא כרגע", style: .cancel) { _ in
			return
		})
		if let title = weightAlert.title, let text = weightAlert.message, lastCaloriesCheckDate != Date().onlyDate {
			self.sendMessageToManager(title: title, text: text)
		}
		weightAlert.showAlert()
	}
}
