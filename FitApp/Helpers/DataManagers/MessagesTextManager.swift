//
//  MessagesTextManager.swift
//  FitApp
//
//  Created by Ofir Elias on 06/12/2021.
//

import UIKit
import Foundation

class MessagesTextManager {
	
	enum CalorieState {
		
		case smallerThenAverage
		case average
		case higherThenAverage
	}
	
	enum WeightState {
		
		case gainWeight
		case asExpected
		case lowerThenExpected
	}
	
	private var title: String?
	private var text: String?
	
	private let newCalories: Double?
	private let weightState: WeightState?
	private let calorieState: CalorieState?
	
	//At the start of every massage
	private let defaultTitle = "קצב הירידה הרצוי הוא \nבין 0.5% ל 1% בשבוע."
	
	//At the end of every massage
	private var newCalorieText: String {
		guard let newCalories = newCalories else { return "" }
		return "בהתאם לניתוח הנתונים כמות הקלוריות היומית הנוכחית שלך היא \(newCalories)"
	}
	
	init (weightState: WeightState? = nil, calorieState: CalorieState? = nil, newCalories: Double? = 0) {
		self.newCalories = newCalories
		self.weightState = weightState
		self.calorieState = calorieState
		self.setupText()
	}
}

extension MessagesTextManager {
	
