//
//  QuestionnairePersonalDetailsViewController.swift
//  FitApp
//
//  Created by iOS Bthere on 08/12/2020.
//

import UIKit
import PDFKit

class QuestionnairePersonalDetailsViewController: UIViewController {
	
	@IBOutlet weak var userNameTextField: UITextField!
	@IBOutlet weak var birthdayDatePicker: UIDatePicker!
	@IBOutlet weak var heightTextField: UITextField!
	@IBOutlet weak var weightTextField: UITextField!
	@IBOutlet weak var pageControl: UIPageControl!

	@IBOutlet weak var termsOfUseViewButton: UIButton!
	@IBOutlet weak var termsOfUseCheckMarkButton: UIButton!
	
	@IBOutlet weak var nextButton: UIButton!
	
	private lazy var pdfView: PDFView = {
		let pdfView = PDFView(frame: self.view.bounds)
		pdfView.translatesAutoresizingMaskIntoConstraints = false
		pdfView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		view.addSubview(pdfView)
		pdfView.autoScales = true

		return pdfView
	}()
	
	private let numberPicker = UIPickerView()
	private let weightNumberArray = Array(30...150)
    private let fractionNumberArray = Array(0...99)
    private let heightNumberArray = Array(100...250)

    private var height: Int?
    private var weight: Double?
    private var birthDate: Date?
    private var userName: String?
	private var userHasCheckedTermOfUse = false

    private var weightString: String?
	private var weighWholeString: String?
	private var weightfractionString: String?
    
    private let googleManager = GoogleApiManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
		super.navigationItem.setHidesBackButton(true, animated: false)

        configurePicker()
		configureTextFields()
        addScreenTappGesture()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupTextfieldText()
    }
    
    @IBAction func nextButtonAction(_ sender: Any) {
		
        if let birthDate = birthDate, let height = height, let weight = weight, let userName = userName {
			
			if userName != "", !userName.isValidFullName {
				presentAlert(withTitle: "אופס",withMessage: "יש להזין שם ושם משפחה", options: "אישור", alertNumber: 1)
			} else if birthDate.onlyDate.isLaterThanOrEqual(to: Date().onlyDate) {
				presentAlert(withTitle: "אופס", withMessage: "תאריך הלידה לא יכול גדול או שווה מהתאריך הנוחכי", options: "אישור", alertNumber: 2)
			} else if height<100 {
				presentAlert(withTitle: "אופס", withMessage: "גובה שגויי אנא בדקי את הנתונים שהזנת", options: "אישור", alertNumber: 3)
			} else if weight<30.0 {
				presentAlert(withTitle: "אופס", withMessage: "משקל שגויי אנא בדקי את הנתונים שהזנת", options: "אישור", alertNumber: 4)
			} else if userHasCheckedTermOfUse == false {
				presentAlert(withTitle: "תנאי השירות לא אושרו", withMessage: "נראה כי לא אשרת את תנאי השירות, בכדי להמשיך בהרשמה אנא סמני את התיבה שמאשרת את תנאי השימוש.", options: "אישור", alertNumber: 5)
			} else {
				UserProfile.defaults.name = userName
				UserProfile.defaults.height = height
				UserProfile.defaults.weight = weight
				UserProfile.defaults.birthDate = birthDate
				UserProfile.defaults.checkedTermsOfUse = userHasCheckedTermOfUse
				googleManager.updateWeights(weights: Weights(weights: [Weight(dateString: Date().dateStringForDB, weight: weight)]))
				
				self.performSegue(withIdentifier: K.SegueId.moveToFatGender, sender: self)
			}
        } else {
			presentAlert(withTitle: "אופס", withMessage: "יש למלא את כל השדות", options: "אישור", alertNumber: 2)
			return
        }
    }
	@IBAction func termsOfUseViewButtonAction(_ sender: UIButton) {
		showTermsOfUse()
	}
	@IBAction func termsOfUseCheckMarkButtonAction(_ sender: UIButton) {
		sender.isSelected = !sender.isSelected
		userHasCheckedTermOfUse = sender.isSelected
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
			return fractionNumberArray.count
		}
	}
	func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
		if component == 0 {
			if weightTextField.isFirstResponder {
				return "\(weightNumberArray[row])"
			}
			return "\(heightNumberArray[row])"
		} else {
			return "\(fractionNumberArray[row])"
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
				weightfractionString = "\(fractionNumberArray[row])"
			}
			weightString = "\(weighWholeString ?? "0").\(weightfractionString ?? "0")"
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
		
        if let text = textField.text, text != "" {
            switch textField {
			case userNameTextField:
				userName = text
            case heightTextField:
                height = Int(text)
            case weightTextField:
                weight = Double(text)
            default:
                break
            }
        }
	}
	func textFieldDidBeginEditing(_ textField: UITextField) {
		
		numberPicker.selectRow(getIndex(textField: textField), inComponent: 0, animated: true)
		numberPicker.reloadAllComponents()
		numberPicker.reloadInputViews()
	}
}
extension QuestionnairePersonalDetailsViewController: PopupAlertViewDelegate {
	
