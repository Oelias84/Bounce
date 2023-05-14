//
//  AddMealAlertDishView.swift
//  FitApp
//
//  Created by Ofir Elias on 10/06/2021.
//

import UIKit

class AddMealAlertDishView: UIView {
	
	let viewModel = AddMealAlertDishViewModel()

	@IBOutlet weak var dishTypeTextField: UITextField!
	@IBOutlet weak var dishNameTextField: UITextField!
	@IBOutlet weak var dishAmountTextField: UITextField!
	
	private var dishTypePicker: UIPickerView = {
		let picker = UIPickerView()
		picker.tag = 0
		picker.backgroundColor = .white
		return picker
	}()
	private var halfNumberPicker: UIPickerView = {
		let picker = UIPickerView()
		picker.tag = 1
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

//MARK: - Delegates
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
				viewModel.dish.amount = amount
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
	
	func numberOfComponents(in pickerView: UIPickerView) -> Int {
		1
	}
	func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		
		viewModel.getPickerCount(for: pickerView.tag)
	}
	func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
		
		viewModel.getTitle(for: pickerView.tag, in: row)
	}
	func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
		
		switch pickerView {
		case halfNumberPicker:
			let selectedNumber = viewModel.getHalfNumber(for: row)
			viewModel.dish.amount = selectedNumber
			dishAmountTextField.text = String(selectedNumber)
			
		case dishTypePicker:
			let selectedName = viewModel.getDishName(for: row)
			viewModel.dish.type = DishType.init(rawValue: selectedName)!
			dishTypeTextField.text = selectedName
			
			dishNameTextField.text = ""
			dishAmountTextField.text = ""
			viewModel.dish.setName(name: "")
			viewModel.dish.amount = 0
		default:
			return
		}
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
			viewModel.dish.setName(name: name)
			dishNameTextField.text = name
		}
		dishNameTextField.inputView = UIView()
		dishNameTextField.endEditing(true)
	}
}

//MARK: - Functions
extension AddMealAlertDishView {
	
	private func setupView() {
		dishNameTextField.delegate = self
		dishAmountTextField.delegate = self
		dishTypeTextField.delegate = self
		
		dishTypePicker.dataSource = self
		dishTypePicker.delegate = self
		halfNumberPicker.dataSource = self
		halfNumberPicker.delegate = self
		
		dishAmountTextField.shouldPerformAction = false
		dishTypeTextField.shouldPerformAction = false
		dishTypeTextField.shouldPerformAction = false
		
		dishAmountTextField.tintColor = .clear
		dishTypeTextField.tintColor = .clear
		dishTypeTextField.tintColor = .clear
		
		dishAmountTextField.setupToolBar(cancelButtonName: "אישור")
		dishTypeTextField.setupToolBar(cancelButtonName: "אישור")
		
		dishAmountTextField.inputView = halfNumberPicker
		dishTypeTextField.inputView = dishTypePicker
		dishTypeTextField.text = viewModel.dish.type.rawValue
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
		dishesListVC.type = viewModel.dish.type
		dishesListVC.state = .exceptional
		dishesListVC.originalDishName = viewModel.dish.getDishName
		
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
