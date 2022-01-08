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
}