	func okButtonTapped(alertNumber: Int, selectedOption: String?, textFieldValue: String?) {
		switch alertNumber {
		case 1:
			self.userNameTextField.becomeFirstResponder()
		case 2:
			self.birthdayDatePicker.becomeFirstResponder()
		case 3:
			self.heightTextField.becomeFirstResponder()
		case 4:
			self.weightTextField.becomeFirstResponder()
		default:
			break
		}
	}
	func cancelButtonTapped(alertNumber: Int) {
		return
	}
	func thirdButtonTapped(alertNumber: Int) {
		return
	}
}
extension QuestionnairePersonalDetailsViewController {
	
	private func configurePicker() {
		numberPicker.delegate = self
		numberPicker.dataSource = self
		numberPicker.backgroundColor = .white
		numberPicker.semanticContentAttribute = .forceLeftToRight
	}
	private func showTermsOfUse() {
		Spinner.shared.show(self.view)
		GoogleStorageManager.shared.downloadImageURL(from: .pdf, path: "terms_of_use.pdf") {
			[weak self] result in
			guard let self = self else { return }
			Spinner.shared.stop()

			switch result {
			case .success(let url):
				if let document = PDFDocument(url: url) {
					self.pdfView.document = document
				}
			case .failure(let error):
				print(error)
			}
		}
	}
	private func setupTextfieldText() {
		let userData = UserProfile.defaults
		
		if let height = userData.height {
			heightTextField.text = "\(height)"
			self.height = height
		}
		if let birthDate = userData.birthDate {
			birthdayDatePicker.date = birthDate
			self.birthDate = birthDate
		}
		if let weight = userData.weight {
			weightTextField.text = "\(weight)"
			self.weight = weight
		}
		if let name = userData.name {
			userNameTextField.text = name
			self.userName = name
		}
	}
	private func configureTextFields() {
		
		height = 100
		weight = 30.0
		heightTextField.text = String(100.0)
		weightTextField.text = String(30.0)

		heightTextField.inputView = numberPicker
		weightTextField.inputView = numberPicker
		heightTextField.setupToolBar(cancelButtonName: "אישור")
		weightTextField.setupToolBar(cancelButtonName: "אישור")
		
		heightTextField.delegate = self
		weightTextField.delegate = self
		userNameTextField.delegate = self
		birthdayDatePicker.addTarget(self, action: #selector(pickerChanged), for: .valueChanged)
	}
	private func getIndex(textField: UITextField) -> Int {
		var text: String
		
		switch textField {
		case weightTextField:
			text = textField.text ?? "30"
		case heightTextField:
			text = textField.text ?? "100"
		default:
			return 0
		}
		
		let floatText = Float(text)
		let intNum = Int(floatText!)
		
		switch textField {
		case weightTextField:
			return weightNumberArray.firstIndex(of: intNum)!
		case heightTextField:
			return heightNumberArray.firstIndex(of: intNum)!
		default:
			return 0
		}
	}
	private func presentAlert(withTitle title: String? = nil, withMessage message: String, options: (String)..., alertNumber: Int) {
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
		customAlert.alertNumber = alertNumber
		customAlert.okButtonText = options[0]
		customAlert.cancelButtonText = options[1]
		
		switch options.count {
		case 1:
			customAlert.cancelButton.isHidden = true
		case 3:
			customAlert.doNotShowText = options.last
		default:
			break
		}
		
		window.rootViewController?.present(customAlert, animated: true, completion: nil)
	}

}
