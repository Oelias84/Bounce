//
//  QuestionnaireNutritionViewController.swift
//  FitApp
//
//  Created by iOS Bthere on 10/12/2020.
//

import UIKit

class QuestionnaireNutritionViewController: UIViewController {
    
    var numberOfMeals = 0
    var mostHunger = 0
    var leastHunger = 0
    
    @IBOutlet weak var mealCheckFirst: UIButton!
    @IBOutlet weak var mealCheckSecond: UIButton!
    @IBOutlet weak var mealCheckThird: UIButton!
    @IBOutlet weak var mealCheckForth: UIButton!
    
    @IBOutlet weak var mostHungerCheckFirst: UIButton!
    @IBOutlet weak var mostHungerCheckSecond: UIButton!
    @IBOutlet weak var mostHungerCheckThird: UIButton!
    @IBOutlet weak var mostHungerCheckForth: UIButton!
    
    @IBOutlet weak var leastHungerCheckFirst: UIButton!
    @IBOutlet weak var leastHungerCheckSecond: UIButton!
    @IBOutlet weak var leastHungerCheckThird: UIButton!
    @IBOutlet weak var leastHungerCheckForth: UIButton!
    
    @IBOutlet weak var nextButton: UIButton! {
        didSet {
            nextButton.isEnabled = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func nextButtonAction(_ sender: Any) {
        if numberOfMeals != 0 || mostHunger != 0 || leastHunger != 0 {
            UserProfile.shared.mealsPerDay = numberOfMeals
            UserProfile.shared.mostHungry = mostHunger
            UserProfile.shared.leastHungry = leastHunger
        }
    }
    
    @IBAction func mealsCheckBoxes(sender: UIButton) {
        sender.isSelected = !sender.isSelected
        
        switch sender.tag {
        case 1:
            if sender.isSelected {
                mealCheckSecond.isSelected = false
                mealCheckThird.isSelected = false
                mealCheckForth.isSelected = false
            }
            numberOfMeals = 3
        case 2:
            if sender.isSelected {
                mealCheckFirst.isSelected = false
                mealCheckThird.isSelected = false
                mealCheckForth.isSelected = false
            }
            numberOfMeals = 4
        case 3:
            if sender.isSelected {
                mealCheckFirst.isSelected = false
                mealCheckSecond.isSelected = false
                mealCheckForth.isSelected = false
            }
            numberOfMeals = 5
        case 4:
            if sender.isSelected {
                mealCheckFirst.isSelected = false
                mealCheckThird.isSelected = false
                mealCheckSecond.isSelected = false
            }
            numberOfMeals = 6
        default:
            return
        }
        enableNextButton(sender)
    }
    @IBAction func mostHungryCheckBoxes(sender: UIButton) {
        sender.isSelected = !sender.isSelected
        mostHunger = sender.tag
        
        switch sender.tag {
        case 1:
            if sender.isSelected {
                mostHungerCheckSecond.isSelected = false
                mostHungerCheckThird.isSelected = false
                mostHungerCheckForth.isSelected = false
            }
        case 2:
            if sender.isSelected {
                mostHungerCheckFirst.isSelected = false
                mostHungerCheckThird.isSelected = false
                mostHungerCheckForth.isSelected = false
            }
        case 3:
            if sender.isSelected {
                mostHungerCheckFirst.isSelected = false
                mostHungerCheckSecond.isSelected = false
                mostHungerCheckForth.isSelected = false
            }
        case 4:
            if sender.isSelected {
                mostHungerCheckFirst.isSelected = false
                mostHungerCheckSecond.isSelected = false
                mostHungerCheckThird.isSelected = false
            }
        default:
            return
        }
        enableNextButton(sender)
    }
    @IBAction func leastHungryCheckBoxes(sender: UIButton) {
        sender.isSelected = !sender.isSelected
        leastHunger = sender.tag
        
        switch sender.tag {
        case 1:
            if sender.isSelected {
                leastHungerCheckSecond.isSelected = false
                leastHungerCheckThird.isSelected = false
                leastHungerCheckForth.isSelected = false
            }
        case 2:
            if sender.isSelected {
                leastHungerCheckFirst.isSelected = false
                leastHungerCheckThird.isSelected = false
                leastHungerCheckForth.isSelected = false
            }
        case 3:
            if sender.isSelected {
                leastHungerCheckFirst.isSelected = false
                leastHungerCheckSecond.isSelected = false
                leastHungerCheckForth.isSelected = false
            }
        case 4:
            if sender.isSelected {
                leastHungerCheckFirst.isSelected = false
                leastHungerCheckSecond.isSelected = false
                leastHungerCheckThird.isSelected = false
            }
        default:
            return
        }
        enableNextButton(sender)
    }
}

extension QuestionnaireNutritionViewController {
    
    private func enableNextButton(_ sender: UIButton) {
        if !sender.isSelected {
            nextButton.isEnabled = false
            //present user message for not selecting
        } else if numberOfMeals != 0 && mostHunger != 0 && leastHunger != 0 {
            nextButton.isEnabled = true
        }
    }
}
