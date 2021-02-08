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
		
		Spinner.shared.show(self.view)
		if Auth.auth().currentUser != nil {
			Spinner.shared.stop()
            let storyboard = UIStoryboard(name: K.StoryboardName.home, bundle: nil)
			let homeVC = storyboard.instantiateViewController(identifier: K.ViewControllerId.HomeTabBar)

			homeVC.modalPresentationStyle = .fullScreen
			self.present(homeVC, animated: true)
	   }
    }
}
