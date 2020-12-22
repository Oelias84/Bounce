//
//  QuestionnairePersonalDetailsViewController.swift
//  FitApp
//
//  Created by iOS Bthere on 08/12/2020.
//

import UIKit

class QuestionnairePersonalDetailsViewController: UIViewController {
    
	@IBOutlet weak var birthdayDatePicker: UIDatePicker!
    @IBOutlet weak var userNameTextField: UITextField!
	@IBOutlet weak var heightTextField: UITextField!
    @IBOutlet weak var weightTextField: UITextField!
	
	@IBOutlet weak var nextButton: UIButton!
	
    private let heightNumberArray = Array(100...250)
	private let weightNumberArray = Array(30...200)
    private let frictionNumberArray = Array(0...99)
    private let numberPicker = UIPickerView()
    
    private var birthDate: Date?
    private var height: Int?
    private var weight: Double?
    private var userName: String?
	
	private var weighWholeString: String?
	private var weightFrictionString: String?
	private var weightString: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTextFields()
        configurePicker()
        addScreenTappGesture()
    }
    
    @IBAction func nextButtonAction(_ sender: Any) {
        if let birthDate = birthDate, let name = userName, let height = height, let weight = weight {
            
            UserProfile.shared.name = name
            UserProfile.shared.height = height
            UserProfile.shared.weight = weight
            UserProfile.shared.birthDate = birthDate
			performSegue(withIdentifier: K.SegueId.moveToFatPercentage, sender: self)
        } else {
			//show alert
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
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
		numberPicker.selectRow(0, inComponent: 0, animated: false)
        numberPicker.reloadAllComponents()
        numberPicker.reloadInputViews()
    }
	func textFieldDidEndEditing(_ textField: UITextField) {
        if !(textField.text?.isEmpty ?? true){
            switch textField {
            case userNameTextField:
                userName = textField.text
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
}

extension QuestionnairePersonalDetailsViewController {
    
    private func configureTextFields() {
		birthdayDatePicker.addTarget(self, action: #selector(pickerChanged), for: .valueChanged)
        heightTextField.inputView = numberPicker
        weightTextField.inputView = numberPicker
        heightTextField.delegate = self
        weightTextField.delegate = self
        userNameTextField.delegate = self
    }
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
}
