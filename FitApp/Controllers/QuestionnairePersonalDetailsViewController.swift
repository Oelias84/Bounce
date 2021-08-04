//
//  QuestionnairePersonalDetailsViewController.swift
//  FitApp
//
//  Created by iOS Bthere on 08/12/2020.
//

import UIKit

class QuestionnairePersonalDetailsViewController: UIViewController {
    
	@IBOutlet weak var birthdayDatePicker: UIDatePicker!
	@IBOutlet weak var heightTextField: UITextField!
    @IBOutlet weak var weightTextField: UITextField!
	
	@IBOutlet weak var nextButton: UIButton!
	
    private let numberPicker = UIPickerView()
	private let weightNumberArray = Array(30...200)
    private let frictionNumberArray = Array(0...99)
    private let heightNumberArray = Array(100...250)

    private var height: Int?
    private var weight: Double?
    private var birthDate: Date?
    private var userName: String?
	
    private var weightString: String?
	private var weighWholeString: String?
	private var weightFrictionString: String?
    
    private let googleManager = GoogleApiManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTextFields()
        configurePicker()
        addScreenTappGesture()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupTextfieldText()
    }
    
    @IBAction func nextButtonAction(_ sender: Any) {
		
        if let birthDate = birthDate, let height = height, let weight = weight {
			if birthDate.isLater(than: Date()) {
				presentAlert(withMessage: "תאריך הלידה לא יכול גדול מהתאריך הנוחכי", options: "אישור") { _ in
					self.birthdayDatePicker.becomeFirstResponder()
				}
			} else if height<100 {
				presentAlert(withMessage: "גובה שגויי אנא בדקי את הנתונים שהזנת", options: "אישור") { _ in
					self.heightTextField.becomeFirstResponder()
				}
			} else if weight<30.0 {
				presentAlert(withMessage: "משקל שגויי אנא בדקי את הנתונים שהזנת", options: "אישור") { _ in
					self.weightTextField.becomeFirstResponder()
				}
			} else {
				UserProfile.defaults.height = height
				UserProfile.defaults.weight = weight
				UserProfile.defaults.birthDate = birthDate
				googleManager.updateWeights(weights: Weights(weights: [Weight(date: Date(), weight: weight)]))
				self.performSegue(withIdentifier: K.SegueId.moveToFatPercentage, sender: self)
			}
        } else {
			presentAlert(withMessage: "יש למלא את כל השדות", options: "אישור") { _ in
				self.birthdayDatePicker.becomeFirstResponder()
			}
			return
        }
    }
}

extension QuestionnairePersonalDetailsViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        var components = 1
        
        if weightTextField.isFirstResponder {
            components = 2
        }
        return components
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {

		
        if component == 0 {
			if weightTextField.isFirstResponder {
				return weightNumberArray.count
			}
			return heightNumberArray.count
        } else {
            return frictionNumberArray.count
        }
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
			if weightTextField.isFirstResponder {
				return "\(weightNumberArray[row])"
			}
            return "\(heightNumberArray[row])"
        } else {
            return "\(frictionNumberArray[row])"
        }
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if heightTextField.isFirstResponder {
            heightTextField.text = "\(heightNumberArray[row])"
            height = heightNumberArray[row]
        } else if weightTextField.isFirstResponder {
			if component == 0 {
				weighWholeString = "\(weightNumberArray[row])"
			} else {
				weightFrictionString = "\(frictionNumberArray[row])"
			}
			weightString = "\(weighWholeString ?? "0").\(weightFrictionString ?? "0")"
			weightTextField.text = weightString
			weight = Double(weightString!)
        }
    }
    
    @objc private func pickerChanged(_ sender: UIDatePicker) {
		birthDate = sender.date
    }
}

extension QuestionnairePersonalDetailsViewController: UITextFieldDelegate {
    
	func textFieldDidEndEditing(_ textField: UITextField) {
        if !(textField.text?.isEmpty ?? true){
            switch textField {
            case heightTextField:
                height = Int(textField.text!)
            case weightTextField:
                weight = Double(textField.text!)
            default:
                break
            }
        }
		checkFieldsEmpty()
	}
    func textFieldDidBeginEditing(_ textField: UITextField) {
        numberPicker.selectRow(0, inComponent: 0, animated: false)
        numberPicker.reloadAllComponents()
        numberPicker.reloadInputViews()
    }
}

extension QuestionnairePersonalDetailsViewController {
    
    private func configurePicker() {
        numberPicker.delegate = self
        numberPicker.dataSource = self
        numberPicker.backgroundColor = .white
		numberPicker.semanticContentAttribute = .forceLeftToRight
    }
	private func checkFieldsEmpty() {
		if let height = heightTextField.text, let weight = weightTextField.text {
			if !height.isEmpty && !weight.isEmpty {
				nextButton.isEnabled = true
			}
		}
	}
    private func setupTextfieldText() {
        let userData = UserProfile.defaults
        
		if let height = userData.height, let weight = userData.weight, let birthDate = userData.birthDate {
            heightTextField.text = "\(height)"
            weightTextField.text = "\(weight)"
			birthdayDatePicker.date = birthDate
			
			self.height = height
			self.weight = weight
			self.birthDate = birthDate
        }
    }
    private func configureTextFields() {
        
        birthdayDatePicker.addTarget(self, action: #selector(pickerChanged), for: .valueChanged)
        heightTextField.inputView = numberPicker
        weightTextField.inputView = numberPicker
        heightTextField.delegate = self
        weightTextField.delegate = self
    }
}
