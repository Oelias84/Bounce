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
			self.presentOkAlert(withTitle:"!אימייל ריק", withMessage: "בכדי לאפס סיסמא יש להזין את כתובת האימייל הרצויה" ) { }
			return
		}
		resetPassword(email: email) {
			self.view.endEditing(true)
			self.navigationController?.popViewController(animated: true)
		}
	}
	
	func resetPassword(email: String, complition: @escaping () -> Void) {
		Auth.auth().sendPasswordReset(withEmail: email) { error in
			if let error = error {
				print(error.localizedDescription)
			} else {
				self.presentOkAlert(withTitle: "איפוס סיסמא", withMessage: "נשלח אליך מייל לאיפוס הסיסמא") {
					complition()
				}
			}
		}
		
	}
}
