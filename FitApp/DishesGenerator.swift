//
//  DishesGenerator.swift
//  FitApp
//
//  Created by iOS Bthere on 15/01/2021.
//

import Foundation

struct DishesGenerator {
    
    
    static let proteinDishes = [
        
        //Breakfest
        ["גבינה לבנה 5% 3/4 גביע",
         "גבינת קוטג 3% 3/4 גביע",
		 "גבינה צהובה 9-15% 3 יחידות",
         "מעדן חלבון גביע",
		 "ביצים M 2 יחידות"],
        
        //Lunch
        ["טונה במים קופסה",
		 "פסטרמה 3% 6 יחידות",
		 "בשר בקר כתף 100 גרם",
		 "דג נילוס 100 גרם",
         "דג סלמון (100 גרם)",
		 "טופו 150 גרם",
],
        
        //Supper
        ["גבינת קוטג 5% 3/4 גביע",
		 "לאבנה 5% 150 גרם",
		 "גבינה צהובה 9-15% 3 יחידות",],
        
        //Middle
        ["חטיף חלבון יחידה",
		 "אבקת חלבון סקופ",
		 "מעדן חלבון לייט גביע",]
    ]
    
    static let carbsDishes = [
        
        //Breakfest
        ["לחם קל 2 יחידות",
		 "ברנפלקס 40 גרם",
		 "קוואקר 30 גרם",
		 "פריכיות עד 100 קל",
		 "פרי בגודל אגרוף 1 יחידות"],
        
        //Lunch
        ["אורז לבן 75 גרם",
		 "בטטה 130 גרם",
		 "פיתה קלה 1 יחידות",
		 "בורגול 125 גרם",
		 "תפוח אדמה 140 גרם",],
        
        //Supper
        ["לחם קל 2 יחידות",
		 "לחם לבן\\מלא 1 יחידות",
		 "פריכיות עד 100 קל",
		 "תפוח אדמה 140 גרם",],
        
        //Middle
        ["פייבר וואן 45 גרם",
        "דגני פיטנס שקדים\\דבש 30 גרם",
		"פרי בגודל אגרוף 1 יחידות",
        "תותים 15 יחידות",]
    ]
    
    static let fatDishes = [
        
        //Breakfest
        ["שקדים 15 יחידות",
		 "1/3 אבוקדו",
		 "אגוזי מלך 6 חצאים",],
        
        //Lunch
        ["מיונז כף",
		 "טחינה מוכנה 2 כפות",
		 "שמן זית\\קוקוס\\רגיל כף",],
        
        //Supper
        ["זיתים 15 זיתים קטנים",
		 "טחינה גולמית כף",
		 "מיונז כף שטוחה",],
        
        //Middle
        ["שקדים 15 יחידות",
		 "שוקולד מריר 70% 5 קוביות",
		 "חמאת בוטנים כף שטוחה",]
    ]
    
    static func randomDishFor(mealType: MealType, _ dishType: DishType) -> String {
        var type: Int {
            switch mealType {
            case .breakfast: return 0
            case .lunch : return 1
            case .supper: return 2
            default: return 3
            }
        }
        
        switch dishType {
        case .carbs:
            return carbsDishes[type].randomElement()!
        case .protein:
            return proteinDishes[type].randomElement()!
        case .fat:
            return fatDishes[type].randomElement()!
        }
    }
}
