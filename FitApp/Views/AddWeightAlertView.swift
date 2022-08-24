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
	func confirmButtonAction(weight: String, date: Date?, imagePath: String?)
}

class AddWeightAlertView: UIView {
	
	var editWeight: Weight?
	
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
	required init?(weight: Weight?) {
		self.editWeight = weight
		super.init(frame: CGRect.zero)
		commonInit()
		setupView()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	deinit {
		removeKeyboardListener()
	}
	
	@IBAction func confirmButtonAction(_ sender: Any) {
		if let perentVC = parentViewController {
			Spinner.shared.show(perentVC.view)
		}
		if let weight = weightTextField.text, !weight.isEmpty {
			delegate?.confirmButtonAction(weight: weight, date: editWeight?.date, imagePath: editWeight?.imagePath)
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

		if let weight = editWeight {
			weightTextField.text = String(weight.weight)
			dateLabel.text = weight.date.dateStringDisplay
		} else {
			dateLabel.text = Date().dateStringDisplay
		}
		raiseScreenWhenKeyboardAppears()
		weightTextField.becomeFirstResponder()
		weightImageButton.isUserInteractionEnabled = true
		weightTextField.layer.borderColor = UIColor.systemBlue.cgColor
		weightImageButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(cameraButtonAction)))
	}
	func changeCheckMarkState() {
		DispatchQueue.main.async { [weak self] in
			guard let self = self else { return }
			self.checkMarkImageView.isHidden = false
		}
	}
	@objc func cameraButtonAction() {
		delegate?.cameraButtonTapped()
	}
}
