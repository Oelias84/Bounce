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
			updateAmountLabel()
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
	
	@IBOutlet weak var dishToMoveTextLabel: UILabel!
	@IBOutlet weak var dishAmountTextLabel: UILabel!
	@IBOutlet weak var mealToMoveTextLabel: UILabel!
	
	@IBOutlet weak var mealTitleLabel: UILabel!
	@IBOutlet weak var dishToMoveTextfield: DishCellTextFieldView!
	@IBOutlet weak var destinationMealTextfield: DishCellTextFieldView!
	@IBOutlet weak var dishAmountStepper: StepperView!
	@IBOutlet weak var dishAmountLabel: UILabel!
	@IBOutlet weak var bottomViewConstrain: NSLayoutConstraint!
	
	deinit {
		removeKeyboardListener()
	}
	
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
	override func draw(_ rect: CGRect) {
		super.draw(rect)
		UIView.animate(withDuration: 0.2) {
			self.alpha = 1
		}
	}
	
	@IBAction func confirmButtonAction(_ sender: Any) {
		Spinner.shared.show()
		
		if let dish = dishToMove, let portion = dishAmount, let toMeal = moveToMealIndex {
			mealViewModel.move(portion: portion, of: dish, from: meal, to: toMeal) { error in
				Spinner.shared.stop()
				if error != nil {
					self.presentOkAlertWithDelegate(withTitle: "שגיאה בהעברה", withMessage: "אנא נסו שנית מאור יותר")
				} else {
					self.removeFromSuperview()
				}
			}
		} else {
			self.presentOkAlertWithDelegate(withTitle: "שגיאה בהעברה", withMessage: "יש לקבוע לאיזו ארוחה להעביר את המנה")
		}
	}
	@IBAction func cancelButtonAction(_ sender: Any) {
		removeFromSuperview()
	}
}

// MARK: - Delegates
extension MoveDishView: PopupAlertViewDelegate {
	
	func okButtonTapped(alertNumber: Int, selectedOption: String?, textFieldValue: String?) {
		self.destinationMealTextfield.becomeFirstResponder()
	}
	func cancelButtonTapped(alertNumber: Int) {
		return
	}
	func thirdButtonTapped(alertNumber: Int) {
		return
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
			return  dish.getDishName
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
			updateAmountLabel()
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

//MARK: - Functions
extension MoveDishView {
	
	private func setupView() {
		mealViewModel = MealViewModel.shared
		
		setupStepper()
		raiseScreenWhenKeyboardAppears()
		
		dishPickerView.delegate = self
		dishPickerView.dataSource = self
		destinationPickerView.delegate = self
		destinationPickerView.dataSource = self
		
		dishToMoveTextfield.delegate = self
		destinationMealTextfield.delegate = self
		dishToMoveTextfield.shouldPerformAction = false
		destinationMealTextfield.shouldPerformAction = false
		
		dishToMoveTextfield.inputView = dishPickerView
		destinationMealTextfield.inputView = destinationPickerView
		dishToMoveTextLabel.text = StaticStringsManager.shared.getGenderString?[23] ?? ""
		
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
	}
	private func setupStepper() {
//		dishAmountStepper.roundButtons = true
		dishAmountStepper.labelTextColor = .black
		dishAmountStepper.backgroundColor = .clear
		dishAmountStepper.buttonsTextColor = .white
		dishAmountStepper.labelBackgroundColor = .clear
		dishAmountStepper.buttonsBackgroundColor = .projectTail
		dishAmountStepper.labelFont = UIFont(name: "Assistant-SemiBold", size: 18)!
		dishAmountStepper.addTarget(self, action: #selector(stepperValueChanged), for: .valueChanged)
	}
	private func updateAmountLabel() {
		if let dishToMove = dishToMove {
			dishAmountLabel.text = "\(dishToMove.amount) / \(dishAmount!)"
		}
	}
	func presentOkAlertWithDelegate(withTitle title: String? = nil, withMessage message: String, buttonText: String = "אישור") {
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
		customAlert.cancelButtonIsHidden = true

		window.rootViewController?.present(customAlert, animated: true, completion: nil)
	}
	@objc func stepperValueChanged(stepper: StepperView) {
		dishAmount = stepper.value
		updateAmountLabel()
	}
}

