//
//  UINavigationController+Extensions.swift
//  FitApp
//
//  Created by Ofir Elias on 16/12/2021.
//

import UIKit

extension UINavigationController {
	
	
	func clear() {
		setNavigationBarHidden(true, animated: false)
		navigationBar.setBackgroundImage(UIImage(), for: .default)
		navigationBar.shadowImage = UIImage()
		navigationBar.isTranslucent = true
	}
}
