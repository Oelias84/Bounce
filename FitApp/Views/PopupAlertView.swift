//
//  PopupAlertView.swift
//  FitApp
//
//  Created by Ofir Elias on 12/01/2022.
//

import UIKit

protocol PopupAlertViewDelegate: AnyObject {
	
	func okButtonTapped(alertNumber: Int, selectedOption: String?, textFieldValue: String?)
	func cancelButtonTapped(alertNumber: Int)
	func thirdButtonTapped(alertNumber: Int)
}

class PopupAlertView: UIViewController {
	
	var alertNumber: Int = 1
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var messageLabel: UILabel!
	@IBOutlet weak var alertView: UIView!
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
		animateView()
	}
	
	@IBAction func onTapOkButton(_ sender: UIButton) {
		delegate?.okButtonTapped(alertNumber: alertNumber, selectedOption: nil, textFieldValue: nil)
		self.dismiss(animated: true, completion: nil)
	}
	@IBAction func onTapCancelButton(_ sender: UIButton) {
		delegate?.cancelButtonTapped(alertNumber: alertNumber)
		self.dismiss(animated: true, completion: nil)
	}
	@IBAction func thirdButton(_ sender: UIButton) {
		delegate?.thirdButtonTapped(alertNumber: alertNumber)
		self.dismiss(animated: true, completion: nil)
	}
	
	private func setupView() {
		alertView.layer.cornerRadius = 15
		self.view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
	}
	private func animateView() {
		alertView.alpha = 0;
		self.alertView.frame.origin.y = self.alertView.frame.origin.y + 50
		UIView.animate(withDuration: 0.4, animations: { () -> Void in
			self.alertView.alpha = 1.0;
			self.alertView.frame.origin.y = self.alertView.frame.origin.y - 50
		})
	}
}
