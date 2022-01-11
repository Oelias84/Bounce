//
//  PopupAlertView.swift
//  FitApp
//
//  Created by Ofir Elias on 12/01/2022.
//

import UIKit

protocol PopupAlertViewDelegate: AnyObject {
	
	func okButtonTapped(selectedOption: String?, textFieldValue: String?)
	func cancelButtonTapped()
}

class PopupAlertView: UIViewController {
	
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var messageLabel: UILabel!
//	@IBOutlet weak var alertTextField: UITextField!
	@IBOutlet weak var alertView: UIView!
	@IBOutlet weak var cancelButton: UIButton!
	@IBOutlet weak var okButton: UIButton!
//	@IBOutlet weak var segmentedControl: UISegmentedControl!
	
	weak var delegate: PopupAlertViewDelegate?
	var selectedOption = "First"
	let alertViewGrayColor = UIColor(red: 224.0/255.0, green: 224.0/255.0, blue: 224.0/255.0, alpha: 1)
	
	var titleText: String?
	var messageText: String?
	
	override func viewDidLoad() {
		super.viewDidLoad()
//		alertTextField.becomeFirstResponder()
		
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
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		setupView()
		animateView()
	}
	
	func setupView() {
		alertView.layer.cornerRadius = 15
		self.view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
	}
	
	func animateView() {
		alertView.alpha = 0;
		self.alertView.frame.origin.y = self.alertView.frame.origin.y + 50
		UIView.animate(withDuration: 0.4, animations: { () -> Void in
			self.alertView.alpha = 1.0;
			self.alertView.frame.origin.y = self.alertView.frame.origin.y - 50
		})
	}
	
	@IBAction func onTapCancelButton(_ sender: Any) {
//		alertTextField.resignFirstResponder()
		delegate?.cancelButtonTapped()
		self.dismiss(animated: true, completion: nil)
	}
	
	@IBAction func onTapOkButton(_ sender: Any) {
//		alertTextField.resignFirstResponder()
		delegate?.okButtonTapped(selectedOption: nil, textFieldValue: nil)
		self.dismiss(animated: true, completion: nil)
	}
	
	@IBAction func onTapSegmentedControl(_ sender: UISegmentedControl) {
		switch sender.selectedSegmentIndex {
		case 0:
			print("First option")
			selectedOption = "First"
			break
		case 1:
			print("Second option")
			selectedOption = "Second"
			break
		default:
			break
		}
	}
}
