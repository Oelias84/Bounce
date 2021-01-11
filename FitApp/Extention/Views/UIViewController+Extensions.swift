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
    func addScreenTappGesture() {
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissView)))
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
    @objc func dismissView() {
        view.endEditing(true)
    }
    
    //MARK: - Alerts
    func presentOkAlert(withTitle title: String? = nil, withMessage message: String, buttonText: String = "אישור", completion: @escaping () -> Void) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: buttonText, style: .default){ action in
            completion()
        })
        present(alertController, animated: true)
    }
    func presentAlert(withTitle title: String? = nil, withMessage message: String, options: (String)..., completion: @escaping (Int) -> Void) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        for (index, option) in options.enumerated() {
            alertController.addAction(UIAlertAction.init(title: option, style: option == "ביטול" ? .destructive : .default, handler: { _ in
                completion(index)
            }))
        }
        self.present(alertController, animated: true, completion: nil)
    }
    func presentActionSheet(withTitle title: String? = nil, withMessage message: String?, options: (String)..., completion: @escaping (Int) -> Void){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        for (index, option) in options.enumerated() {
            alertController.addAction(UIAlertAction.init(title: option, style: option == "ביטול" ? .destructive : .default, handler: { _ in
                completion(index)
            }))
        }
        if let popoverController = alertController.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        self.present(alertController, animated: true, completion: nil)
    }
}
