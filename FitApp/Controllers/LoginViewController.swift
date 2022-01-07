//
//  LoginViewController.swift
//  FitApp
//
//  Created by Ofir Elias on 24/11/2020.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {

	private let viewModel = LoginViewModel()

	@IBOutlet weak var emailTextfield: UITextField!
	@IBOutlet weak var passwordTextfield: UITextField!
	@IBOutlet weak var buttonsStackView: UIStackView!
	@IBOutlet weak var noAccountButton: UIButton!
	
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

				if let error = error {
					var message = ""
					if error.contains("There is no user record corresponding to this identifier") {
						message = "נראה שהיוזר לא נמצא"
					} else if error.contains("The password is invalid") {
						message = "הסיסמא שהכנסת שגויה"
					} else if error.contains("Access to this account has been temporarily disabled due to many failed login attempts") {
						message = "החשבון נחסם זמנית, בעכבות יותר מידיי ניסיונות כושלים. את יכולה לאפס סיסמא או שנית במועד מאוחר יותר"
					} else {
						message = error
					}
					
					self.presentAlert(withTitle: "לא מצליח להתחבר", withMessage: message, options: "אישור") { _ in }
				} else {
					if !(UserProfile.defaults.finishOnboarding ?? false) {
						self.startQuestionnaire()
					} else  {
						self.moveToHomeViewController()
					}
				}
			}
		} catch ErrorManager.LoginError.emptyEmail {
			presentOkAlert(withTitle: "אופס", withMessage: "נראה ששכחת להזין כתובת האמייל") {
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
		} catch ErrorManager.LoginError.incorrectPassword {
			presentOkAlert(withTitle: "אופס", withMessage: "אורך הסיסמא חייב להיות בעל 6 תווים") {
				self.passwordTextfield.becomeFirstResponder()
			}
		} catch {
			print("Something went wrong!")
		}
	}
	
	private func startQuestionnaire() {
		let storyboard = UIStoryboard(name: K.StoryboardName.questionnaire, bundle: nil)
		let questionnaireVC = storyboard.instantiateViewController(identifier: K.ViewControllerId.questionnaireNavigation)
		
		questionnaireVC.modalPresentationStyle = .fullScreen
		present(questionnaireVC, animated: true)
	}
	private func moveToHomeViewController() {
		let storyboard = UIStoryboard(name: K.StoryboardName.home, bundle: nil)
		let homeVC = storyboard.instantiateViewController(identifier: K.ViewControllerId.HomeTabBar)
		
		homeVC.modalPresentationStyle = .fullScreen
		present(homeVC, animated: true)
	}
}
