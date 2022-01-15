//
//  UIViewController+Extensions.swift
//  MyFItApp
//
//  Created by Ofir Elias on 13/11/2020.
//

import UIKit
import FirebaseAuth
import CropViewController

extension UIViewController {
	
	//MARK: - Keyboard Listener
	func raiseScreenWhenKeyboardAppears() {
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
	}
	func removeKeyboardListener() {
		NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: self)
		NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: self)
	}
	func addScreenTappGesture() {
		view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissView)))
	}
	@objc func keyboardWillShow(notification: NSNotification) {
		if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
			if self.view.frame.origin.y == 0 {
				self.view.frame.origin.y -= keyboardSize.height
			}
		}
	}
	@objc func keyboardWillHide(notification: NSNotification) {
		if self.view.frame.origin.y != 0 {
			self.view.frame.origin.y = 0
		}
	}
	@objc func dismissView() {
		view.endEditing(true)
	}
	
	//MARK: - Alerts
	func presentOkAlert(withTitle title: String? = nil, withMessage message: String, buttonText: String = "אישור") {
	
		let storyboard = UIStoryboard(name: "PopupAlertView", bundle: nil)
		let customAlert = storyboard.instantiateViewController(identifier: "PopupAlertView") as! PopupAlertView
		
		customAlert.providesPresentationContextTransitionStyle = true
		customAlert.definesPresentationContext = true
		customAlert.modalPresentationStyle = .overCurrentContext
		customAlert.modalTransitionStyle = .crossDissolve
		
		customAlert.titleText = title
		customAlert.messageText = message
		customAlert.cancelButtonIsHidden = true
		
		present(customAlert, animated: true)
	}
	func presentLogoutAlert() {
		
		let signOutAlert = UIAlertController(title: "התנתקות", message: "האם ברצונך להתנתק מהמערכת?", preferredStyle: .alert)
		
		signOutAlert.addAction(UIAlertAction(title: "אישור", style: .default) { _ in
			do {
				guard let window = (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.window else {
					return
				}
				try Auth.auth().signOut()
				UserDefaults.resetDefaults()
				UserProfile.defaults.resetUserProfileData()
				ConsumptionManager.shared.resetConsumptionManager()
				
				UserProfile.defaults.hasRunBefore = true
				let storyboard = UIStoryboard(name: K.StoryboardName.loginRegister, bundle: nil)
				let startNav = storyboard.instantiateViewController(withIdentifier: K.ViewControllerId.startNavigationViewController)
				
				startNav.modalPresentationStyle = .fullScreen
				window.rootViewController = startNav
			} catch {
				print("Something went Wrong...")
			}
		})
		signOutAlert.addAction(UIAlertAction(title: "ביטול", style: .cancel))
		present(signOutAlert, animated: true)
	}
	
	func presentActionSheet(withTitle title: String? = nil, withMessage message: String?, options: (String)..., completion: @escaping (Int) -> Void) {
		let alertController = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
		for (index, option) in options.enumerated() {
			alertController.addAction(UIAlertAction.init(title: option, style: option == "ביטול" ? .destructive : .default, handler: { _ in
				completion(index)
			}))
		}
		if let popoverController = alertController.popoverPresentationController {
			popoverController.sourceView = self.view
			popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
			popoverController.permittedArrowDirections = []
		}
		present(alertController, animated: true)
	}
	func presentImagePickerActionSheet(imagePicker: UIImagePickerController, completion: @escaping (Bool) -> Void) {
		let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
		alert.addAction(UIAlertAction(title: "מצלמה", style: .default, handler: { _ in
			imagePicker.sourceType = .camera
			self.present(imagePicker, animated: true)
			completion(true)
		}))
		alert.addAction(UIAlertAction(title: "גלריה", style: .default, handler: { _ in
			imagePicker.sourceType = .photoLibrary
			self.present(imagePicker, animated: true)
			completion(true)
		}))
		alert.addAction(UIAlertAction(title: "ביטול", style: .cancel))
		present(alert, animated: true)
		completion(false)
	}
	
	func presentCropViewController(image: UIImage, type: CropViewCroppingStyle) {
		let cropViewController = CropViewController(croppingStyle: type, image: image)
		
		cropViewController.doneButtonTitle = "סיים"
		cropViewController.cancelButtonTitle = "ביטול"
		cropViewController.delegate = self as? CropViewControllerDelegate
		present(cropViewController, animated: true)
	}
	
	func applyGradientBackground() {
		view.layer.insertSublayer(ProjectColors.gradientColorView(view), at: 0)
	}
}
extension UIViewController {
	
	func topMostViewController() -> UIViewController {
		
		if let presented = self.presentedViewController {
			return presented.topMostViewController()
		}
		
		if let navigation = self as? UINavigationController {
			return navigation.visibleViewController?.topMostViewController() ?? navigation
		}
		
		if let tab = self as? UITabBarController {
			return tab.selectedViewController?.topMostViewController() ?? tab
		}
		
		return self
	}
}
