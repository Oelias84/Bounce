//
//  SettingsViewController.swift
//  FitApp
//
//  Created by Ofir Elias on 11/12/2020.
//

import UIKit
import FirebaseAuth

class SettingsViewController: UIViewController {
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
	}
	
	@IBAction func logOutAction(_ sender: Any) {
		do {
			try Auth.auth().signOut()
		}
		catch let signOutError as NSError {
			print ("Error signing out: %@", signOutError)
		}
		navigationController?.popToRootViewController(animated: true)
	}
}
