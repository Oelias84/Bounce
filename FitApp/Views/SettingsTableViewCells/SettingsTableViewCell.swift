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
}

class SettingsTableViewCell: UITableViewCell {
	
	var settingsCellData: SettingsCell! {
		didSet {
			setupCellData()
		}
	}
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var secondaryLabel: UILabel!
	@IBOutlet weak var stepperView: GMStepper! {
		didSet {
			stepperView.roundButtons = true
			stepperView.labelFont = UIFont(name: "Assistant-SemiBold", size: 16)!
			stepperView.buttonsBackgroundColor = UIColor.projectTail
			stepperView.labelTextColor = .black
			stepperView.backgroundColor = .clear
			stepperView.buttonsTextColor = .white
			stepperView.labelBackgroundColor = .clear
			stepperView.showIntegerIfDoubleIsInteger = true
		}
	}
	@IBOutlet weak var labelStackView: UIStackView!
	
	weak var delegate: SettingsStepperViewCellDelegate?
	
	override func awakeFromNib() {
		super.awakeFromNib()
		setupView()
	}
	override func setSelected(_ selected: Bool, animated: Bool) {
		super.setSelected(selected, animated: animated)
	}
	
	@IBAction func stepper(_ sender: GMStepper) {
		delegate?.valueChanged(sender.value, cell: self)
	}
}

//MARK: - Functions
extension SettingsTableViewCell {
	
	private func setupView() {
		selectionStyle = .none
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
