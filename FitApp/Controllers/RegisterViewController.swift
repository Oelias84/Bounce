//
//  RegisterViewController.swift
//  FitApp
//
//  Created by Ofir Elias on 24/11/2020.
//

import UIKit

class RegisterViewController: UIViewController {

	
	@IBOutlet weak var emailTextfield: UITextField!
	@IBOutlet weak var passwordTextfield: UITextField!
	@IBOutlet weak var confirmPasswordTextfield: UITextField!
	
//	var handle: AuthStateDidChangeListenerHandle?
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
//		Auth.auth().addStateDidChangeListener { (auth, user) in
//			print(auth.apnsToken, user?.displayName)
//		}
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		raiseScreenWhenKeyboardAppears()
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		
//		if let handle = handle {
////			Auth.auth().removeStateDidChangeListener(handle)
//		}
		removeKeyboardListener()
	}
	
	@IBAction func singUpButtonAction(_ sender: Any) {
		
		if let email = emailTextfield.text, !email.isEmpty,
		   let password = passwordTextfield.text, !password.isEmpty,
		   let confirmPassword = confirmPasswordTextfield.text, !confirmPassword.isEmpty {
			
			if !email.isValidEmail {
				print("email is invalid")
			} else if password.count < 6 {
				print("password most have at least 6 characters")
			} else if password != confirmPassword {
				print("confirmed password no equal to password")
			} else {
//				FirebaseAuth.Auth.auth().createUser(withEmail: email, password: password) { result, error in
//
//					if error != nil {
//						print(error.debugDescription)
//						return
//					}
//					if let result = result {
//						UserProfile.shared.id = result.user.uid
//					}
//				}
			}
		}else {
			//alert empty fields
		}
	}

}
