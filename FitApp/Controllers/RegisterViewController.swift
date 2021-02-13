//
//  RegisterViewController.swift
//  FitApp
//
//  Created by Ofir Elias on 24/11/2020.
//

import UIKit
import FirebaseAuth
import CropViewController

class RegisterViewController: UIViewController {
	
	private let imagePickerController = UIImagePickerController()
	
	@IBOutlet weak var userNameTextfield: UITextField!
	@IBOutlet weak var emailTextfield: UITextField!
	@IBOutlet weak var passwordTextfield: UITextField!
	@IBOutlet weak var confirmPasswordTextfield: UITextField!
	
	@IBOutlet weak var profileImageButton: UIButton!
	@IBOutlet weak var profileImageView: UIImageView!
	
	private var profileImage: UIImage?
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
	}
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
		if let userName = userNameTextfield.text, let email = emailTextfield.text, let password = passwordTextfield.text, let confirmedEmail = confirmPasswordTextfield.text {
			Spinner.shared.show(self.view)
			if password != confirmedEmail {
				presentOkAlert(withTitle: "סיסמה שגויה", withMessage: "אנא נסי שוב") {}
				return
			} else {
				GoogleDatabaseManager.shared.userExists(with: email) { [weak self] doesExist in
					guard let self = self else { return }
					
					if !doesExist {
						UserProfile.defaults.email = email
						Auth.auth().createUser(withEmail: email, password: password){
							[weak self] (user, error) in
							guard let self = self else { return }
							
							if error == nil {
								let splitUserName = userName.splitFullName
								let user = User(firsName: splitUserName.0, lastName: splitUserName.1, email: email)
								
								GoogleDatabaseManager.shared.insertUser(with: user) {
									[weak self] success in
									guard let self = self else { return }

									switch success {
									case true:
										UserProfile.defaults.name = userName

										if let image = self.profileImage {
											GoogleStorageManager.shared.uploadImage(from: .profileImage, data: image.jpegData(compressionQuality: 8)!, fileName: user.profileImageUrl){
												result in
												
												switch result {
												case .success(let imageUrl):
													UserProfile.defaults.profileImageImageUrl = imageUrl
												case .failure(let error):
													print(error)
												}
												self.moveToHomeViewController()
											}
										} else {
											self.moveToHomeViewController()
										}
									case false:
										self.presentAlert(withTitle: "שגיאה", withMessage: "ההרשמה נכשלה אנא נסה שנית", options: "אוקיי") {
											_ in
											
											self.passwordTextfield.text?.removeAll()
											self.confirmPasswordTextfield.text?.removeAll()
										}
									}
								}
							} else {
								Spinner.shared.stop()
								self.presentOkAlert(withTitle: "שגיאה", withMessage: error!.localizedDescription) {}
							}
						}
					} else {
						Spinner.shared.stop()
						self.presentOkAlert(withTitle: "משתמש קיים", withMessage: "אנא נסי שוב") {
							self.userNameTextfield.text?.removeAll()
							self.emailTextfield.text?.removeAll()
							self.passwordTextfield.text?.removeAll()
							self.confirmPasswordTextfield.text?.removeAll()
							
						}
						return
					}
				}
			}
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
