//
//  ConsumptionManager.swift
//  FitApp
//
//  Created by iOS Bthere on 01/01/2021.
//

import Foundation

class ConsumptionManager {
	
	static let shared = ConsumptionManager()
	
	private var weight: Double?
	private var fatPercentage: Double?
	private var Kilometer: Double?
	private var numberOfTrainings: Int?
	private var lifeStyle: Double?
	
	private var dailyCalories: Double?
	private var dailyFatPortion: Double?
	private var dailyProteinPortion: Double?
	private var dailyCarbsPortion: Double?
	
	private var fatProgress = 0.0
	private var proteinProgress = 0.0
	private var carbsProgress = 0.0
	
	//MARK: - Getters
	func getCalories() -> String {
		return String(format: "%.0f", dailyCalories ?? 0)
	}
	
	func getDailyProtein() -> Double {
		return dailyProteinPortion ?? 0
	}
	func getDailyFat() -> Double {
		return dailyFatPortion ?? 0
	}
	func getDailyCarbs() -> Double {
		return dailyCarbsPortion ?? 0
	}
	
	func getDayProteinProgress() -> Double {
		return proteinProgress
	}
	func getDayFatProgress() -> Double {
		return fatProgress
	}
	func getDayCarbsProgress() -> Double {
		return carbsProgress
	}
	
	func calculateUserData() {
		let userData = UserProfile.defaults
		
		self.weight = userData.weight
		self.fatPercentage = userData.fatPercentage
		self.Kilometer = userData.kilometer
		self.lifeStyle = userData.lifeStyle
		self.numberOfTrainings = userData.weaklyWorkouts
		
		configureData()
	}
	func resetConsumptionManager() {
		
		weight = nil
		fatPercentage = nil
		Kilometer = nil
		numberOfTrainings = nil
		lifeStyle = nil
		dailyCalories = nil
		dailyFatPortion = nil
		dailyProteinPortion = nil
		dailyCarbsPortion = nil
		fatProgress = 0
		proteinProgress = 0
		carbsProgress = 0
	}
}

extension ConsumptionManager {
	
	//MARK: - lean body weight
	//= daily calories
	private func TDEE(weight: Double, fatPercentage: Double, Kilometer: Double?, lifeStyle: Double?, numberOfTrainings: Int) -> Double {
		
		let LBM = weight * ((100 - fatPercentage) / 100)
		let BMR = (LBM * 22.0) + 500.0
		let EAT = (150.0 * Double(numberOfTrainings)) / 7.0
		
		var NIT: Double {
			if let lifeStyle = lifeStyle {
				return BMR * lifeStyle
			}
			return (Kilometer! * weight) * 0.93
		}
		var result: Double {
			if lifeStyle != nil {
				return (NIT + EAT) - 500
			}
			return ((BMR * 1.1) + NIT + EAT) - 500
		}
		
		if result < 1200 {
			return 1200
		} else {
			return result
		}
	}
	
	//MARK: - convert to grams
	//Calculate Daily protein grams
	func proteinGrams(weight: Double, fatPercentage: Double) -> Double {
		let LBM = weight * ((100 - fatPercentage) / 100)
		
		return LBM * 2.1
	}
	//Calculate Daily Protein portion dish
	func proteinPortion(proteinGrams: Double) -> Double {
		let proteinPortion = proteinGrams / 20.0
		let truncatingRemainder = proteinPortion.fraction
		
		return roundOrHalf(friction: truncatingRemainder, portion: proteinPortion)
	}
	
	//MARK: - Fat calculation
	//Calculate Daily Fat grams
	private func fatGrams(weight: Double) -> Double {
		return weight * 0.5
	}
	//Calculate Daily Fat portion dish
	private func portionFat(tdee: Double) -> Double {
		let fatCalories = tdee * 0.15
		let portionFat = fatCalories / 100
		let truncatingRemainder = portionFat.fraction
		
		return roundOrHalf(friction: truncatingRemainder, portion: portionFat)
	}
	
	//MARK: - Carbs calculation
	private func portionCarbs(fatPortion: Double, proteinPortion: Double, calories: Double) -> Double {
		let caloriesCarbs = calories - ((fatPortion * 100) + (proteinPortion * 150))
		let portion = caloriesCarbs / 100.0
		let truncatingRemainder = portion.fraction
		
		return roundOrHalf(friction: truncatingRemainder, portion: portion)
	}
	
	private func configureData() {
		guard let weight = weight, let fatPercentage = fatPercentage, let numberOfTrainings = numberOfTrainings else { return }
		
		self.dailyCalories = TDEE(weight: weight, fatPercentage: fatPercentage, Kilometer: Kilometer, lifeStyle: lifeStyle, numberOfTrainings: numberOfTrainings)
		self.dailyFatPortion = portionFat(tdee: dailyCalories!)
		self.dailyProteinPortion = proteinPortion(proteinGrams: proteinGrams(weight: weight, fatPercentage: fatPercentage))
		self.dailyCarbsPortion = portionCarbs(fatPortion: self.dailyFatPortion!, proteinPortion: self.dailyProteinPortion!, calories: dailyCalories!)
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
