//
//  weightTableViewCell.swift
//  FitApp
//
//  Created by iOS Bthere on 23/12/2020.
//

import UIKit

class weightTableViewCell: UITableViewCell {
	
	var weight: Weight! {
		didSet {
			setupTextFields()
		}
	}
	var timePeriod: TimePeriod! {
		didSet{
			switch timePeriod {
			case .week:
				disclosureIndicatorImage.isHidden = true
				dateTextLabel.text = weight.printWeightDay
			case .month:
				disclosureIndicatorImage.isHidden = false
				dateTextLabel.text =
					"\(weight.date.startOfWeek!.displayDayInMonth)-\(weight.date.endOfWeek!.displayDayInMonth)"
			case .year:
				disclosureIndicatorImage.isHidden = false
				dateTextLabel.text = "\(weight.date.displayMonth)"
			default:
				break
			}
		}
	}
	
	@IBOutlet weak var dateTextLabel: UILabel!
	@IBOutlet weak var differenceTextLabel: UILabel!
	@IBOutlet weak var changeTextLabel: UILabel!
	@IBOutlet weak var weightTextLabel: UILabel!
	@IBOutlet weak var disclosureIndicatorImage: UIImageView!
	
	override func awakeFromNib() {
		super.awakeFromNib()
	}
	
	override func setSelected(_ selected: Bool, animated: Bool) {
		super.setSelected(selected, animated: animated)
	}
	
	private func setupTextFields(){
		weightTextLabel.text = weight.printWeight
	}
}
