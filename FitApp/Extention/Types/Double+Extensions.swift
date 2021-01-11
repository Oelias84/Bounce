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
        let friction = self.fraction
        let whole = self.whole.nextDown.rounded()
        
        if friction > 0.0 && friction < 0.5 {
            return whole
        } else if friction > 0.5 && friction < whole+1 {
            return whole + 0.5
        } else {
            return self
        }
    }
}
