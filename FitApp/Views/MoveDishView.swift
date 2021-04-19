//
//  MoveDishView.swift
//  FitApp
//
//  Created by Ofir Elias on 16/04/2021.
//

import UIKit

class MoveDishView: UIView {
	
	var meal: Meal! {
		didSet {
			mealTitleLabel.text = "העברת מנה מ\(meal.name)"
			dishAmountStepper.maximumValue = meal.dishes[0].amount
			dishAmount = 0.5
			dishToMove = meal.dishes[0]
		}
	}
	private var dishPickerView: UIPickerView = {
		let picker = UIPickerView()
		picker.backgroundColor = .white
		return picker
	}()
	private var destinationPickerView: UIPickerView = {
		let picker = UIPickerView()
		picker.backgroundColor = .white
		return picker
	}()
	
	private var mealViewModel: MealViewModel!
	
	private var dishToMove: Dish?
	private var moveToMealIndex: Meal?
	private var dishAmount: Double?
	
	@IBOutlet var contentView: UIView!
	@IBOutlet weak var mealTitleLabel: UILabel!
	@IBOutlet weak var dishToMoveTextfield: UITextField!
	@IBOutlet weak var destinationMealTextfield: UITextField!
	@IBOutlet weak var dishAmountStepper: UIStepper!
	@IBOutlet weak var dishAmountLabel: UILabel!
	@IBOutlet weak var bottomViewConstrain: NSLayoutConstraint!
		
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		commonInit()
		setupView()
	}
	override init(frame: CGRect) {
		super.init(frame: frame)
		commonInit()
		setupView()
	}
	deinit {
		removeKeyboardListener()
	}

	@IBAction func confirmButtonAction(_ sender: Any) {
		
		if let dish = dishToMove, let portion = dishAmount, let toMeal = moveToMealIndex {
			mealViewModel.move(portion: portion, of: dish, from: meal, to: toMeal)
			removeFromSuperview()
		} else {
			window?.rootViewController?.presentAlert(withTitle: "שגיאה בהעברה", withMessage: "יש לקבוע לאיזו ארוחה להעביר את המנה", options: "אישור", completion: {
				[weak self] _ in
				guard let self = self else { return }
				self.destinationMealTextfield.becomeFirstResponder()
			})
		}
	}
	@IBAction func cancelButtonAction(_ sender: Any) {
		removeFromSuperview()
	}
	@IBAction func dishAmountStepper(_ sender: UIStepper) {
		dishAmount = sender.value
		dishAmountLabel.text = "\(sender.value)"
	}
}

extension MoveDishView: UIPickerViewDelegate, UIPickerViewDataSource {
	
	func numberOfComponents(in pickerView: UIPickerView) -> Int {
		1
	}
	func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		
		switch pickerView {
		case dishPickerView:
			return meal.dishes.count
		case destinationPickerView:
			return mealViewModel.meals!.count
		default:
			return 0
		}
	}
	func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
		
		switch pickerView {
		case dishPickerView:
			let dish = meal.dishes[row]
			return dish.getDishName + " " + dish.type.rawValue
		case destinationPickerView:
			return mealViewModel.meals![row].name
		default:
			return nil
		}
	}
	func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {

	switch pickerView {
	case dishPickerView:
		dishAmountStepper.value = 0.5
		dishAmountStepper.maximumValue = meal.dishes[row].amount
		dishToMoveTextfield.text = meal.dishes[row].getDishName
		dishToMove = meal.dishes[row]
	case destinationPickerView:
		destinationMealTextfield.text = mealViewModel.meals![row].name
		moveToMealIndex = mealViewModel.meals![row]
	default:
		break
	}
}
}

extension MoveDishView: UITextFieldDelegate {
	
	func textFieldDidBeginEditing(_ textField: UITextField) {
		let dishName = textField.text

		switch textField {
		case dishToMoveTextfield:
			if let dishNameIndex = meal.dishes.firstIndex(where: {$0.getDishName == dishName }) {
				dishPickerView.selectRow(dishNameIndex, inComponent: 0, animated: false)
			} else {
				textField.text = meal.dishes.first?.getDishName
			}
		case destinationMealTextfield:
			if let mealNameIndex = mealViewModel.meals?.firstIndex(where: {$0.name == dishName }) {
				dishPickerView.selectRow(mealNameIndex, inComponent: 0, animated: false)
			} else {
				textField.text = mealViewModel.meals!.first?.name
				moveToMealIndex = mealViewModel.meals!.first
			}
		default:
			break
		}
	}
}

extension MoveDishView {
	
	private func setupView() {
		mealViewModel = MealViewModel.shared

		dishPickerView.delegate = self
		dishPickerView.dataSource = self
		destinationPickerView.delegate = self
		destinationPickerView.dataSource = self
		dishToMoveTextfield.delegate = self
		destinationMealTextfield.delegate = self
		dishToMoveTextfield.inputView = dishPickerView
		destinationMealTextfield.inputView = destinationPickerView
		dishToMoveTextfield.tintColor = .clear
		destinationMealTextfield.tintColor = .clear
		dishAmountStepper.minimumValue = 0.5
		dishAmountStepper.stepValue = 0.5
		dishToMoveTextfield.becomeFirstResponder()
	}
	private func commonInit() {
		self.alpha = 0
		Bundle.main.loadNibNamed(K.NibName.moveDishView, owner: self, options: nil)
		addSubview(contentView)
		contentView.frame = self.bounds
		contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		UIView.animate(withDuration: 0.2) {
			self.alpha = 1
		}
		raiseScreenWhenKeyboardAppears()
	}
}
