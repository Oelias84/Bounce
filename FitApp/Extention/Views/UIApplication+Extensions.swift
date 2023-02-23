//
//  UIApplication+Extensions.swift
//  FitApp
//
//  Created by Ofir Elias on 20/02/2023.
//

import SwiftUI

extension UIApplication {
	func endEditing() {
		sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
	}
}
