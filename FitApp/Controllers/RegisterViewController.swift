//
//  RegisterViewController.swift
//  FitApp
//
//  Created by Ofir Elias on 24/11/2020.
//

import UIKit
import PDFKit
import CropViewController

class RegisterViewController: UIViewController {
	
	private let viewModel = RegisterViewModel()
	private let imagePickerController = UIImagePickerController()
	private var profileImage: UIImage?
	private var userHasCheckedTermOfUse = false
	
	@IBOutlet weak var userNameTextfield: UITextField!
	@IBOutlet weak var emailTextfield: UITextField!
	@IBOutlet weak var passwordTextfield: UITextField!
	@IBOutlet weak var confirmPasswordTextfield: UITextField!
	@IBOutlet weak var profileImageButton: UIButton!
	@IBOutlet weak var profileImageView: UIImageView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		imagePickerController.delegate = self
		raiseScreenWhenKeyboardAppears()
		addScreenTappGesture()
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
		signUp()
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
		case 2:
			self.userNameTextfield.becomeFirstResponder()
		case 3:
			self.emailTextfield.becomeFirstResponder()
		case 4:
			self.passwordTextfield.becomeFirstResponder()
		case 5:
			self.confirmPasswordTextfield.becomeFirstResponder()
		case 6:
			self.userNameTextfield.text?.removeAll()
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

//MARK: - Functions
extension RegisterViewController {
	
	private func signUp() {
		
		do {
			try viewModel.register(userName: userNameTextfield.text, email: emailTextfield.text, password: passwordTextfield.text, confirmPassword: confirmPasswordTextfield.text, userImage: profileImage, termsOfUse: userHasCheckedTermOfUse) {
				[weak self] result in
				guard let self = self else { return }
				Spinner.shared.stop()
				
				switch result {
				case .success(_):
					self.moveToHomeViewController()
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
		} catch ErrorManager.RegisterError.emptyUserName {
			Spinner.shared.stop()
			presentAlert(withTitle: "אופס", withMessage: "נראה ששחכת להזין שם משתמש", alertNumber: 2)
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
	private func moveToHomeViewController() {
		let storyboard = UIStoryboard(name: K.StoryboardName.home, bundle: nil)
		let homeVC = storyboard.instantiateViewController(withIdentifier: K.ViewControllerId.HomeTabBar)
		
		homeVC.modalPresentationStyle = .fullScreen
		self.present(homeVC, animated: true)
		Spinner.shared.stop()
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
		customAlert.okButtonText = options[0]
		
		switch options.count {
		case 1:
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
