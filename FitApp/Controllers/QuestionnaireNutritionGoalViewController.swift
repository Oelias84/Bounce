//
//  QuestionnaireNutritionPlanViewController.swift
//  FitApp
//
//  Created by Ofir Elias on 27/03/2023.
//

import UIKit

class QuestionnaireNutritionGoalViewController: UIViewController {
    
    @IBOutlet weak var naturalMenuTitle: UILabel!
    @IBOutlet weak var naturalMenuText: UILabel!
    @IBOutlet weak var neutralMenuCheckMark: UIButton!
    
    @IBOutlet weak var negativeMenuTitle: UILabel!
    @IBOutlet weak var negativeMenuText: UILabel!
    @IBOutlet weak var negativeMenuCheckMark: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        setupCheckMarks()
    }
    
    @IBAction func neutralMenuCheckMarkAction(_ sender: UIButton) {
        sender.isSelected = true
        negativeMenuCheckMark.isSelected = false
        UserProfile.defaults.naturalMenu = true
    }
    @IBAction func negativeMenuCheckMarkAction(_ sender: UIButton) {
        sender.isSelected = true
        neutralMenuCheckMark.isSelected = false
        UserProfile.defaults.naturalMenu = false
    }
    @IBAction func backButtonAction(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    @IBAction func nextButtonAction(_ sender: Any) {
        performSegue(withIdentifier: K.SegueId.moveToFitnessLevel, sender: self)
    }
    private func setupView() {
        naturalMenuTitle.text = StaticStringsManager.shared.getGenderString?[46]
        naturalMenuText.text = StaticStringsManager.shared.getGenderString?[47]
        negativeMenuTitle.text = StaticStringsManager.shared.getGenderString?[48]
        negativeMenuText.text = StaticStringsManager.shared.getGenderString?[49]
    }
    private func setupCheckMarks() {
        let userData = UserProfile.defaults
        
        if userData.naturalMenu == true {
            neutralMenuCheckMark.isSelected = true
            negativeMenuCheckMark.isSelected = false
        } else {
            neutralMenuCheckMark.isSelected = false
            negativeMenuCheckMark.isSelected = true
        }
    }
}
