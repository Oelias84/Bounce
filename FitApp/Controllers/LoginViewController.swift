//
//  LoginViewController.swift
//  FitApp
//
//  Created by Ofir Elias on 24/11/2020.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {
	
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
        guard let email = emailTextfield.text, let password = passwordTextfield.text else { return }
		Spinner.shared.show(self.view)

		Auth.auth().signIn(withEmail: email, password: password) { [weak self] (user, error) in
			guard let self = self else { return }
			
			if error == nil {
				self.getUserImageProfileUrl(with: email)
                self.googleManager.getUserData { result in

                    switch result {
                    case .success(let userData):
						if let user = user?.user {
							UserProfile.defaults.updateUserProfileData(userData!, id: user.uid)
						}
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
	
	func getUserImageProfileUrl(with email: String) {
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
