//
//  LoginViewController.swift
//  FitApp
//
//  Created by Ofir Elias on 24/11/2020.
//

import UIKit
import FirebaseAuth
import FirebaseAnalytics

import FirebaseDatabase

class LoginViewController: UIViewController {
	
	enum LoginError: Error {
		
		case emptyEmail
		case emptyPassword
		case invalidEmail
		case incorrectPasswordLength
	}
	
	@IBOutlet weak var emailTextfield: UITextField!
	@IBOutlet weak var passwordTextfield: UITextField!
	
	private let googleManager = GoogleApiManager()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		raiseScreenWhenKeyboardAppears()
		addScreenTappGesture()
	}
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		
		removeKeyboardListener()
	}
	
	@IBAction func signInButtonAction(_ sender: Any) {
		view.endEditing(true)
		
		do {
			try login()
		} catch LoginError.emptyEmail {
			presentOkAlert(withTitle: "אופס", withMessage: "נראה ששכחת למלא את כתובת האמייל") {
				self.emailTextfield.becomeFirstResponder()
			}
		} catch LoginError.emptyPassword {
			presentOkAlert(withTitle: "אופס", withMessage: "נראה ששכחת להזין סיסמא") {
				self.passwordTextfield.becomeFirstResponder()
			}
		} catch LoginError.invalidEmail {
			presentOkAlert(withTitle: "אופס", withMessage: "נראה שכתובת האמייל שגויה") {
				self.emailTextfield.becomeFirstResponder()
			}
		} catch LoginError.incorrectPasswordLength {
			presentOkAlert(withTitle: "אופס", withMessage: "אורך הסיסמא חייב להיות בעל 6 תווים") {
				self.passwordTextfield.becomeFirstResponder()
			}
		} catch {
			print("Something went wrong!")
		}
	}
}

extension LoginViewController {
	
	private func login() throws {
		
		guard let email = emailTextfield.text else {
			throw LoginError.emptyEmail
		}
		
		guard let password = passwordTextfield.text else {
			throw LoginError.emptyPassword
		}
		
		if !email.isValidEmail {
			throw LoginError.invalidEmail
		}
		
		if password.count != 6 {
			throw LoginError.incorrectPasswordLength
		}
		
		Spinner.shared.show(self.view)
		
		Auth.auth().signIn(withEmail: email, password: password) {
			[weak self] (user, error) in
			guard let self = self else { return }
			
			if error == nil {
				self.getUserImageProfileUrl(with: email)
				self.googleManager.getUserData { result in
					
					switch result {
					case .success(let userData):
						UserProfile.defaults.email = email
						if let user = user?.user, let data = userData {
							UserProfile.defaults.updateUserProfileData(data, id: user.uid)
							if let token =  UserProfile.defaults.fcmToken {
								let userName = data.name.splitFullName
								GoogleDatabaseManager.shared.add(token: token, for: User(firsName: userName.0, lastName: userName.1, email: data.email, deviceToken: token))
							}
						}
						
						Analytics.logEvent(AnalyticsEventLogin, parameters: ["USER_EMAIL": email])
						let storyboard = UIStoryboard(name: K.StoryboardName.home, bundle: nil)
						let homeVC = storyboard.instantiateViewController(identifier: K.ViewControllerId.HomeTabBar)
						
						homeVC.modalPresentationStyle = .fullScreen
						self.present(homeVC, animated: true)
					case .failure(let error):
						print("Error fetching user data: ", error)
					}
				}
			} else {
				Spinner.shared.stop()
				
				let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
				let defaultAction = UIAlertAction(title: "אישור", style: .cancel, handler: nil)
				
				alertController.addAction(defaultAction)
				self.present(alertController, animated: true, completion: nil)
			}
		}
	}
	private func getUserImageProfileUrl(with email: String) {
		let path = "\(email.safeEmail)_profile_picture.jpeg"
		GoogleStorageManager.shared.downloadImageURL(from: .profileImage , path: path){ result in
			
			switch result {
			case .success(let url):
				DispatchQueue.main.async {
					UserProfile.defaults.profileImageImageUrl = url.absoluteString
				}
			case .failure(let error):
				print("no image exist", error)
			}
		}
	}
}
