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
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		raiseScreenWhenKeyboardAppears()
	}
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		
		removeKeyboardListener()
	}
	
	@IBAction func signInButtonAction(_ sender: Any) {
		let storyboard = UIStoryboard(name: "Questionnaire", bundle: nil)
		let questionnaireVC = storyboard.instantiateViewController(identifier: "q_welcome")
		navigationController?.pushViewController(questionnaireVC, animated: true)
	}
}
