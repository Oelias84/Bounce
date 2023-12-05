//
//  UIAlertController+Extensions.swift
//  FitApp
//
//  Created by Ofir Elias on 11/09/2021.
//

import UIKit
import Foundation

extension UIAlertController {
	
	func showAlert() {
		let keyWindow = UIApplication.shared.connectedScenes
											.filter({$0.activationState == .foregroundActive})
											.compactMap({$0 as? UIWindowScene})
											.first?.windows
											.filter({$0.isKeyWindow}).first
		
		DispatchQueue.main.async {
            keyWindow?.rootViewController?.present(self, animated: true)
		}
	}
}
