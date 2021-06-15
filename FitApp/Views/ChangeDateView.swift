//
//  ChangeDateView.swift
//  FitApp
//
//  Created by Ofir Elias on 08/06/2021.
//

import UIKit

protocol ChangeDateViewDelegate: AnyObject {
	
	func dateDidChange(_ date:Date)
}

class ChangeDateView: UIView {
	
	private var date = Date()
	private lazy var picker = UIDatePicker()

	@IBOutlet weak var dateTextField: UITextField!
	@IBOutlet weak var backwardDateButtonView: UIView!
	@IBOutlet weak var backwardDateButton: UIButton!
	@IBOutlet weak var forwardDateButtonView: UIView!
	@IBOutlet weak var forwardDateButton: UIButton!
	
	@IBOutlet var contentView: UIView!
	
	weak var delegate: ChangeDateViewDelegate?
	
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
	
	@IBAction func changeDateButtons(_ sender: UIButton) {
		
		switch sender {
		case forwardDateButton:
			date = date.add(1.days)
			delegate?.dateDidChange(date)
		case backwardDateButton:
			date = date.subtract(1.days)
			delegate?.dateDidChange(date)
		default:
			break
		}
		dateTextField.text = date.dateStringDisplay + " " + date.displayDayName
	}

	private func setupView() {
		
		dateTextField.delegate = self
		dateTextField.tintColor = .clear

		dateTextField.text = date.dateStringDisplay + " " + date.displayDayName
		
		backwardDateButtonView.buttonShadow()
		forwardDateButtonView.buttonShadow()
		addDatePickerWithToolBar()
	}
	private func commonInit() {
		Bundle.main.loadNibNamed(K.NibName.changeDateView, owner: self, options: nil)
		addSubview(contentView)
		contentView.frame = self.bounds
		contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
	}
	
	func changeToCurrentDate() {
		date = Date()
		dateTextField.text = date.dateStringDisplay + " " + date.displayDayName
	}
	private func forwardDateButtonEnable() {
		forwardDateButton.isEnabled = date.onlyDate.isEarlier(than: Date().onlyDate)

	}
	private func addDatePickerWithToolBar() {
		let toolBar = UIToolbar()

		if #available(iOS 13.4, *) {
			picker.preferredDatePickerStyle = .wheels
		}
		picker.maximumDate = Date()
		picker.datePickerMode = .date
		picker.backgroundColor = .white
		
		if let textFieldTime = dateTextField.text?.timeFromString {
			picker.date = textFieldTime
		}
		toolBar.backgroundColor = .white
		toolBar.sizeToFit()
		
		let doneButton = UIBarButtonItem(title: "בחר", style: .plain, target: self, action: #selector(toolBarDoneTapped(_:)))
		let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
		let cancelButton = UIBarButtonItem(title: "סגור", style: .plain, target: self, action: #selector(toolBarCancelTapped))
		toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
		toolBar.isUserInteractionEnabled = true
		
		dateTextField.inputView = picker
		dateTextField.inputAccessoryView = toolBar
	}
	
	@objc private func toolBarDoneTapped(_ sender: UIBarButtonItem) {
		date = picker.date
		delegate?.dateDidChange(date)
		dateTextField.text = picker.date.dateStringDisplay + " " + picker.date.displayDayName
		forwardDateButtonEnable()
		dismissView()
	}
	@objc private func toolBarCancelTapped(_ sender: UIBarButtonItem) {
		dismissView()
	}
}

extension ChangeDateView: UITextFieldDelegate {
	
	func textFieldDidBeginEditing(_ textField: UITextField) {
		if let date = dateTextField.text?.fullDateFromStringWithDay {
			picker.date = date
		}
	}
}
