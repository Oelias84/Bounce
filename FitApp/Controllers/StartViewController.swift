//
//  StartViewController.swift
//  FitApp
//
//  Created by Ofir Elias on 11/12/2020.
//

import UIKit
import FirebaseAuth

class StartViewController: UIViewController {

	@IBOutlet weak var buttonsStackView: UIStackView!
	
	override func viewDidLoad() {
        super.viewDidLoad()
    }
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		if Auth.auth().currentUser != nil {
			buttonsStackView.isHidden = true
		} else {
			buttonsStackView.isHidden = false
		}
	}
}
