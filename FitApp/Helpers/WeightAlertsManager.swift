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
}

class WeightAlertsManager {
	
	static let shared = WeightAlertsManager()
	
	private var userWeights: [Weight]!
	private var userDailyMeals: [DailyMeal]!
	
	private var userConsumedCalories: Double!
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
	
	private init() {
		
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
		lastCaloriesCheckDate = UserProfile.defaults.lastCaloriesCheckDate
		userExpectedDailyCalories = ConsumptionManager.shared.getCalories()
		shouldShowAlertToUser = UserProfile.defaults.shouldShowCaloriesCheckAlert ?? true

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
		
		//Check if has lastChecked date not empty
		if let lastCheck = lastCaloriesCheckDate?.onlyDate, lastCheck.add(1.weeks).isLaterThanOrEqual(to: today), shouldShowAlertToUser {
			
			//Calculate calories consumed over the last week
			calculateConsumedCaloriesFormPastWeek()
			
			//Fill the arrays with weight data
			firstWeekWeightsArray = userWeights.filter { $0.date.onlyDate.isLaterThanOrEqual(to: lastCheck.subtract(1.weeks)) &&
				$0.date.onlyDate.isEarlierThanOrEqual(to: lastCheck) }
			secondWeekWeightsArray = userWeights.filter { $0.date.onlyDate.isLaterThanOrEqual(to: lastCheck) &&
				$0.date.onlyDate.isEarlierThanOrEqual(to: lastCheck.add(1.weeks)) }
			
			//Update last check date
			lastCaloriesCheckDate = today
			
			completion()
			
		//Else if 2 week has passed from first user Weight
		} else if today.isLater(than: firstUserWeightDate.add(2.weeks)) || shouldShowAlertToUser {
			
			//Update last check date
			lastCaloriesCheckDate = firstUserWeightDate.add(2.weeks)
			
			//Calculate calories consumed over the last week
			calculateConsumedCaloriesFormPastWeek()
			
			//Fill the arrays with weight data
			firstWeekWeightsArray = userWeights.filter { $0.date.onlyDate.isLaterThanOrEqual(to: firstUserWeightDate) &&
				$0.date.onlyDate.isEarlierThanOrEqual(to: firstUserWeightDate.add(1.weeks)) }
			secondWeekWeightsArray = userWeights.filter { $0.date.onlyDate.isLaterThanOrEqual(to: firstUserWeightDate.add(1.weeks)) &&
				$0.date.onlyDate.isEarlierThanOrEqual(to: firstUserWeightDate.add(2.weeks)) }
			
			completion()
		}
	}
	
	//MARK: - Fetch Data From Server
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
	
	//MARK: - Calculation
	private func calculateConsumedCaloriesFormPastWeek() {
		guard let lastCaloriesCheckDate = lastCaloriesCheckDate else { return }
		
		//If first check the take today and subtract a week else add take
		let firstDayForCalculatedWeek = (lastCaloriesCheckDate == todayDate) ? lastCaloriesCheckDate.subtract(1.weeks).start(of: .day) : lastCaloriesCheckDate.start(of: .day)
		
		let mealsConsumedInPeriod = userDailyMeals.filter {
			$0.meals.first!.date.onlyDate.isLaterThanOrEqual(to: firstDayForCalculatedWeek) &&
			$0.meals.first!.date.onlyDate.isEarlierThanOrEqual(to: firstDayForCalculatedWeek.add(1.weeks))
		}
		
		if let consumedCalories = DailyMealManager.calculateMealAverageCalories(meals: mealsConsumedInPeriod) {
			userConsumedCalories = consumedCalories
		} else {
			shouldShowNotEnoughDataAlert = true
		}
	}
	private func calculatePercentage(value: Double , percentageVal: Double) -> Double {
		let val = value * percentageVal
		return val / 100.0
	}
	
	//MARK: - Notification
	private func sendNotificationToManager(with text: String) {
		//		let notification = PushNotificationSender()
		//
		//		if let tokens = self.otherTokens {
		//			tokens.forEach {
		//				notification.sendPushNotification(to: $0, title: "הודעה נשלחה מ-" + (self.title ?? "User"), body: text)
		//			}
		//		}
	}
	
