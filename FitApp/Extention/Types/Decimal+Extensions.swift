//
//  Decimal+Extensions.swift
//  FitApp
//
//  Created by Ofir Elias on 27/08/2022.
//

import Foundation

extension Decimal {
	
	func shortFraction(maxDecimals max: Int? = 1) -> String {
		if self.isWholeNumber || self.isNaN {
			return String(format: "%.1f", (self as NSDecimalNumber).doubleValue)
		}
		
		let stringArr = self.description.split(separator: ".")
		let decimals = Array(stringArr[1])
		var string = "\(stringArr[0])."
		
		var count = 0;
		for n in decimals {
			if count == max { break }
			string += "\(n)"
			count += 1
		}
		return string
	}
	var isWholeNumber: Bool {
		return self.isZero || (self.isNormal && self.exponent >= 0)
	}
}
