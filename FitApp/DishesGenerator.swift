//
//  DishesGenerator.swift
//  FitApp
//
//  Created by iOS Bthere on 15/01/2021.
//

import Foundation

struct DishesGenerator {
    
    
    static let carbsDishes = [
        
        //Breakfest
        ["גבינה לבנה 5% (3/4 גביע)",
         "גבינת קוטג 3% (3/4 גביע)",
         "גבינה צהובה 9% (3 פרוסות)",
         "מעדן חלבון (1 גביע)",
         "ביצים  (2 מדיום)"],
        
        //Lunch
        ["טונה במים (1 קופסה)",
         "פסטרמה 3 אחוז (6 יחידות)", "חזה עוף (100 גרם)",
         "בשר בקר רזה שייטל\\כתף\\סינטה (100 גרם)",
         "דג אמנון\\נילוס\\בקלה (100 גרם)",
         "דג סלמון (100 גרם)",
       "טופו (150 גרם)", "דג סול\\ בורי\\ לברק (100 גרם)"],
        
        //Supper
        ["גבינת קוטג 5% (3/4 גביע)",
        "לאבנה 5% (150 גרם)",
        "גבינה צהובה 15% (3 פרוסות)",],
        
        //Middle
        ["חטיף חלבון (1 יחידה עד 200 קל ו20 גרם חלבון)",
        "אבקת חלבון (1 סקופ)",
        "מעדן חלבון לייט (1 גביע)",]
    ]
    
    static let proteinDishes = [
        
        //Breakfest
        ["לחם קל (2 פרוסות)",
        "ברנפקלס (30 גרם)",
        "קוואקר לפני בישול (30 גרם)",
        "פריכיות (עד 100 קל)",
        "פרי  (1 יחידה גודל אגרוף)"],
        
        //Lunch
        ["אורז לבן (75 גרם)",
        "בטטה (130 גרם)",
        "פיתה קלה (1 יחידה)",
        "בורגול (120 גרם)",
        "תפוח אדמה (120 גרם)",],
        
        //Supper
        ["לחם קל (2 פרוסות)",
        "לחם לבן (1 פרוסה)",
        "פריכיות (עד 100 קל)",
        "תפוח אדמה (120 גרם)",],
        
        //Middle
        ["פייבר וואן (50 גרם)",
        "דגני פיטנס שקדים\\דבש (30 גרם)",
        "פרי  (1 יחידה גודל אגרוף)",
        "תותים (15 יחידות)",]
    ]
    
    static let fatDishes = [
        
        //Breakfest
        ["שקדים (15 יחידות)",
        "אבוקדו (60 גרם . 1/3 יחידה)",
        "אגוזי מלך (6 חצאי יחידות)",],
        
        //Lunch
        ["מיונז (1 כף שטוחה)",
        "טחינה מוכנה (2 כפות שטוחות)",
        "שמן זית (1 כף שטוחה)",],
        
        //Supper
        ["זיתים (15 יחידות)",
        "טחינה גולמית (1 כף שטוחה)",
        "חמאה (14 גרם, 1 כף שטוחה)",],
        
        //Middle
        ["שקדים (15 יחידות)",
        "שוקולד מריר 70% (עד 100 קל)",
        "חמאת בוטנים (1 כף שטוחה)",]
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
