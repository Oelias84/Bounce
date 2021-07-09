//
//  AddWeightAlertView.swift
//  FitApp
//
//  Created by Ofir Elias on 13/02/2021.
//

import UIKit

protocol AddWeightAlertViewDelegate {
	
	func cancelButtonAction()
	func cameraButtonTapped()
	func confirmButtonAction(weight: String)
}

class AddWeightAlertView: UIView {
	
	@IBOutlet var contentView: UIView!
	@IBOutlet weak var dateLabel: UILabel!
	@IBOutlet weak var weightTextField: UITextField!
	@IBOutlet weak var weightImageButton: UIImageView!
	@IBOutlet weak var checkMarkImageView: UIImageView!
	
	var delegate: AddWeightAlertViewDelegate?
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		commonInit()
		setupView()
	}
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		commonInit()
		setupView()
	}
	deinit {
		removeKeyboardListener()
	}
	
	@objc func cameraButtonAction() {
		delegate?.cameraButtonTapped()
	}
	@IBAction func confirmButtonAction(_ sender: Any) {
		if let weight = weightTextField.text, !weight.isEmpty {
			delegate?.confirmButtonAction(weight: weight)
		} else {
			weightTextField.becomeFirstResponder()
			weightTextField.layer.borderColor = UIColor.red.cgColor
		}
	}
	@IBAction func cancelButtonAction(_ sender: Any) {
		delegate?.cancelButtonAction()
	}
	
	private func commonInit() {
		self.alpha = 0
		Bundle.main.loadNibNamed(K.NibName.addWeightAlertView, owner: self, options: nil)
		addSubview(contentView)
		contentView.frame = self.bounds
		contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		UIView.animate(withDuration: 0.2) {
			self.alpha = 1
		}
	}
	private func setupView() {
		var dateStringDisplay: String {
			let formatter = DateFormatter()
			formatter.dateFormat = "dd/MM/yy"
			formatter.locale = Locale(identifier: "en_Us")
			formatter.timeZone = .current
			return formatter.string(from: Date())
		}
		
		weightTextField.becomeFirstResponder()
		weightTextField.layer.borderColor = UIColor.systemBlue.cgColor
		dateLabel.text = dateStringDisplay
		raiseScreenWhenKeyboardAppears()
		weightImageButton.isUserInteractionEnabled = true
		weightImageButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(cameraButtonAction)))
	}
	func chageCheckMarkState() {
		DispatchQueue.main.async { [weak self] in
			guard let self = self else { return }
			self.checkMarkImageView.isHidden = false
		}
	}
}
