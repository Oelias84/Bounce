//
//  StartViewController.swift
//  FitApp
//
//  Created by Ofir Elias on 11/12/2020.
//

import UIKit
import FirebaseAuth

class StartViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

		if Auth.auth().currentUser != nil {
			let storyboard = UIStoryboard(name: K.StoryboardName.Home, bundle: nil)
			let homeVC = storyboard.instantiateViewController(identifier: K.StoryboardNameId.HomeTabBar)
			
			homeVC.modalPresentationStyle = .fullScreen
			self.present(homeVC, animated: true)
	   }
    }
}