	//MARK: - Alerts
	private func presentAlertForUserState() {
		guard shouldShowAlertToUser != false else { return }
		
		//Weight Calculation
		let expectedWeightRange = 0...1.5
		let differenceBetweenWeight = firstWeekAverageWeight - secondWeekAverageWeight
		let differenceBetweenWeightPercentage = calculatePercentage(value: firstWeekAverageWeight, percentageVal: differenceBetweenWeight)
		
		
		if (shouldShowNotEnoughDataAlert || differenceBetweenWeight.isNaN) && shouldShowAlertToUser {
			
			//present an alert that the user dose not have enough data to calculate calories
			notEnoughDataAlert()
		} else if shouldShowAlertToUser {
			//present an alert depending on the calories calculation
			if differenceBetweenWeightPercentage < expectedWeightRange.lowerBound {
				
				//Check average calories consumed from the last week
				if userConsumedCalories < userExpectedDailyCalories {
					//Send Message 1
					smallerWeightThenExpectedAlert(state: .smallerThen)
				} else if userConsumedCalories > userExpectedDailyCalories {
					//Send Message 2
					smallerWeightThenExpectedAlert(state: .biggerThen)
				} else {
					//Send Message 3
					smallerWeightThenExpectedAlert(state: .inRange)
				}
			} else if differenceBetweenWeightPercentage > expectedWeightRange.upperBound {
				
				//Check average calories consumed from the last week
				if userConsumedCalories < userExpectedDailyCalories {
					//Send Message 1
					biggerWeightThenExpectedAlert(state: .smallerThen)
				} else if userConsumedCalories > userExpectedDailyCalories {
					//Send Message 2
					biggerWeightThenExpectedAlert(state: .biggerThen)
				} else {
					//Send Message 3
					biggerWeightThenExpectedAlert(state: .inRange)
				}
			} else if expectedWeightRange.contains(differenceBetweenWeightPercentage) {
				
				//Check average calories consumed from the last week
				if userConsumedCalories < userExpectedDailyCalories {
					//Send Message 1
					weightInExpectedRangeAlert(state: .smallerThen)
				} else if userConsumedCalories > userExpectedDailyCalories {
					//Send Message 2
					weightInExpectedRangeAlert(state: .biggerThen)
				} else {
					//Send Message 3
					weightInExpectedRangeAlert(state: .inRange)
				}
			}
		}
	}

	private func notEnoughDataAlert() {
		let weightAlert = UIAlertController(title:  "חישוב צריכה תקותי לא זמין", message: "נראה שלא הזנת מספיק נתונים בכדי נוכל לבצע את הבידה הקלורית התקופתית", preferredStyle: .alert)
		
		
		weightAlert.addAction(UIAlertAction(title: "הבנתי, אל תציג לי שוב", style: .default) { _ in
			self.shouldShowAlertToUser = false
			UserProfile.defaults.shouldShowCaloriesCheckAlert = self.shouldShowAlertToUser
		})
		weightAlert.addAction(UIAlertAction(title: "לא כרגע", style: .cancel) { _ in
			return
		})
		weightAlert.show()
	}
	private func smallerWeightThenExpectedAlert(state: CaloriesAlertsState) {
		let weightAlert = UIAlertController(title:  "לא ירדת לפי המתוכנן, לא קרה כלום- מתחילים שבוע חדש!", message: nil, preferredStyle: .alert)
		
		//Calorie State
		switch state {
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
		}
		
		weightAlert.addAction(UIAlertAction(title: "הבנתי, אל תציג לי שוב", style: .default) { _ in
			self.shouldShowAlertToUser = false
			UserProfile.defaults.shouldShowCaloriesCheckAlert = self.shouldShowAlertToUser
		})
		weightAlert.addAction(UIAlertAction(title: "לא כרגע", style: .cancel) { _ in
			return
		})
		weightAlert.show()
	}
	private func weightInExpectedRangeAlert(state: CaloriesAlertsState) {
		
		let weightAlert = UIAlertController(title: "כל הכבוד עמדת ביעדים! עבודה יפה, המשיכי ככה!", message: nil, preferredStyle: .alert)
		
		//Calorie State
		switch state {
		case .smallerThen:
			
			weightAlert.message =
				"""

אבל שמנו לב שכמות הקק״ל שדיווחת בתפריט התזונה קטנה יותר מזו שניתנה לך.

אנא בדקי האם:

1. שכחת לסמן ארוחות שנאכלו.

2. ההוצאה האנרגטית (הפעילות היומית) שלך ירדה.

"""
		case .inRange:
			
			weightAlert.message =
				"""

אנו רואים שגופך מגיב מעולה לכן לא נעשה שינוי בכמות הקלוריות.

"""
		case .biggerThen:
			
			weightAlert.message =
				"""

אבל שמנו לב שכמות הקק״ל שדיווחת בתפריט התזונה גדולה יותר מזו שניתנה לך.

אנא בדקי האם:

1. ההוצאה האנרגטית (הפעילות היומית) שלך עלתה.

2. יתר הערכה קלורית בהמרות- יתכן והערכת את המזון המומר בכמות קלוריות גדולה יותר מהערך האמיתי של המזון.

"""
		}
		
		weightAlert.addAction(UIAlertAction(title: "הבנתי, אל תציג לי שוב", style: .default) { _ in
			self.shouldShowAlertToUser = false
			UserProfile.defaults.shouldShowCaloriesCheckAlert = self.shouldShowAlertToUser
		})
		weightAlert.addAction(UIAlertAction(title: "לא כרגע", style: .cancel) { _ in
			return
		})
		weightAlert.show()
	}
	private func biggerWeightThenExpectedAlert(state: CaloriesAlertsState) {
		
		let weightAlert = UIAlertController(title: "כל הכבוד ירדת במשקל!", message: nil, preferredStyle: .alert)
		
		//Calorie State
		switch state {
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
		}
		
		weightAlert.addAction(UIAlertAction(title: "הבנתי, אל תציג לי שוב", style: .default) { _ in
			self.shouldShowAlertToUser = false
			UserProfile.defaults.shouldShowCaloriesCheckAlert = self.shouldShowAlertToUser
		})
		weightAlert.addAction(UIAlertAction(title: "לא כרגע", style: .cancel) { _ in
			return
		})
		weightAlert.show()
	}
}
