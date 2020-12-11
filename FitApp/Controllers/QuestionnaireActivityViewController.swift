//
//  QuestionnaireActivityViewController.swift
//  FitApp
//
//  Created by iOS Bthere on 10/12/2020.
//

import UIKit

class QuestionnaireActivityViewController: UIViewController {
    
    
    @IBOutlet weak var kilometresSlider: UISlider! {
        didSet {
            kilometresSlider.maximumValue = 100.00
        }
    }
    @IBOutlet weak var stepsSlider: UISlider! {
        didSet {
            stepsSlider.maximumValue = 10000.00
        }
    }
    @IBOutlet weak var kilometersLabel: UILabel!
    @IBOutlet weak var stepsLabel: UILabel!
    @IBOutlet weak var kilometersCheckBox: UIButton!
    @IBOutlet weak var stepsCheckBox: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func nextButtonAction(_ sender: Any) {
        if kilometersCheckBox.isSelected {
            if let kilometers = kilometersLabel.text?.split(separator: " ").first {
                UserProfile.shared.kilometer = Double(kilometers)
				UserProfile.shared.steps = nil
            }
        } else if stepsCheckBox.isSelected {
            if let steps = stepsLabel.text {
                UserProfile.shared.steps = Int(steps)
				UserProfile.shared.kilometer = nil
            }
        }
		performSegue(withIdentifier: K.SegueId.moveToNutrition, sender: self)
    }
    @IBAction func kilometersSliderAction(_ sender: UISlider) {
		kilometersLabel.text = String(format: "%.1f", sender.value) + " " + K.Units.kilometers
    }
    @IBAction func stepsSliderAction(_ sender: UISlider) {
        stepsLabel.text = String(format: "%.0f", sender.value)
    }
    @IBAction func checkBoxes(sender: UIButton) {
        sender.isSelected = !sender.isSelected
        
        switch sender.tag {
        case 1:
            if sender.isSelected {
                stepsCheckBox.isSelected = false
            }
        case 2:
            if sender.isSelected {
                kilometersCheckBox.isSelected = false
            }
        default:
            return
        }
        
        (kilometersCheckBox.isSelected || stepsCheckBox.isSelected)
            ? nextButton.setTitle("הבא", for: .normal)
            : nextButton.setTitle("דלג", for: .normal)
    }
}
