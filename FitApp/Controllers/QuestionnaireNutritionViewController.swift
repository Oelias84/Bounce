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
    
    @IBOutlet weak var mostHungerCheckFirst: UIButton!
    @IBOutlet weak var mostHungerCheckSecond: UIButton!
    @IBOutlet weak var mostHungerCheckThird: UIButton!
    @IBOutlet weak var mostHungerCheckForth: UIButton!
    
    @IBOutlet weak var nextButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func nextButtonAction(_ sender: Any) {
        if numberOfMeals != 0 && mostHunger != 0 {
            UserProfile.defaults.mealsPerDay = numberOfMeals
            UserProfile.defaults.mostHungry = mostHunger
			performSegue(withIdentifier: K.SegueId.moveToFitnessLevel, sender: self)
        }
    }
    
    @IBAction func mealsCheckBoxes(sender: UIButton) {
        sender.isSelected = !sender.isSelected
        
        switch sender.tag {
        case 1:
            if sender.isSelected {
                mealCheckSecond.isSelected = false
                mealCheckThird.isSelected = false
            }
            numberOfMeals = 3
        case 2:
            if sender.isSelected {
                mealCheckFirst.isSelected = false
                mealCheckThird.isSelected = false
            }
            numberOfMeals = 4
        case 3:
            if sender.isSelected {
                mealCheckFirst.isSelected = false
                mealCheckSecond.isSelected = false
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
		if !sender.isSelected {
			numberOfMeals = 0
		}
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
		if !sender.isSelected {
			mostHunger = 0
		}
    }
}
