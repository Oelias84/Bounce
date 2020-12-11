//
//  RegisterViewController.swift
//  FitApp
//
//  Created by Ofir Elias on 24/11/2020.
//

import UIKit
import FirebaseAuth

class RegisterViewController: UIViewController {
	
	
	@IBOutlet weak var emailTextfield: UITextField!
	@IBOutlet weak var passwordTextfield: UITextField!
	@IBOutlet weak var confirmPasswordTextfield: UITextField!
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		raiseScreenWhenKeyboardAppears()
		addScreenTappGesture()
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		
		removeKeyboardListener()
	}
	
	@IBAction func singUpButtonAction(_ sender: Any) {
		
		if passwordTextfield.text != confirmPasswordTextfield.text {
			let alertController = UIAlertController(title: "Password Incorrect", message: "Please re-type password", preferredStyle: .alert)
			let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
			
			alertController.addAction(defaultAction)
			self.present(alertController, animated: true, completion: nil)
		}
		else{
			Auth.auth().createUser(withEmail: emailTextfield.text!, password: passwordTextfield.text!){ (user, error) in
				if error == nil {
					let storyboard = UIStoryboard(name: K.StoryboardName.Home, bundle: nil)
					let homeVC = storyboard.instantiateViewController(identifier: K.StoryboardNameId.HomeTabBar)
					
					homeVC.modalPresentationStyle = .fullScreen
					self.present(homeVC, animated: true)
				} else {
					let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
					let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
					
					alertController.addAction(defaultAction)
					self.present(alertController, animated: true, completion: nil)
				}
			}
		}
	}
}
