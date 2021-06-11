//
//  AddMealAlertDishView.swift
//  FitApp
//
//  Created by Ofir Elias on 10/06/2021.
//

import UIKit

class AddMealAlertDishView: UIView {
	
	var dish = Dish(name: "", type: .protein, amount: 0.0)
	
	@IBOutlet weak var dishTypeTextField: UITextField!
	@IBOutlet weak var dishNameTextField: UITextField!
	@IBOutlet weak var dishAmountTextField: UITextField!
	
	private var dishTypePicker: UIPickerView = {
		let picker = UIPickerView()
		
		picker.backgroundColor = .white
		return picker
	}()
	
	@IBOutlet var contentView: UIView!
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		commonInit()
	}
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		commonInit()
	}
	override func draw(_ rect: CGRect) {
		setupView()
	}
	
	private func setupView() {
		dishNameTextField.delegate = self
		dishAmountTextField.delegate = self
		dishTypeTextField.delegate = self
		
		dishNameTextField.inputTextFieldStyle()
		dishAmountTextField.inputTextFieldStyle()
		dishTypeTextField.inputTextFieldStyle()
		
		dishTypePicker.dataSource = self
		dishTypePicker.delegate = self
		
		dishAmountTextField.setupToolBar(cancelButtonName: "אישור")
		dishTypeTextField.setupToolBar(cancelButtonName: "אישור")
		
		dishTypeTextField.inputView = dishTypePicker
		dishTypeTextField.text = dish.type.rawValue
	}
	private func commonInit() {
		
		Bundle.main.loadNibNamed(K.NibName.addMealAlertDishView, owner: self, options: nil)
		addSubview(contentView)
		contentView.frame = self.bounds
		contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
	}
	private func getDishName() {
		let storyboard = UIStoryboard(name: K.StoryboardName.mealPlan, bundle: nil)
		let dishesListVC = storyboard.instantiateViewController(identifier: K.ViewControllerId.dishesListViewController) as DishesTableViewController
		
		dishesListVC.delegate = self
		dishesListVC.originalDish = dish
		self.parentViewController?.present(dishesListVC, animated: true, completion: nil)
	}
}

extension AddMealAlertDishView: UITextFieldDelegate {
	
	func textFieldDidBeginEditing(_ textField: UITextField) {
		
		switch textField {
		case dishNameTextField:
			getDishName()
		case dishAmountTextField:
			dishAmountTextField.text = ""
		default:
			break
		}
	}
	func textFieldDidEndEditing(_ textField: UITextField) {
		
		switch textField {
		case dishAmountTextField:
			if let amountText = dishAmountTextField.text, !amountText.isEmpty {
				let amount = amountText.toDecimalDouble
				dish.amount = amount
				dishAmountTextField.text = String(amount)
			} else {
				self.parentViewController?.presentAlert(withMessage: "נראה שכמות המנה שגויה אנא נסה שנית", options: "הבנתי", "ביטול", completion: {
					[unowned self ] selection in
					
					switch selection {
					case 0:
						self.dishAmountTextField.becomeFirstResponder()
					default:
						break
					}
				})
			}
		default:
			break
		}
	}
}

extension AddMealAlertDishView: UIPickerViewDelegate, UIPickerViewDataSource {
	
	private var typeNames: [String] {
		return DishType.allCases.map {
			$0.rawValue
		}
	}
	
	func numberOfComponents(in pickerView: UIPickerView) -> Int {
		1
	}
	func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		typeNames.count
	}
	func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
		typeNames[row]
	}
	func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
		let selectedName = typeNames[row]
		dish.type = DishType.init(rawValue: selectedName)!
		dishTypeTextField.text = selectedName
	}
}

extension AddMealAlertDishView: DishesTableViewControllerDelegate {
	
	func didPickDish(name: String?) {
		
		if let name = name {
			dish.setName(name: name)
			dishNameTextField.text = name
		}
		dishNameTextField.endEditing(true)
	}
}
