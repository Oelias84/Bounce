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
}
