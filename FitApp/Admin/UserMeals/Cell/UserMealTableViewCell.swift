//
//  UserMealTableViewCell.swift
//  FitApp
//
//  Created by Ofir Elias on 04/06/2022.
//

import UIKit

class UserMealTableViewCell: UITableViewCell {
	
	var meal: Meal! {
		didSet {
			configureData()
		}
	}

	@IBOutlet weak var cellBackgroundView: UIView!
	@IBOutlet weak var mealNameLabel: UILabel!
	
	@IBOutlet weak var dishesHeadLineStackView: UIStackView!
	@IBOutlet weak var dishStackView: UIStackView!
	@IBOutlet weak var dishesStackViewHeight: NSLayoutConstraint!
	@IBOutlet weak var mealCaloriesSumLabel: UILabel!
	
	private let cellHeight: CGFloat = 46
	
    override func awakeFromNib() {
        super.awakeFromNib()
		
		setupView()
    }
}

//MARK: - Functions
extension UserMealTableViewCell {
	
	private func setupView() {
		selectionStyle = .none
		cellBackgroundView.cellView()
	}
	private func configureData() {
		var tag = 1
		dishStackView.arrangedSubviews.forEach {
			dishesStackViewHeight.constant -= cellHeight
			$0.removeFromSuperview()
		}
		mealNameLabel.text = meal.name
		meal.dishes.forEach {
			let view = DishView(frame: .zero, isFromAdmin: true)
			view.tag = tag
			tag += 1
			view.dish = $0
			view.dishes = MealManager.shared.getDishesFor(type: $0.type)
			view.clipsToBounds = true
			dishStackView.addArrangedSubview(view)
			dishesStackViewHeight.constant += cellHeight
		}
		mealCaloriesSumLabel.text = "כ- \(DailyMealManager.getMealCaloriesSum(dishes: meal.dishes)) קל׳"
	}
}
