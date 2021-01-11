//
//  ConsumptionManager.swift
//  FitApp
//
//  Created by iOS Bthere on 01/01/2021.
//

import Foundation

class ConsumptionManager {
    
    private var weight: Double
    private var fatPercentage: Double
    private var Kilometer: Double
    private var numberOfTrainings: Int
    
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
        self.numberOfTrainings = userData.weaklyWorkouts ?? 0
        configureData()
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
}

extension ConsumptionManager {
    
    //lean body weight
    private func TDEE(weight: Double, fatPercentage: Double, Kilometer: Double, numberOfTrainings: Int) -> Double {
        let LBM = weight * ((100 - 32) / 100)
        let BMR = (LBM * 22.0) + 500.0
        let NIT = (Kilometer * weight) * 0.93
        let EAT = (150.0 * Double(numberOfTrainings)) / 7.0
        
        return ((BMR * 1.1) + NIT + EAT) - 500
    }//= daily calories
    //convert to grams
    private func proteinGrams(weight: Double) -> Double {
        return weight * 1.5
    }//= Daily protein grams
    private func proteinPortion(proteinGrams: Double) -> Double {
        let proteinPortion = proteinGrams / 20.0
        let truncatingRemainder = proteinPortion.fraction
        
        if (truncatingRemainder > 0.25 && truncatingRemainder < 0.5) || (truncatingRemainder < 0.75 && truncatingRemainder > 0.5) {
            return proteinPortion.round(nearest: 0.5)
        } else if truncatingRemainder < 0.25 {
            return proteinPortion.rounded(.towardZero)
        } else if  truncatingRemainder > 0.75 {
            return proteinPortion.rounded()
        } else {
            return proteinPortion
        }
    }//= Daily Protein portion dish
    //Fat calculation
    private func fatGrams(weight: Double) -> Double {
        return weight * 0.5
    }//= Daily Fat grams
    private func portionFat(fatGrams: Double) -> Double {
        let fatPortion = fatGrams / 11.0
        let truncatingRemainder = fatPortion.fraction
        
        if (truncatingRemainder > 0.25 && truncatingRemainder < 0.5) || (truncatingRemainder < 0.75 && truncatingRemainder > 0.5) {
            return fatPortion.round(nearest: 0.5)
        } else if truncatingRemainder < 0.25 {
            return fatPortion.rounded(.towardZero)
        } else if  truncatingRemainder > 0.75 {
            return fatPortion.rounded(.awayFromZero)
        } else {
            return fatPortion
        }
    }//= Daily Fat portion dish
    //Carbs calculation
    private func portionCarbs(fatPortion: Double, proteinPortion: Double, calories: Double) -> Double {
        let caloriesCarbs = (fatPortion * 100) + (proteinPortion * 150)
        
        return caloriesCarbs / 100.0
    }
    
    private func configureData(){
        self.calories = TDEE(weight: weight, fatPercentage: fatPercentage, Kilometer: Kilometer, numberOfTrainings: numberOfTrainings)
        self.fatPortion = portionFat(fatGrams: fatGrams(weight: weight))
        self.proteinPortion = proteinPortion(proteinGrams: proteinGrams(weight: weight))
        self.carbsPortion = portionCarbs(fatPortion: self.fatPortion, proteinPortion: self.proteinPortion, calories: calories)
    }
}
