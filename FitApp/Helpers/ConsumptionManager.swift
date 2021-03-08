//
//  ConsumptionManager.swift
//  FitApp
//
//  Created by iOS Bthere on 01/01/2021.
//

import Foundation

class ConsumptionManager {
	
	static let shared = ConsumptionManager()
    
    private var weight: Double
    private var fatPercentage: Double
    private var Kilometer: Double
    private var numberOfTrainings: Int
	private var lifeStyle: Double
    
    private var calories: Double!
    private var fatPortion: Double!
    private var proteinPortion: Double!
    private var carbsPortion: Double!
    
    private var fatProgress = 0.0
    private var proteinProgress = 0.0
    private var carbsProgress = 0.0
    
    init() {
        let userData = UserProfile.defaults
        
        self.weight = userData.weight ?? 0.0
        self.fatPercentage = userData.fatPercentage ?? 0.0
        self.Kilometer = userData.kilometer ?? 0.0
		self.lifeStyle = userData.lifeStyle ?? 0.0
        self.numberOfTrainings = userData.weaklyWorkouts ?? 0
        configureData()
		
//		let weight = 61.0

//		let calo = TDEE(weight: weight, fatPercentage: 25, Kilometer: 7, lifeStyle: nil, numberOfTrainings: 2)
//		print("TDEE:", calo)
//		print("ProteinGrams:", proteinGrams(weight: weight))
//		print("ProteinPortion:", proteinPortion(proteinGrams: proteinGrams(weight: weight)))
//		print("fatGrams:", fatGrams(weight: weight))
//		print("fatPortion:", portionFat(fatGrams: fatGrams(weight: weight)))
//		print("carbsPortion:", portionCarbs(fatPortion: portionFat(fatGrams: fatGrams(weight: weight)), proteinPortion: proteinPortion(proteinGrams: proteinGrams(weight: weight)), calories: calo))
    }
    
    var getDayProtein: Double {
        return proteinPortion
    }
    var getDayFat: Double {
        return fatPortion
    }
    var getDayCarbs: Double {
        return carbsPortion
    }
    
    var getDayProteinProgress: Double {
        return proteinProgress
    }
    var getDayFatProgress: Double {
        return fatProgress
    }
    var getDayCarbsProgress: Double {
        return carbsProgress
    }
    
    func calculateUserData(){
        let userData = UserProfile.defaults
        
        self.weight = userData.weight ?? 0.0
        self.fatPercentage = userData.fatPercentage ?? 0.0
        self.Kilometer = userData.kilometer ?? 0.0
        self.numberOfTrainings = userData.weaklyWorkouts ?? 0
        configureData()
    }
}

extension ConsumptionManager {
    
    //MARK: - lean body weight
	private func TDEE(weight: Double, fatPercentage: Double, Kilometer: Double?, lifeStyle: Double?, numberOfTrainings: Int) -> Double {
		
        let LBM = weight * ((100 - fatPercentage) / 100)
        let BMR = (LBM * 22.0) + 500.0
		var NIT: Double {
			if let Kilometer = Kilometer {
				return (Kilometer * weight) * 0.93
			} else {
				return BMR * lifeStyle!
			}
		}
		let EAT = (150.0 * Double(numberOfTrainings)) / 7.0
        let result = Kilometer != nil ? ((BMR * 1.1) + NIT + EAT) - 500 : (NIT + EAT) - 500
		
		if result < 1200 {
			return 1200
		} else {
			return result
		}
    }//= daily calories
    
    //MARK: - convert to grams
    private func proteinGrams(weight: Double) -> Double {
        return weight * 1.5
    }//= Daily protein grams
    
    private func proteinPortion(proteinGrams: Double) -> Double {
        let proteinPortion = proteinGrams / 20.0
        let truncatingRemainder = proteinPortion.fraction
        
		return roundOrHalf(friction: truncatingRemainder, portion: proteinPortion)
    }//= Daily Protein portion dish
    
    //MARK: - Fat calculation
    private func fatGrams(weight: Double) -> Double {
        return weight * 0.5
    }//= Daily Fat grams
    
    private func portionFat(fatGrams: Double) -> Double {
        let fatPortion = fatGrams / 11.0
        let truncatingRemainder = fatPortion.fraction
        
       return roundOrHalf(friction: truncatingRemainder, portion: fatPortion)
    }//= Daily Fat portion dish
    
    //MARK: - Carbs calculation
    private func portionCarbs(fatPortion: Double, proteinPortion: Double, calories: Double) -> Double {
        let caloriesCarbs = calories - ((fatPortion * 100) + (proteinPortion * 150))

		let portion = caloriesCarbs / 100.0
		let truncatingRemainder = portion.fraction
		return roundOrHalf(friction: truncatingRemainder, portion: portion)
    }
    
    private func configureData() {
		self.calories = TDEE(weight: weight, fatPercentage: fatPercentage, Kilometer: Kilometer, lifeStyle: lifeStyle, numberOfTrainings: numberOfTrainings)
        self.fatPortion = portionFat(fatGrams: fatGrams(weight: weight))
        self.proteinPortion = proteinPortion(proteinGrams: proteinGrams(weight: weight))
        self.carbsPortion = portionCarbs(fatPortion: self.fatPortion, proteinPortion: self.proteinPortion, calories: calories)
    }
	
	private func roundOrHalf(friction: Double, portion: Double) -> Double {
		if (friction > 0.25 && friction < 0.5) || (friction < 0.75 && friction > 0.5) {
			return portion.round(nearest: 0.5)
		} else if friction <= 0.25 {
			return portion.rounded(.towardZero)
		} else if  friction >= 0.75 {
			return portion.rounded(.awayFromZero)
		} else {
			return portion
		}
	}
}