	private func setupText() {
		
		let userGender = UserProfile.defaults.getGender
		
		switch weightState {
		case .gainWeight:
			switch calorieState {
			case .smallerThenAverage:
				self.title =
"""
לא ירדת לפי המתוכנן,
אבל לא קרה כלום- מתחילים שבוע חדש!
"""
				text =
"""
שמנו לב שכמות הקלוריות שדיווחת בתפריט התזונה קטנה יותר מזו שניתנה לך.

יש לבדוק האם:
1. תת הערכה קלורית- האם יכול להיות שהערכה הקלורית של המזון אותו המרת, נמוכה מהערך הקלורי האמיתי שלו?
לדוגמה: הערכת המזון עם העין, המרות לא מדויקות) .

2. האם אכלת ארוחות מהתפריט ולא סימנת?

3. האם אכלת ארוחות חריגות (מעבר לכמות הקלוריות היומית) ולא סימנת בארוחה חריגה?
"""
			case .average:
				self.title =
"""
לא ירדת לפי המתוכנן,
אבל לא קרה כלום- מתחילים שבוע חדש!
"""
				
				switch userGender {
				case .male:
					self.text =
"""
שמנו לב שכמות הקלוריות שדיווחת בתפריט התזונה זהה לזו שניתנה לך.

יש לבדוק האם:
1. תת הערכה קלורית- האם יכול להיות שהערכה הקלורית של המזון אותו המרת, נמוכה מהערך הקלורי האמיתי שלו?
לדוגמה: הערכת המזון עם העין, המרות לא מדויקות).

2. האם אכלת ארוחות חריגות (מעבר לכמות הקלוריות היומית) ולא סימנת בארוחה חריגה?

3. האם ההוצאה האנרגטית (הפעילות היומית) שלך קטנה?
(משמע אתv זקוק לכמות קלוריות קטנה יותר ולכן לא ירדת כמצופה)
"""
				default:
					self.text =
"""
שמנו לב שכמות הקלוריות שדיווחת בתפריט התזונה זהה לזו שניתנה לך.

יש לבדוק האם:
1. תת הערכה קלורית- האם יכול להיות שהערכה הקלורית של המזון אותו המרת, נמוכה מהערך הקלורי האמיתי שלו?
לדוגמה: הערכת המזון עם העין, המרות לא מדויקות) .

2. האם אכלת ארוחות חריגות (מעבר לכמות הקלוריות היומית) ולא סימנת בארוחה חריגה?

3. האם ההוצאה האנרגטית (הפעילות היומית) שלך קטנה?
(משמע את זקוקה לכמות קלוריות קטנה יותר ולכן לא ירדת כמצופה)
"""
				}

			case .higherThenAverage:
				self.title =
"""
לא ירדת לפי המתוכנן,
אבל לא קרה כלום- מתחילים שבוע חדש!
"""
				self.text =
"""
שמנו לב שכמות הקלוריות שדיווחת בתפריט התזונה גדולה יותר מזו שניתנה לך

אנו ממליצים לצרוך את כמות הקלוריות היומית כדי להגיע ליעדים שהצבנו - קטן עליך!
"""
			case .none:
				break
			}
		case .asExpected:
			switch calorieState {
			case .smallerThenAverage:
				self.title =
"""
כל הכבוד! עמדת ביעדים,
עבודה יפה, המשיכי ככה!
"""
				self.text =
"""
אך שמנו לב שכמות הקלוריות שדיווחת בתפריט התזונה קטנה יותר מזו שניתנה לך.

יש לבדוק האם:
1. האם יכול להיות שאכלת ארוחות מהתפריט ולא סימנת?

2. האם ההוצאה האנרגטית (הפעילות היומית) שלך ירדה?
(הוצאת פחות אנרגיה ולכן צרכת פחות מזון)
"""
			case .average:
				self.title =
"""
כל הכבוד עמדת ביעדים.
"""
				self.text = ""
			case .higherThenAverage:
				self.title =
"""
כל הכבוד! עמדת ביעדים.
עבודה יפה, המשיכי ככה!
"""
				self.text =
"""
אך שמנו לב שכמות הקלוריות שדיווחת בתפריט התזונה גדולה יותר מזו שניתנה לך.

יש לבדוק האם:
1. האם ההוצאה האנרגטית (הפעילות היומית) שלך עלתה?
(הוצאת יותר אנרגיה ולכן צרכת יותר מזון)

2. יתר הערכה קלורית בהמרות- האם יתכן והערכת את המזון המומר בכמות קלוריות גדולה יותר מהערך האמיתי של המזון?
לדוגמה: הערכת המזון עם העין, המרות לא מדויקות)

3. הוספת ארוחה חריגה (מעבר לכמות הקלוריות היומית) בטעות.
"""
			case .none:
				break
			}
		case .lowerThenExpected:
			switch calorieState {
			case .smallerThenAverage:
				self.title =
"""
כל הכבוד! עמדת ביעדים.
אך ירדת מעל המצופה, כלומר- יש סיכון לפגיעה במסת שריר.
"""
				self.text =
"""
שמנו לב שדיווחת בתפריט התזונה על כמות קלוריות נמוכה יותר מזו שניתנה לך.

חשוב לאכול את כמות הקלוריות שניתנה לך, ולא להמנע מארוחות במידה ומתפתח רעב, על מנת שלא להחסיר ערכים תזונתיים חיונים ולא לאבד מסת שריר.
"""
			case .average:
				self.title =
"""
כל הכבוד! עמדת ביעדים.
אך ירדת מעל המצופה, כלומר- יש סיכון לפגיעה במסת שריר.
"""
				self.text =
"""
שמנו לב שלמרות זאת דיווחת בתפריט התזונה על כמות קלוריות זהה לזו שניתנה לך.

יש לבדוק האם:

1. האם ההוצאה האנרגטית (הפעילות היומית) שלך עלתה?
(הוצאת יותר אנרגיה, צרכת כמות קלוריות זהה לתפריט, ולכן ירדת מעבר למצופה)

2. יתר הערכה קלורית בהמרות- האם יכול להיות שהערכה הקלורית של המזון אותו המרת, גבוהה מהערך הקלורי האמיתי שלו?
לדוגמה: הערכת המזון עם העין, המרות לא מדויקות)

3. האם סימנת בטעות ארוחות שלא אכלת?
"""
			case .higherThenAverage:
				self.title =
"""
כל הכבוד! עמדת ביעדים.
אך ירדת מעל המצופה, משמע יש סיכון לפגיעה במסת שריר.
"""
				
				switch userGender {
				case .male:
					self.text =
	"""
	שמנו לב שלמרות זאת דיווחת בתפריט התזונה על כמות קלוריות גדולה לזו שניתנה לך.

	יש לבדוק האם:

	1. האם ההוצאה האנרגטית (הפעילות היומית) שלך עלתה משמעותית?
	(הוצאת יותר אנרגיה, צרכת כמות קלוריות גבוהה מהתפריט, ועדין ירדת מעבר למצופה)
	תצur איתנו קשר בצ‘אט במידה וזה נכון.

	2. יתר הערכה קלורית בהמרות- האם יכול להיות שהערכה הקלורית של המזון אותו המרת, גבוהה מהערך הקלורי האמיתי שלו?
	לדוגמה: הערכת המזון עם העין, המרות לא מדויקות)

	3. האם סימנת בטעות ארוחות שלא אכלת?
	"""				default:
					
					self.text =
	"""
	שמנו לב שלמרות זאת דיווחת בתפריט התזונה על כמות קלוריות גדולה לזו שניתנה לך.

	יש לבדוק האם:

	1. האם ההוצאה האנרגטית (הפעילות היומית) שלך עלתה משמעותית?
	(הוצאת יותר אנרגיה, צרכת כמות קלוריות גבוהה מהתפריט, ועדין ירדת מעבר למצופה)
	תצרי איתנו קשר בצ‘אט במידה וזה נכון.

	2. יתר הערכה קלורית בהמרות- האם יכול להיות שהערכה הקלורית של המזון אותו המרת, גבוהה מהערך הקלורי האמיתי שלו?
	לדוגמה: הערכת המזון עם העין, המרות לא מדויקות)

	3. האם סימנת בטעות ארוחות שלא אכלת?
	"""
				}
			case .none:
				break
			}
		case .none:
			break
		}
	}
	func composeMessage() -> (String, String) {
		(
   """
   \(defaultTitle)
   \(title!)\n
   """,
   """
   \(text!)\n
   \(newCalorieText)
   """
		)
	}
	func notEnoughDataAlert() -> String {
		let message =
"""
איזה באסה 😑,
לא הזנת 3 שקילות השבוע ולכן לא נוכל לבצע את הניתוח השבועי.
מחכים לשקילות של השבוע הנוכחי! 💪🏼
"""
		return message
	}
}
