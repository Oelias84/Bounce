//
//  UIViewController+Extensions.swift
//  MyFItApp
//
//  Created by Ofir Elias on 13/11/2020.
//

import UIKit

extension UIViewController {
	
	//MARK: - Keyboard Listener
	func raiseScreenWhenKeyboardAppears() {
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
	}
	func removeKeyboardListener() {
		NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: self)
		NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: self)
	}
	@objc func keyboardWillShow(notification: NSNotification) {
		if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
			if self.view.frame.origin.y == 0 {
				self.view.frame.origin.y -= keyboardSize.height
			}
		}
	}
	@objc func keyboardWillHide(notification: NSNotification) {
		if self.view.frame.origin.y != 0 {
			self.view.frame.origin.y = 0
		}
	}
}
