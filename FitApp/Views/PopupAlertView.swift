//
//  PopupAlertView.swift
//  FitApp
//
//  Created by Ofir Elias on 12/01/2022.
//

import UIKit

enum PopupType {
	
	case normal
	case textField
}

protocol PopupAlertViewDelegate: AnyObject {
	
	func okButtonTapped(alertNumber: Int, selectedOption: String?, textFieldValue: String?)
	func cancelButtonTapped(alertNumber: Int)
	func thirdButtonTapped(alertNumber: Int)
}

class PopupAlertView: UIViewController {
	
	var alertNumber: Int = 1
	var popupType: PopupType = .normal
	
	@IBOutlet weak var alertView: UIView!
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var messageLabel: UILabel!
	
	@IBOutlet weak var textBox: UITextView!
	@IBOutlet weak var cancelButton: UIButton!
	@IBOutlet weak var okButton: UIButton!
	@IBOutlet weak var thirdButton: UIButton!
	
	weak var delegate: PopupAlertViewDelegate?
	
	var selectedOption = "First"
	let alertViewGrayColor = UIColor(red: 224.0/255.0, green: 224.0/255.0, blue: 224.0/255.0, alpha: 1)
		
	var titleText: String?
	var messageText: String?
	var okButtonText: String?
	var cancelButtonText: String?
	var doNotShowText: String?
	
	var cancelButtonIsHidden: Bool = false
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		switch popupType {
		case .normal:
			break
		case .textField:
			textBox.isHidden = false
		}
		
		if titleText != nil {
			titleLabel.text = titleText
		} else {
			titleLabel.isHidden = true
		}
		if messageText != nil {
			messageLabel.text = messageText
		} else {
			messageLabel.isHidden = true
		}
		if okButtonText != nil {
			okButton.setTitle(okButtonText, for: .normal)
		}
		if cancelButtonText != nil {
			cancelButton.setTitle(cancelButtonText, for: .normal)
		}
		if cancelButtonIsHidden {
			cancelButton.isHidden = true
		}
		if doNotShowText != nil {
			thirdButton.isHidden = false
			thirdButton.tintColor = .red
			thirdButton.setTitle(doNotShowText, for: .normal)
		}
	}
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		setupView()
		setupTextView()
		animateView()
	}
	
	@IBAction func onTapOkButton(_ sender: UIButton) {
		textBox.resignFirstResponder()
		delegate?.okButtonTapped(alertNumber: alertNumber, selectedOption: nil, textFieldValue: textBox.text)
		self.dismiss(animated: true, completion: nil)
	}
	@IBAction func onTapCancelButton(_ sender: UIButton) {
		textBox.resignFirstResponder()
		delegate?.cancelButtonTapped(alertNumber: alertNumber)
		self.dismiss(animated: true, completion: nil)
	}
	@IBAction func thirdButton(_ sender: UIButton) {
		delegate?.thirdButtonTapped(alertNumber: alertNumber)
		self.dismiss(animated: true, completion: nil)
	}
}
//MARK: - Delegates
extension PopupAlertView: UITextViewDelegate  {
	
	func textViewDidBeginEditing(_ textView: UITextView) {

		if textBox.textColor == UIColor.lightGray {
			textBox.text = ""
			textBox.textColor = .black
		}
	}
	func textViewDidEndEditing(_ textView: UITextView) {

		if textBox.text == "" {
			textBox.text = "כתבו את תוכן ההודעה…"
			textBox.textColor = .lightGray
		}
	}
}
//MARK: - Functions
extension PopupAlertView {
	
	private func setupView() {
		alertView.layer.cornerRadius = 15
		view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
	}
	private func setupTextView() {
		textBox.delegate = self
		textBox.text = "כתבו את תוכן ההודעה…"
		textBox.textColor = .lightGray
	}
	private func animateView() {
		alertView.alpha = 0;
		alertView.frame.origin.y = self.alertView.frame.origin.y + 50
		
		UIView.animate(withDuration: 0.4, animations: { () -> Void in
			self.alertView.alpha = 1.0;
			self.alertView.frame.origin.y = self.alertView.frame.origin.y - 50
		})
	}
}

