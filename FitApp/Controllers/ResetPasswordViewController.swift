//
//  ResetPasswordViewController.swift
//  FitApp
//
//  Created by Ofir Elias on 02/02/2021.
//

import UIKit
import FirebaseAuth

class ResetPasswordViewController: UIViewController {
	
	
	@IBOutlet weak var emailTextField: UITextField!
	@IBOutlet weak var resetPasswordButton: UIButton!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		addScreenTappGesture()
		raiseScreenWhenKeyboardAppears()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		removeKeyboardListener()
	}
	
	@IBAction func resetButtonAction(_ sender: Any) {
		guard let email = emailTextField.text, email != "" else {
			presentOkAlert(withTitle:"!אימייל ריק", withMessage: "בכדי לאפס סיסמא יש להזין את כתובת האימייל הרצויה")
			return
		}
		resetPasswordButton.isUserInteractionEnabled = true
		
		if !email.isValidEmail {
			presentOkAlert(withTitle: "אופס!", withMessage: "נראה שכתובת האמייל שגויה")
		} else {
			resetPassword(email: email)
		}
	}
	
	func resetPassword(email: String) {
		DispatchQueue.global(qos: .userInteractive).async {
			Auth.auth().sendPasswordReset(withEmail: email) {
				[weak self] error in
				guard let self = self else { return }
				
				self.resetPasswordButton.isUserInteractionEnabled = false
				DispatchQueue.main.async {
					if let error = error {
						self.presentOkAlert(withTitle: "אופס!", withMessage: error.localizedDescription)
						print(error.localizedDescription)
					} else {
						self.presentOkAlertWithDelegate(withTitle: "איפוס סיסמא", withMessage: "נשלח אליך מייל לאיפוס הסיסמא")
					}
				}
			}
		}
	}
	func presentOkAlertWithDelegate(withTitle title: String? = nil, withMessage message: String, buttonText: String = "אישור") {
		
		let storyboard = UIStoryboard(name: "PopupAlertView", bundle: nil)
		let customAlert = storyboard.instantiateViewController(identifier: "PopupAlertView") as! PopupAlertView
		
		customAlert.providesPresentationContextTransitionStyle = true
		customAlert.definesPresentationContext = true
		customAlert.modalPresentationStyle = .overCurrentContext
		customAlert.modalTransitionStyle = .crossDissolve
		
		customAlert.delegate = self
		customAlert.titleText = title
		customAlert.messageText = message
		customAlert.cancelButtonIsHidden = true

		present(customAlert, animated: true)
	}
}
extension ResetPasswordViewController: PopupAlertViewDelegate {
	
	func okButtonTapped(alertNumber: Int, selectedOption: String?, textFieldValue: String?) {
		if alertNumber == 99 {
			self.view.endEditing(true)
			self.navigationController?.popViewController(animated: true)
		}
	}
	func cancelButtonTapped(alertNumber: Int) {
		return
	}
	func thirdButtonTapped(alertNumber: Int) {
		return
	}
}
