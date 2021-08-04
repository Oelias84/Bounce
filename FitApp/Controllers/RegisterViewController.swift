//
//  RegisterViewController.swift
//  FitApp
//
//  Created by Ofir Elias on 24/11/2020.
//

import UIKit
import CropViewController

class RegisterViewController: UIViewController {
	
	private let viewModel = RegisterViewModel()
	private let imagePickerController = UIImagePickerController()
	private var profileImage: UIImage?
	
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
		
		do {
			try viewModel.register(userName: userNameTextfield.text, email: emailTextfield.text, password: passwordTextfield.text, confirmPassword: confirmPasswordTextfield.text, userImage: profileImage) {
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
						self.presentOkAlert(withTitle: "שמשתמש קיים", withMessage: "נראה שכתובת האימייל שהזנת כבר קיימת במערכת, אנא נסי שנית") {
							self.userNameTextfield.text?.removeAll()
							self.emailTextfield.text?.removeAll()
							self.passwordTextfield.text?.removeAll()
							self.confirmPasswordTextfield.text?.removeAll()
						}
					case ErrorManager.RegisterError.failToRegister:
						Spinner.shared.stop()
						self.presentOkAlert(withTitle: "אופס",withMessage: "נראה שיש בעיה ביצירת המשתמש, אנא נסה שנית מאוחר יותר") { }
					case ErrorManager.RegisterError.userNotSaved:
						Spinner.shared.stop()
						self.presentOkAlert(withTitle: "אופס",withMessage: "נראה שיש בעיה ביצירת המשתמש \(error.localizedDescription)") { }
					default:
						Spinner.shared.stop()
						self.presentOkAlert(withTitle: "אופס",withMessage: "נראה שיש בעיה: \(error.localizedDescription)") { }
					}
				}
			}
			
		} catch ErrorManager.RegisterError.emptyUserName {
			Spinner.shared.stop()
			presentOkAlert(withTitle: "אופס",withMessage: "נראה ששחכת להזין שם משתמש") {
				self.userNameTextfield.becomeFirstResponder()
			}
		} catch ErrorManager.RegisterError.emptyEmail {
			Spinner.shared.stop()
			presentOkAlert(withTitle: "אופס",withMessage: "נראה ששחכת להזין כתובת אימייל") {
				self.emailTextfield.becomeFirstResponder()
			}
		} catch ErrorManager.RegisterError.emptyPassword {
			Spinner.shared.stop()
			presentOkAlert(withTitle: "אופס",withMessage: "נראה ששחכת להזין סיסמא") {
				self.passwordTextfield.becomeFirstResponder()
			}
		} catch ErrorManager.RegisterError.emptyConfirmPassword {
			Spinner.shared.stop()
			presentOkAlert(withTitle: "אופס",withMessage: "נראה ששחכת להזין את אישור הסיסמא") {
				self.confirmPasswordTextfield.becomeFirstResponder()
			}
		} catch ErrorManager.RegisterError.userNameNotFullName {
			Spinner.shared.stop()
			presentOkAlert(withTitle: "אופס",withMessage: "יש להזין שם ושם משפחה") {
				self.userNameTextfield.becomeFirstResponder()
			}
		} catch ErrorManager.RegisterError.incorrectEmail {
			Spinner.shared.stop()
			presentOkAlert(withTitle: "אופס",withMessage: "נראה כי כתובת האימייל שגויה") {
				self.emailTextfield.becomeFirstResponder()
			}
		} catch ErrorManager.RegisterError.shortPassword {
			Spinner.shared.stop()
			presentOkAlert(withTitle: "אופס",withMessage: "הסיסמא חייבת לכלול רק 6 תווים") {
				self.passwordTextfield.becomeFirstResponder()
			}
		} catch ErrorManager.RegisterError.confirmPasswordDoNotMatch {
			Spinner.shared.stop()
			presentOkAlert(withTitle: "אופס",withMessage: "הסיסמא אינה תואמת, אנא נסי שנית") {
				self.confirmPasswordTextfield.becomeFirstResponder()
			}
		} catch {
			print("Something went wrong!")
		}
	}
	
	func moveToHomeViewController() {
		let storyboard = UIStoryboard(name: K.StoryboardName.home, bundle: nil)
		let homeVC = storyboard.instantiateViewController(withIdentifier: K.ViewControllerId.HomeTabBar)
		
		homeVC.modalPresentationStyle = .fullScreen
		self.present(homeVC, animated: true)
		Spinner.shared.stop()
	}
}

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
