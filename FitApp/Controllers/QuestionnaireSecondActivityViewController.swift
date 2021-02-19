//
//  QuestionnaireSecondActivityViewControllerViewController.swift
//  FitApp
//
//  Created by Ofir Elias on 18/02/2021.
//

import UIKit

class QuestionnaireSecondActivityViewController: UIViewController {
	
	@IBOutlet weak var sittingCheckBox: UIButton!
	@IBOutlet weak var semiActiveCheckBox: UIButton!
	@IBOutlet weak var activeCheckBox: UIButton!
	@IBOutlet weak var veryActiveCheckBox: UIButton!
	@IBOutlet weak var nextButton: UIButton!
	
	private var lifeStyleSelection: Int?

    override func viewDidLoad() {
        super.viewDidLoad()
		
    }
	
	@IBAction func nextButtonAction(_ sender: Any) {
		
		if let lifeStyle = lifeStyleSelection {
			
			
		}
	}
	
	@IBAction func checkBoxAction(_ sender: UIButton) {
		
		switch sender.tag {
		case 1:
			semiActiveCheckBox.isSelected = false
			activeCheckBox.isSelected = false
			veryActiveCheckBox.isSelected = false
		case 2:
			sittingCheckBox.isSelected = false
			activeCheckBox.isSelected = false
			veryActiveCheckBox.isSelected = false
		case 3:
			sittingCheckBox.isSelected = false
			semiActiveCheckBox.isSelected = false
			veryActiveCheckBox.isSelected = false
		case 4:
			sittingCheckBox.isSelected = false
			semiActiveCheckBox.isSelected = false
			activeCheckBox.isSelected = false
		default:
			break
		}
	}
}

extension QuestionnaireSecondActivityViewController {
	
	private func setUpTextfields() {
		if let lifeStyle = lifeStyleSelection {
			UserProfile.defaults.lifeStyle = getBMR(for: lifeStyle)
			performSegue(withIdentifier: K.SegueId.moveToNutrition, sender: self)
		}
	}
	
	private func getBMR(for lifestyle: Int) -> Double {
		switch lifestyle {
		case 1:
			return 1.2
		case 2:
			return 1.3
		case 3:
			return 1.5
		case 4:
			return 1.6
		default:
			return 0.0
		}
	}
}
