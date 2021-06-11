//
//  AddMealAlertView.swift
//  FitApp
//
//  Created by Ofir Elias on 09/06/2021.
//

import UIKit

protocol AddMealAlertViewDelegate: AnyObject {
	
	func didFinish(with meal: Meal)
}

class AddMealAlertView: UIView {
	
	var mealDate: Date!
	private var dishes = [Dish]()
	
	@IBOutlet weak var dishStackView: UIStackView!
	@IBOutlet weak var dishStackViewHeightConstrain: NSLayoutConstraint!
	@IBOutlet weak var addButton: UIButton!
	@IBOutlet weak var removeButton: UIButton!
	@IBOutlet var contentView: UIView!
	
	weak var delegate: AddMealAlertViewDelegate?
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		commonInit()
		addDish()
	}
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		commonInit()
	}
	override func draw(_ rect: CGRect) {
		super.draw(rect)
		UIView.animate(withDuration: 0.2) {
			self.alpha = 1
		}
		addButton.layer.cornerRadius = addButton.frame.height/2
		removeButton.layer.cornerRadius = removeButton.frame.height/2
	}
	
	@IBAction func addButtonAction(_ sender: Any) {
		addDish()
	}
	@IBAction func removeButtonAction(_ sender: Any) {
		removeDish()
	}
	@IBAction func confirmButtonAction(_ sender: Any) {
		let meal = Meal(mealType: .other, dishes: dishes, date: mealDate)
		delegate?.didFinish(with: meal)
		removeFromSuperview()
	}
	@IBAction func cancelButtonAction(_ sender: Any) {
		removeFromSuperview()
	}
	
	private func addDish() {
		if dishStackView.arrangedSubviews.count > 2 { return }
		let newDish = AddMealAlertDishView()
		newDish.isHidden = true

		UIView.animate(withDuration: 0.2) {
			newDish.isHidden = false
			self.dishStackView.addArrangedSubview(newDish)
		} completion: { _ in
			self.dishes.append(newDish.dish)
			DispatchQueue.main.async {
				self.shouldHideButtons()
			}
		}
	}
	private func commonInit() {
		alpha = 0
		Bundle.main.loadNibNamed(K.NibName.addMealAlertView, owner: self, options: nil)
		addSubview(contentView)
		contentView.frame = self.bounds
		contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
	}
	private func removeDish() {
		if dishStackView.arrangedSubviews.count == 1 { return }

		var viewCounter = 1
		dishStackView.arrangedSubviews.forEach { view in
			if viewCounter == dishStackView.arrangedSubviews.count {
				UIView.animate(withDuration: 0.2) {
					view.isHidden = true
					view.removeFromSuperview()
				} completion: { _ in
					self.dishes.removeLast()
					DispatchQueue.main.async {
						self.shouldHideButtons()
					}
				}
			}
			viewCounter += 1
		}
	}
	private func shouldHideButtons() {
		let stackCount = self.dishStackView.arrangedSubviews.count
		UIView.animate(withDuration: 0.3) { [unowned self] in
			self.addButton.isHidden = (stackCount == 3)
			self.removeButton.isHidden = (stackCount == 1)
		}
	}
}
