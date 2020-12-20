//
//  MealPlanTableViewCell.swift
//  FitApp
//
//  Created by iOS Bthere on 27/11/2020.
//

protocol MealPlanTableViewCellDelegate {
    func detailTapped(cell: IndexPath)
}

import UIKit

class MealPlanTableViewCell: UITableViewCell {
    
    var indexPath: IndexPath!
    
    var meal: Meal! {
        didSet {
            configureData()
        }
    }
    
    @IBOutlet weak var cellBackgroundView: UIView!
    @IBOutlet weak var mealNameLabel: UILabel!
    @IBOutlet weak var mealDescriptionLabel: UILabel!
    @IBOutlet weak var mealIsDoneCheckMark: UIButton!
    
    @IBOutlet weak var dishesHeadLineStackView: UIStackView!
    @IBOutlet weak var dishStackView: UIStackView!
    @IBOutlet weak var dishesStackViewHeight: NSLayoutConstraint!
    
    var delegate: MealPlanTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func downButtonAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }
    @IBAction func completeMealCheckMarkAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        meal.isMealDone.toggle()
        
        dishStackView.arrangedSubviews.forEach {
            dishesStackViewHeight.constant -= 40
            $0.removeFromSuperview()
        }
        meal.dishes.forEach {
            $0.isDishDone = sender.isSelected
        }
        configureData()
    }
    @IBAction func openDetailsAction(_ sender: UIButton) {
        delegate?.detailTapped(cell: indexPath)
    }
}

extension MealPlanTableViewCell {
    
    private func setupView() {
        cellBackgroundView.layer.cornerRadius = 10
        cellBackgroundView.layer.shadowOpacity = 0.18
        cellBackgroundView.layer.shadowColor = UIColor.systemBlue.cgColor
        cellBackgroundView.layer.shadowOffset = CGSize(width: 0, height: 12)
        cellBackgroundView.layer.shadowRadius = 12
    }
    private func configureData(isChecked: Bool = false){
        var tag = 1
        dishStackView.arrangedSubviews.forEach {
            dishesStackViewHeight.constant -= 40
            $0.removeFromSuperview()
        }
        mealNameLabel.text = meal.name
        meal.dishes.forEach {
            let view = DishView()
            view.tag = tag
            tag += 1
            view.delegate = self
            view.dish = $0
            view.clipsToBounds = true
            dishStackView.addArrangedSubview(view)
            dishesStackViewHeight.constant += 40
        }
    }
    private func checkDish(type: DishType){
        meal.dishes.forEach {
            if $0.type == type {
                $0.isDishDone.toggle()
            }
        }
    }
}

extension MealPlanTableViewCell: DishViewDelegate {
    func didCheck() {
        var allChecked = false
        let isDishesChecked = meal.dishes.compactMap{ $0.isDishDone}
        for isDone in isDishesChecked {
            if !isDone {
                allChecked = false
                break
            } else {
                allChecked = true
            }
        }
        mealIsDoneCheckMark.isSelected = allChecked
        //Update Meal to Server
    }
}
