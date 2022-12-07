//
//  CongratsConfettiViewController.swift
//  FitApp
//
//  Created by Ofir Elias on 18/10/2022.
//

import UIKit
import Lottie

enum WorkoutCongratsPopupType {
	case finishedAll
	case finishedOne
}

class CongratsConfettiViewController: UIViewController {
	
	var popupType: WorkoutCongratsPopupType!

	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var animation: LottieAnimationView!
	@IBOutlet weak var animationTop: LottieAnimationView!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		animationTop.contentMode = .scaleToFill
		animationTop.loopMode = .loop
		animationTop.play()
		animation.contentMode = .scaleToFill
		animation.loopMode = .loop
		animation.play()
		
		switch popupType {
		case .finishedAll:
			titleLabel.text = StaticStringsManager.shared.getGenderString?[45] ??  ""
		case .finishedOne:
			titleLabel.text = StaticStringsManager.shared.getGenderString?[44] ??  ""
		case .none:
			break
		}
	}
	
	@IBAction func closeButtonAction(_ sender: Any) {
		dismiss(animated: true)
	}
}
