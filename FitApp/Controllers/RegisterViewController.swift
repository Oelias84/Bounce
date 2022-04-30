//
//  RegisterViewController.swift
//  FitApp
//
//  Created by Ofir Elias on 24/11/2020.
//

import UIKit
import PDFKit
import StoreKit
import CropViewController

class RegisterViewController: UIViewController {
	
	var products: [SKProduct]?
	
	private let viewModel = RegisterViewModel()
	private let imagePickerController = UIImagePickerController()
	
	private var orderId: String?
	private var profileImage: UIImage?
	private var userHasCheckedTermOfUse = false
	private var userHasCheckedHealth = false
	
	@IBOutlet weak var emailTextfield: UITextField!
	@IBOutlet weak var passwordTextfield: UITextField!
	@IBOutlet weak var confirmPasswordTextfield: UITextField!
	
	@IBOutlet weak var termsOfUseViewButton: UIButton!
	@IBOutlet weak var healthTermsViewButton: UIButton!
	
	@IBOutlet weak var profileImageButton: UIButton!
	@IBOutlet weak var profileImageView: UIImageView!
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		imagePickerController.delegate = self
		generateOrderId()
		raiseScreenWhenKeyboardAppears()
		addScreenTappGesture()
		setupView()
		
		fetchProducts()
	}
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		
		removeKeyboardListener()
	}
	
	@IBAction func profileImageButtonAction(_ sender: UIButton) {
		presentImagePickerActionSheet(imagePicker: imagePickerController) { _ in }
	}
	@IBAction func singUpButtonAction(_ sender: Any) {
		Spinner.shared.show(self.view)
		view.endEditing(true)
		
		do {
			try viewModel.validateData(email: emailTextfield.text, password: passwordTextfield.text, confirmPassword: confirmPasswordTextfield.text, termsOfUse: userHasCheckedTermOfUse) {
				error in
				
				if let error = error {
					if error as? ErrorManager.RegisterError == ErrorManager.RegisterError.emailExist {
						Spinner.shared.stop()
						self.presentAlert(withTitle: "שמשתמש קיים", withMessage: "נראה שכתובת האימייל שהזנת כבר קיימת במערכת, אנא נסי שנית", alertNumber: 6)
					} else {
						Spinner.shared.stop()
						self.presentAlert(withTitle: "אופס",withMessage: "נראה שיש בעיה ביצירת המשתמש, אנא נסה שנית מאוחר יותר", alertNumber: 0)
					}
					return
				} else {
					self.purchase(product: .monthlySubID)
				}
			}
		} catch ErrorManager.RegisterError.emptyEmail {
			Spinner.shared.stop()
			presentAlert(withTitle: "אופס", withMessage: "נראה ששחכת להזין כתובת אימייל", alertNumber: 3)
		} catch ErrorManager.RegisterError.emptyPassword {
			Spinner.shared.stop()
			presentAlert(withTitle: "אופס", withMessage: "נראה ששחכת להזין סיסמא", alertNumber: 4)
		} catch ErrorManager.RegisterError.emptyConfirmPassword {
			Spinner.shared.stop()
			presentAlert(withTitle: "אופס", withMessage: "נראה ששחכת להזין את אישור הסיסמא", alertNumber: 5)
		} catch ErrorManager.RegisterError.userNameNotFullName {
			Spinner.shared.stop()
			presentAlert(withTitle: "אופס", withMessage: "יש להזין שם ושם משפחה", alertNumber: 1)
		} catch ErrorManager.RegisterError.incorrectEmail {
			Spinner.shared.stop()
			presentAlert(withTitle: "אופס", withMessage: "נראה כי כתובת האימייל שגויה", alertNumber: 3)
		} catch ErrorManager.RegisterError.shortPassword {
			Spinner.shared.stop()
			presentAlert(withTitle: "אופס", withMessage: "הסיסמא חייבת לכלול רק 6 תווים", alertNumber: 5)
		} catch ErrorManager.RegisterError.confirmPasswordDoNotMatch {
			Spinner.shared.stop()
			presentAlert(withTitle: "אופס", withMessage: "הסיסמא אינה תואמת, אנא נסי שנית", alertNumber: 5)
		} catch ErrorManager.RegisterError.termsOfUse {
			Spinner.shared.stop()
			presentAlert(withTitle: "תנאי השירות לא אושרו", withMessage: "נראה כי לא אשרת את תנאי השירות, בכדי להמשיך בהרשמה אנא סמני את התיבה שמאשרת את תנאי השימוש.", alertNumber: 0)
		} catch {
			Spinner.shared.stop()
			presentAlert(withTitle: "אופס", withMessage: "נראה שמשהו לא צפוי קרה, אנא נסי להרשם יותר מאוחר", alertNumber: 0)
		}
	}
	
	@IBAction func termsOfUseViewButtonAction(_ sender: UIButton) {
		if let url = URL(string: "https://bouncefit.co.il/privacy-policy/") {
			UIApplication.shared.open(url)
		}
	}
	@IBAction func termsOfUseCheckMarkButtonAction(_ sender: UIButton) {
		sender.isSelected = !sender.isSelected
		userHasCheckedTermOfUse.toggle()
	}
	@IBAction func heathViewButtonAction(_ sender: UIButton) {
		if let url = URL(string: "https://bouncefit.co.il/health/") {
			UIApplication.shared.open(url)
		}
	}
	@IBAction func heathCheckMarkButtonAction(_ sender: UIButton) {
		sender.isSelected = !sender.isSelected
		userHasCheckedHealth.toggle()
	}
}

