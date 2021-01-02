//
//  FloatingPoint+Extensions.swift
//  FitApp
//
//  Created by iOS Bthere on 01/01/2021.
//

import Foundation

extension FloatingPoint {
    
    var whole: Self { modf(self).0 }
    var fraction: Self { modf(self).1 }
    var isWholeNumber: Bool {
        let dbl = self
        return dbl.rounded() == dbl
    }
}
