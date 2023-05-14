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
	@IBOutlet weak var forgotPasswordButton: UIButton!
	@IBOutlet weak var showPasswordButton: UIButton! {
		didSet {
			showPasswordButton.addTarget(self, action: #selector(thumbsUpButtonPressed(_:)), for: .touchDown)
			showPasswordButton.addTarget(self, action: #selector(thumbsUpButtonCancelled(_:)), for: .touchUpInside)
		}
	}
	@IBOutlet weak var noAccountButton: UIButton!
	
	deinit {
		removeKeyboardListener()
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
        
		raiseScreenWhenKeyboardAppears()
		addScreenTappGesture()
		passwordTextfield.isSecureTextEntry = true
		passwordTextfield.keyboardType = .alphabet
	}

	@objc func thumbsUpButtonPressed(_ sender: Any) {
		passwordTextfield.isSecureTextEntry = false
	}
	@objc func thumbsUpButtonCancelled(_ sender: Any) {
		passwordTextfield.isSecureTextEntry = true
	}
	@IBAction func signInButtonAction(_ sender: Any) {
		view.endEditing(true)
		Spinner.shared.show(self)

		do {
			try viewModel.login(email: emailTextfield.text, password: passwordTextfield.text) {
				[weak self] login, error in
				guard let self = self else { return }
				Spinner.shared.stop()

				if let error = error {
					var title = "לא מצליח להתחבר"
					var message = ""
					if error.contains("There is no user record corresponding to this identifier") {
						title = "הי! לצערנו נראה שאין לך מנוי bounce 😞"
						message = "האפליקציה מהווה חלק מסדנת \" מוציאים אתכם מהלופ!\" לפרטים נוספים והרשמה ניתן להכנס לאתר שלנו"
						self.presentAlert(withTitle: title, withMessage: message, options: "לאתר", "ביטול", alertNumber: 1)
						return
					} else if error.contains("The password is invalid") {
						message = "הסיסמא שהכנסת שגויה"
					} else if error.contains("Access to this account has been temporarily disabled due to many failed login attempts") {
						message = "החשבון נחסם זמנית, בעכבות יותר מידיי ניסיונות כושלים. את יכולה לאפס סיסמא או שנית במועד מאוחר יותר"
					} else {
						title = "הי! לצערנו נראה שאין לך מנוי bounce 😞"
						message = "האפליקציה מהווה חלק מסדנת \"מוציאים אתכם מהלופ!\" לפרטים נוספים והרשמה ניתן להכנס לאתר שלנו"
						self.presentAlert(withTitle: title, withMessage: message, options: "לאתר", "ביטול", alertNumber: 1)
						return
					}
					
					self.presentAlert(withTitle: title, withMessage: message, options: "אישור", alertNumber: 2)
				} else {
					if !(UserProfile.defaults.finishOnboarding ?? false) {
						self.startQuestionnaire()
					} else  {
						self.moveToHomeViewController()
					}
				}
			}
		} catch ErrorManager.LoginError.emptyEmail {
			presentAlert(withTitle: "אופס", withMessage: "נראה ששכחת להזין כתובת האימייל", options: "אישור", alertNumber: 3)
		} catch ErrorManager.LoginError.emptyPassword {
			presentAlert(withTitle: "אופס", withMessage: "נראה ששכחת להזין סיסמא", options: "אישור", alertNumber: 4)
		} catch ErrorManager.LoginError.invalidEmail {
			presentAlert(withTitle: "אופס", withMessage: "נראה שכתובת האימייל שגויה", options: "אישור", alertNumber: 5)
		} catch {
			print("Something went wrong!")
		}
	}
	@IBAction func noAccountButtonAction(_ sender: Any) {
		presentAlert(withTitle: "שימו לב!", withMessage: "הרכישה דרך החנות כוללת את האפליקציה בלבד. על מנת לרכוש את הסדנה אנא עברו לאתר המקושר.", options: "המשך ברכישה", "מעבר לאתר", "ביטול", alertNumber: 6)
	}
}

//MARK: - Delegates
extension LoginViewController: PopupAlertViewDelegate {
	
	func okButtonTapped(alertNumber: Int, selectedOption: String?, textFieldValue: String?) {
		view.endEditing(true)
		
		switch alertNumber {
		case 1:
			if let url = URL(string: "https://www.bouncefit.co.il") {
				UIApplication.shared.open(url)
			}
		case 2:
			break
		case 3:
			self.emailTextfield.becomeFirstResponder()
		case 4:
			self.passwordTextfield.becomeFirstResponder()
		case 5:
			self.emailTextfield.becomeFirstResponder()
		case 6:
			self.moveToRegisterViewController()
		default:
			break
		}
	}
	func cancelButtonTapped(alertNumber: Int) {
		if alertNumber == 6 {
			if let url = URL(string: "https://www.bouncefit.co.il") {
				UIApplication.shared.open(url)
			}
		} else {
			return
		}
	}
	func thirdButtonTapped(alertNumber: Int) {
		if alertNumber == 6 {
			return
		} else {
			return
		}
	}
}

//MARK: - Function
extension LoginViewController {
	
	private func startQuestionnaire() {
		let storyboard = UIStoryboard(name: K.StoryboardName.questionnaire, bundle: nil)
		let questionnaireVC = storyboard.instantiateViewController(identifier: K.ViewControllerId.questionnaireNavigation)
		
		questionnaireVC.modalPresentationStyle = .fullScreen
		DispatchQueue.main.async {
			self.present(questionnaireVC, animated: true)
		}
	}
	private func moveToHomeViewController() {
		let storyboard = UIStoryboard(name: K.StoryboardName.home, bundle: nil)
		let homeVC = storyboard.instantiateViewController(identifier: K.ViewControllerId.HomeTabBar)
		
		homeVC.modalPresentationStyle = .fullScreen
		DispatchQueue.main.async {
			self.present(homeVC, animated: true)
		}
	}
	private func moveToRegisterViewController() {
		guard let registerVC = storyboard?.instantiateViewController(identifier: K.ViewControllerId.registerViewController) else { return }
		
		DispatchQueue.main.async {
			self.navigationController?.pushViewController(registerVC, animated: true)
		}
	}
	private func presentAlert(withTitle title: String? = nil, withMessage message: String, options: (String)..., alertNumber: Int) {
		Spinner.shared.stop()
		
		guard let window = (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.window else {
			return
		}
		let storyboard = UIStoryboard(name: "PopupAlertView", bundle: nil)
		let customAlert = storyboard.instantiateViewController(identifier: "PopupAlertView") as! PopupAlertView
		
		customAlert.providesPresentationContextTransitionStyle = true
		customAlert.definesPresentationContext = true
		customAlert.modalPresentationStyle = .overCurrentContext
		customAlert.modalTransitionStyle = .crossDissolve
		
		customAlert.delegate = self
		customAlert.titleText = title
		customAlert.messageText = message
		customAlert.alertNumber = alertNumber
		customAlert.okButtonText = options[0]
		
		switch options.count {
		case 1:
			customAlert.cancelButtonIsHidden = true
		case 2:
			customAlert.cancelButtonText = options[1]
		case 3:
			customAlert.cancelButtonText = options[1]
			customAlert.doNotShowText = options.last
		default:
			break
		}
		DispatchQueue.main.async {
			window.rootViewController?.present(customAlert, animated: true, completion: nil)
		}
	}
}
