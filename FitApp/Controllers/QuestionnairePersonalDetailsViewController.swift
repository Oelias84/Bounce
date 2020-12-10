//
//  QuestionnairePersonalDetailsViewController.swift
//  FitApp
//
//  Created by iOS Bthere on 08/12/2020.
//

import UIKit

class QuestionnairePersonalDetailsViewController: UIViewController {
    
    @IBOutlet weak var birthDateTextField: UITextField!
    @IBOutlet weak var heightTextField: UITextField!
    @IBOutlet weak var weightTextField: UITextField!
    
    private let wholeNumberArray = Array(1...250)
    private let frictionNumberArray = Array(0...99)
    private let numberPicker = UIPickerView()
    
    private var birthDate: String?
    private var height: Int?
    private var weight: Double?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTextFields()
        configurePicker()
        addScreenTappGesture()
    }
    
    @IBAction func nextButtonAction(_ sender: Any) {
        if let birthDate = birthDate,
           let height = height, let weight = weight {
            
            UserProfile.shared.birthDate = birthDate
            UserProfile.shared.height = height
            UserProfile.shared.weight = weight
        } else {
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
            return wholeNumberArray.count
        } else {
            return frictionNumberArray.count
        }
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            return "\(wholeNumberArray[row])"
        } else {
            return "\(frictionNumberArray[row])"
        }
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if heightTextField.isFirstResponder {
            heightTextField.text = "\(wholeNumberArray[row])"
            height = wholeNumberArray[row]
        } else if weightTextField.isFirstResponder {
            
        }
    }
    
    @objc private func pickerChanged(_ sender: UIDatePicker) {
        self.birthDateTextField.text = "\(sender.date.dateStringDisplay)"
    }
}

extension QuestionnairePersonalDetailsViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        numberPicker.reloadAllComponents()
        numberPicker.reloadInputViews()
    }
}

extension QuestionnairePersonalDetailsViewController {
    
    func configureTextFields() {
        birthDateTextField.setupDatePicker()
        heightTextField.inputView = numberPicker
        weightTextField.inputView = numberPicker
        
        birthDateTextField.delegate = self
        heightTextField.delegate = self
        weightTextField.delegate = self
    }
    func configurePicker() {
        numberPicker.delegate = self
        numberPicker.dataSource = self
        numberPicker.backgroundColor = .white
    }
}
