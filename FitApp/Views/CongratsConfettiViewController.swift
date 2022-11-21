//
//  CongratsConfettiViewController.swift
//  FitApp
//
//  Created by Ofir Elias on 18/10/2022.
//

import UIKit
import Lottie

class CongratsConfettiViewController: UIViewController {

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
		titleLabel.text = StaticStringsManager.shared.getGenderString?[0] ?? "איזה כיף, סיימתי אימון :)"
	}
	
	@IBAction func closeButtonAction(_ sender: Any) {
		dismiss(animated: true)
	}
}
