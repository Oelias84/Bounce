//
//  Double+Extensions.swift
//  FitApp
//
//  Created by iOS Bthere on 02/01/2021.
//

import Foundation


extension Double {
    
    func round(nearest: Double) -> Double {
        let n = 1/nearest
        let numberToRound = self * n
        
        return numberToRound.rounded() / n
    }
    var roundHalfDown: Double {
        let fraction = self.fraction
        let whole = self.whole.nextDown.rounded()
		
		if fraction >= 0.75 {
			return whole + 1
		} else if fraction < 0.75 && fraction >= 0.25 {
			return whole + 0.5
		} else {
			return whole
		}
    }
	var mealRound: Double {
		let fraction = self.fraction
		let whole = self.whole.nextDown.rounded()
		
		if fraction >= 0.5 {
			return whole + 0.5
		} else {
			return whole
		}
	}
	func shortDecimal(maxDecimals max: Int? = 2) -> Double {
		let stringArr = String(self).split(separator: ".")
		let decimals = Array(stringArr[1])
		var string = "\(stringArr[0])."
		
		var count = 0;
		for n in decimals {
			if count == max { break }
			string += "\(n)"
			count += 1
		}
		
		
		let double = Double(string)!
		return double
	}
}
