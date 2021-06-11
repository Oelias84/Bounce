//
//  MealPlanTableViewCell.swift
//  FitApp
//
//  Created by iOS Bthere on 27/11/2020.
//

import UIKit
import Foundation

class MealPlanTableViewCell: UITableViewCell {
	
	var indexPath: IndexPath!
	
	var meal: Meal! {
		didSet {
			configureData()
		}
	}
	var moveDishAlert: MoveDishView?
	var mealViewModel: MealViewModel!
	var dishToMove: Dish!
	
	@IBOutlet weak var cellBackgroundView: UIView!
	@IBOutlet weak var mealNameLabel: UILabel!
	@IBOutlet weak var mealIsDoneCheckMark: UIButton!
	
	@IBOutlet weak var dishesHeadLineStackView: UIStackView!
	@IBOutlet weak var dishStackView: UIStackView!
	@IBOutlet weak var dishesStackViewHeight: NSLayoutConstraint!
	@IBOutlet weak var moveDishButton: UIButton!
	@IBOutlet weak var mealCaloriesSumLabel: UILabel!
	
	override func awakeFromNib() {
		super.awakeFromNib()
		
		setupView()
	}
	
	override func setSelected(_ selected: Bool, animated: Bool) {
		super.setSelected(selected, animated: animated)
	}
	
	@IBAction func moveDishButtonAction(_ sender: Any) {
		presentMoveDishAlert()
	}
	@IBAction func completeMealCheckMarkAction(_ sender: UIButton) {
		if meal.isMealDone {
			let alert = UIAlertController(title: "האם ברצונך להסיר את הסימון?", message: nil, preferredStyle: .alert)
			alert.addAction(UIAlertAction(title: "אישור", style: .default, handler: { _ in
				sender.isSelected = !sender.isSelected
				self.changeMealState(sender)
			}))
			alert.addAction(UIAlertAction(title: "ביטול", style: .cancel))
			self.parentViewController?.present(alert, animated: true)
		} else {
			sender.isSelected = !sender.isSelected
			self.changeMealState(sender)
		}
	}
}

extension MealPlanTableViewCell {
	
	private func setupView() {
		cellBackgroundView.layer.cornerRadius = 14
		cellBackgroundView.layer.shadowOpacity = 0.18
		cellBackgroundView.layer.shadowColor = UIColor.systemBlue.cgColor
		cellBackgroundView.layer.shadowOffset = CGSize(width: 0, height: 5)
		cellBackgroundView.layer.shadowRadius = 14
		
	}
	private func presentMoveDishAlert() {
		moveDishAlert = MoveDishView()
		moveDishAlert?.meal = meal
		moveDishAlert?.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width,
									  height: UIScreen.main.bounds.size.height)
		if let alert = moveDishAlert {
			window?.addSubview(alert)
		}
	}
	private func configureData(isChecked: Bool = false) {
		var tag = 1
		mealIsDoneCheckMark.isSelected = meal.isMealDone
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
			view.dishes = mealViewModel.mealManager.getDishesFor(type: $0.type)
			view.clipsToBounds = true
			dishStackView.addArrangedSubview(view)
			dishesStackViewHeight.constant += 40
		}
		if meal.dishes.count == 0 {
			moveDishButton.isHidden = true
		} else {
			moveDishButton.isHidden = false
		}
		mealCaloriesSumLabel.text = "כ- \(mealViewModel.getMealCaloriesSum(dishes: meal.dishes)) קל׳"
	}
}

extension MealPlanTableViewCell: DishViewDelegate {
	
	func didCheck(dish: Dish) {
		var allChecked = false
		
		let isDishesChecked = meal.dishes.compactMap{ $0.isDishDone }
		for isDone in isDishesChecked {
			if !isDone {
				allChecked = false
				break
			} else {
				allChecked = true
			}
		}
		meal.isMealDone = allChecked
		mealIsDoneCheckMark.isSelected = allChecked
		mealViewModel.updateMeals(for: meal.date)
	}
}

extension MealPlanTableViewCell {
	
	func changeMealState(_ sender: UIButton) {
		meal.isMealDone.toggle()
		
		dishStackView.arrangedSubviews.forEach {
			dishesStackViewHeight.constant -= 40
			$0.removeFromSuperview()
		}
		meal.dishes.forEach {
			$0.isDishDone = sender.isSelected
		}
		configureData()
		mealViewModel.updateMeals(for: meal.date)
	}
}
