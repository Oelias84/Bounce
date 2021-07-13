//
//  LoginViewController.swift
//  FitApp
//
//  Created by Ofir Elias on 24/11/2020.
//

import UIKit

class LoginViewController: UIViewController {
	
	@IBOutlet weak var emailTextfield: UITextField!
	@IBOutlet weak var passwordTextfield: UITextField!
	
	private let viewModel = LoginViewModel()
	
	deinit {
		removeKeyboardListener()
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		raiseScreenWhenKeyboardAppears()
		addScreenTappGesture()
	}
	
	@IBAction func signInButtonAction(_ sender: Any) {
		view.endEditing(true)
		
		do {
			Spinner.shared.show(view)
			try viewModel.login(email: emailTextfield.text, password: passwordTextfield.text) {
				[weak self] login, error in
				guard let self = self else { return }
				Spinner.shared.stop()

				if login {
					let storyboard = UIStoryboard(name: K.StoryboardName.home, bundle: nil)
					let homeVC = storyboard.instantiateViewController(identifier: K.ViewControllerId.HomeTabBar)
					
					homeVC.modalPresentationStyle = .fullScreen
					self.present(homeVC, animated: true)
				} else {
					self.presentAlert(withTitle: "Error", withMessage: error!, options: "אישור") { _ in }
				}
			}
		} catch ErrorManager.LoginError.emptyEmail {
			presentOkAlert(withTitle: "אופס", withMessage: "נראה ששכחת למלא את כתובת האמייל") {
				self.emailTextfield.becomeFirstResponder()
			}
		} catch ErrorManager.LoginError.emptyPassword {
			presentOkAlert(withTitle: "אופס", withMessage: "נראה ששכחת להזין סיסמא") {
				self.passwordTextfield.becomeFirstResponder()
			}
		} catch ErrorManager.LoginError.invalidEmail {
			presentOkAlert(withTitle: "אופס", withMessage: "נראה שכתובת האמייל שגויה") {
				self.emailTextfield.becomeFirstResponder()
			}
		} catch ErrorManager.LoginError.incorrectPasswordLength {
			presentOkAlert(withTitle: "אופס", withMessage: "אורך הסיסמא חייב להיות בעל 6 תווים") {
				self.passwordTextfield.becomeFirstResponder()
			}
		} catch {
			print("Something went wrong!")
		}
	}
}
