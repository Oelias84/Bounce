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
}
extension AddMealAlertDishView {
	
	private func setupView() {
		dishNameTextField.delegate = self
		dishAmountTextField.delegate = self
		dishTypeTextField.delegate = self
		
		dishTypePicker.dataSource = self
		dishTypePicker.delegate = self
		
		dishAmountTextField.setupToolBar(cancelButtonName: "אישור")
		dishTypeTextField.setupToolBar(cancelButtonName: "אישור")
		
		dishNameTextField.inputView = UIView()
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
		dishesListVC.type = dish.type
		dishesListVC.state = .exceptional
		dishesListVC.originalDishName = dish.getDishName

		self.parentViewController?.present(dishesListVC, animated: true, completion: nil)
	}
	private func presentAlert(withTitle title: String? = nil, withMessage message: String, options: (String)...) {
		guard let window = (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.window else {
			return
		}
		let storyboard = UIStoryboard(name: "PopupAlertView", bundle: nil)
		let customAlert = storyboard.instantiateViewController(identifier: "PopupAlertView") as! PopupAlertView
		
		customAlert.providesPresentationContextTransitionStyle = true
		customAlert.definesPresentationContext = true
		customAlert.modalPresentationStyle = .overCurrentContext
		customAlert.modalTransitionStyle = .crossDissolve

		customAlert.delegate = self
		customAlert.titleText = title
		customAlert.messageText = message
		customAlert.okButtonText = options[0]
		customAlert.cancelButtonText = options[1]
		
		if options.count == 3 {
			customAlert.doNotShowText = options.last
		}
		window.rootViewController?.present(customAlert, animated: true, completion: nil)
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
				self.presentAlert(withMessage: "נראה שכמות המנה שגויה אנא נסה שנית", options: "הבנתי", "ביטול")
			}
		default:
			break
		}
	}
}

extension AddMealAlertDishView: PopupAlertViewDelegate {
	
	func okButtonTapped(alertNumber: Int, selectedOption: String?, textFieldValue: String?) {
		self.dishAmountTextField.becomeFirstResponder()
	}
	func cancelButtonTapped(alertNumber: Int) {
		return
	}
	func thirdButtonTapped(alertNumber: Int) {
		return
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
		
		dishNameTextField.text = ""
		dishAmountTextField.text = ""
		dish.setName(name: "")
		dish.amount = 0
	}
}

extension AddMealAlertDishView: DishesTableViewControllerDelegate {
	
	func didDissmisView() {
		dishNameTextField.inputView = UIView()
		dishNameTextField.endEditing(true)
	}
	func cancelButtonTapped() {
		dishNameTextField.inputView = UIView()
		dishNameTextField.endEditing(true)
	}
	func didPickDish(name: String?) {
		
		if let name = name {
			dish.setName(name: name)
			dishNameTextField.text = name
		}
		dishNameTextField.inputView = UIView()
		dishNameTextField.endEditing(true)
	}
}