//MARK: - Delegates
extension RegisterViewController: CropViewControllerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
	
	func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
		cropViewController.dismiss(animated: true) {
			self.profileImageView.image = image.circleMasked
			self.profileImage = image
		}
	}
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
		let tempoImage = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
		
		picker.dismiss(animated: true)
		presentCropViewController(image: tempoImage, type: .circular)
	}
	func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
		picker.dismiss(animated: true)
	}
}
extension RegisterViewController: PopupAlertViewDelegate {
	
	func okButtonTapped(alertNumber: Int, selectedOption: String?, textFieldValue: String?) {
		switch alertNumber {
		case 1:
			if let url = URL(string: "https://www.bouncefit.co.il") {
				UIApplication.shared.open(url)
			}
		case 3:
			self.emailTextfield.becomeFirstResponder()
		case 4:
			self.passwordTextfield.becomeFirstResponder()
		case 5:
			self.confirmPasswordTextfield.becomeFirstResponder()
		case 6:
			self.emailTextfield.text?.removeAll()
			self.passwordTextfield.text?.removeAll()
			self.confirmPasswordTextfield.text?.removeAll()
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

//MARK: - Register Functions
extension RegisterViewController {
	
	private func fetchProducts() {
		IAPManager.shared.fetchAvailableProducts { (products) in
			self.products = products
		}
	}
	private func generateOrderId() {
		GoogleApiManager.shared.generatOrderId  {
			[weak self] result in
			guard let self = self else { return }
			
			switch result {
			case .success(let orderId):
				self.orderId = orderId
			case .failure(_):
				self.presentOkAlert(withMessage: "משהו השתבש, אנא נסו שוב מאוחר יותר")
			}
		}
	}
	private func purchase(product: IAPProducts) {
		guard let _product = products?.first(where: {$0.productIdentifier == product.rawValue}), let orderId = self.orderId else {
			print("Product: \(product.rawValue) not found in Products Set")
			self.presentAlert(withTitle: "אופס", withMessage: "הרכישה נכשלה, נסו שוב", alertNumber: 3)
			Spinner.shared.stop()
			return
		}
		
		IAPManager.shared.purchase(product: _product) {
			[weak self] (message, product, transaction) in
			guard let self = self else { return }
			
			if let transaction = transaction, let product = product {
				print("Transaction : \(transaction)")
				print("Product: \(product.productIdentifier)")
			
				if transaction.error == nil {
					
					switch transaction.transactionState {
					case .purchased:
						let orderData = OrderData(address: nil,
												  city: nil,
												  companyName: nil,
												  country: nil,
												  dateOfTranasction: transaction.transactionDate?.fullDateStringForDB ?? Date().fullDateStringForDB,
												  email: self.emailTextfield.text, period: 1,
												  phoneNumberL: nil, postCode: nil,
												  productName: "Apple In App Purchase", state: nil,
												  transactionAmount: "\(product.price)", userType: "No Chat User")
						
						self.registerUser(orderId: orderId, order: orderData)
					case .failed:
						Spinner.shared.stop()
						self.presentAlert(withTitle: "אופס", withMessage: message, alertNumber: 3)
					default:
						Spinner.shared.stop()
						self.presentAlert(withTitle: "אופס", withMessage: "הרכישה נכשלה, נסו שוב", alertNumber: 3)
					}
				} else {
					Spinner.shared.stop()
					self.presentAlert(withTitle: "אופס", withMessage: "הרכישה נכשלה, נסו שוב", alertNumber: 3)
				}
			}
		}
	}
	private func registerUser(orderId: String, order: OrderData) {
		self.viewModel.register(orderId: orderId, order: order) { result in
			Spinner.shared.stop()
			
			switch result {
			case .success(_):
				
				self.startQuestionnaire()
			case .failure(let error):
				
				switch error {
				case ErrorManager.RegisterError.emailExist:
					Spinner.shared.stop()
					self.presentAlert(withTitle: "שמשתמש קיים", withMessage: "נראה שכתובת האימייל שהזנת כבר קיימת במערכת, אנא נסי שנית", alertNumber: 6)
				case ErrorManager.RegisterError.userNotApproved:
					Spinner.shared.stop()
					self.presentAlert(withTitle: "אופס",withMessage: "אין באפשרוך להתחבר, אנא צרי איתנו קשר", alertNumber: 0)
				case ErrorManager.RegisterError.failToRegister:
					Spinner.shared.stop()
					self.presentAlert(withTitle: "אופס",withMessage: "נראה שיש בעיה ביצירת המשתמש, אנא נסה שנית מאוחר יותר", alertNumber: 0)
				case ErrorManager.RegisterError.userNotSaved:
					Spinner.shared.stop()
					self.presentAlert(withTitle: "אופס",withMessage: "נראה שיש בעיה ביצירת המשתמש \(error.localizedDescription)", alertNumber: 0)
				default:
					Spinner.shared.stop()
					self.presentAlert(withTitle: "אופס",withMessage: "נראה שיש בעיה: \(error.localizedDescription)", alertNumber: 0)
				}
			}
		}
	}
}
//MARK: - Class Functions
extension RegisterViewController {
	
	private func setupView() {
		let termsOfUseAttributedString = NSMutableAttributedString(string: "קראתי ואני מאשר/ת תקנון תנאי שימוש")
		let termsOfUseCount = termsOfUseAttributedString.string.count
		termsOfUseAttributedString.addAttribute(.link, value: "https://bouncefit.co.il/privacy-policy/",
												range: NSRange(location: termsOfUseCount-16, length: 16))
		
		
		let healthTermsAttributedString = NSMutableAttributedString(string: "קראתי ואני מאשר/ת את הצהרת הבריאות")
		let healthTermsCount = healthTermsAttributedString.string.count
		healthTermsAttributedString.addAttribute(.link, value: "https://bouncefit.co.il/health/",
												 range: NSRange(location: healthTermsCount-13, length: 13))
		
		healthTermsViewButton.setAttributedTitle(healthTermsAttributedString, for: .normal)
		termsOfUseViewButton.setAttributedTitle(termsOfUseAttributedString, for: .normal)
	}
	private func startQuestionnaire() {
		DispatchQueue.main.async {
			let storyboard = UIStoryboard(name: K.StoryboardName.questionnaire, bundle: nil)
			let questionnaireVC = storyboard.instantiateViewController(identifier: K.ViewControllerId.questionnaireNavigation)
		
			questionnaireVC.modalPresentationStyle = .fullScreen
			self.present(questionnaireVC, animated: true)
		}
	}
	private func presentAlert(withTitle title: String? = nil, withMessage message: String, options: (String)..., alertNumber: Int) {
		Spinner.shared.stop()
		
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
		customAlert.cancelButtonIsHidden = true
		
		switch options.count {
		case 1:
			customAlert.okButtonText = options[0]
			customAlert.cancelButtonIsHidden = true
		case 2:
			customAlert.cancelButtonText = options[1]
		case 3:
			customAlert.cancelButtonText = options[1]
			customAlert.doNotShowText = options.last
		default:
			break
		}
		DispatchQueue.main.async {
			window.rootViewController?.present(customAlert, animated: true, completion: nil)
		}
	}
}
