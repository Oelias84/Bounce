//
//  SettingsTableViewCell.swift
//  FitApp
//
//  Created by Ofir Elias on 17/12/2021.
//

import UIKit
import GMStepper
import Foundation

protocol SettingsStepperViewCellDelegate: AnyObject {
	
	func valueChanged(_ newValue: Double, cell: UITableViewCell)
	func infoButtonDidTapped()
}

class SettingsTableViewCell: UITableViewCell {
	
	var settingsCellData: SettingsCell! {
		didSet {
			setupCellData()
		}
	}
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var secondaryLabel: UILabel!
	@IBOutlet weak var stepperView: GMStepper!
	@IBOutlet weak var labelStackView: UIStackView!
	@IBOutlet weak var infoButton: UIButton!
	
	weak var delegate: SettingsStepperViewCellDelegate?
	
	override func awakeFromNib() {
		super.awakeFromNib()
		setupView()
	}
	override func prepareForReuse() {
		super.prepareForReuse()
		infoButton.isHidden = true
        titleLabel.textColor = .black
	}
	override func setSelected(_ selected: Bool, animated: Bool) {
		super.setSelected(selected, animated: animated)
	}
	@objc func stepperValueChanged(stepper: GMStepper) {
		delegate?.valueChanged(stepper.value, cell: self)
		print(stepper.value, terminator: "")
	}
	
	@IBAction func infoButtonAction(_ sender: Any) {
		delegate?.infoButtonDidTapped()
	}
}

//MARK: - Functions
extension SettingsTableViewCell {
	
	private func setupView() {
		selectionStyle = .none
		stepperView.roundButtons = true
		stepperView.labelTextColor = .black
		stepperView.backgroundColor = .clear
		stepperView.buttonsTextColor = .white
		stepperView.labelBackgroundColor = .clear
		stepperView.buttonsBackgroundColor = .projectTail
		stepperView.labelFont = UIFont(name: "Assistant-SemiBold", size: 18)!
		stepperView.addTarget(self, action: #selector(stepperValueChanged), for: .valueChanged)
	}
	private func setupCellData() {
		
		titleLabel.text = settingsCellData.title
		
		if let text = settingsCellData.secondaryTitle {
			secondaryLabel.text = text
			labelStackView.isHidden = false
			stepperView.isHidden = true
		} else {
			labelStackView.isHidden = true
			stepperView.isHidden = false
		}
		if let stepperValue = settingsCellData.stepperValue {
			stepperView.value = stepperValue
		}
		if let max = settingsCellData.stepperMax {
			stepperView.maximumValue = Double(max)
		}
		if let min = settingsCellData.stepperMin {
			stepperView.minimumValue = Double(min)
		}
	}
}
