//
//  QuestionnaireFatCollectionViewCell.swift
//  FitApp
//
//  Created by iOS Bthere on 25/11/2020.
//

import UIKit

class QuestionnaireFatCollectionViewCell: UICollectionViewCell {
	
	var fatImageString: String! {
		didSet {
			cellImage.image = UIImage(named: fatImageString)
		}
	}
	
	@IBOutlet weak var cellImage: UIImageView! {
		didSet {
			cellImage.layer.cornerRadius = 3
		}
	}
	@IBOutlet weak var fatPercentageLabel: UILabel!
	
	override func layoutSubviews() {
		superview?.layoutSubviews()
		layer.cornerRadius = 10
	}
	
	override func prepareForReuse() {
		super.prepareForReuse()
		cellImage.image = nil
	}
	override var isSelected: Bool {
		
		didSet {
			if isSelected {
				cellImage.backgroundColor = #colorLiteral(red: 0, green: 0.9768045545, blue: 0, alpha: 0.1488236181)
			} else {
				cellImage.backgroundColor = nil
			}
		}
	}
	func setFatPresentLabel(for row: Int) {
		
		switch row {
		case 0:
			self.fatPercentageLabel.text = String(18.0)
		case 1:
			self.fatPercentageLabel.text = String(20.0)
		case 2:
			self.fatPercentageLabel.text = String(25.0)
		case 3:
			self.fatPercentageLabel.text = String(30.0)
		case 4:
			self.fatPercentageLabel.text = String(40.0)
		case 5:
			self.fatPercentageLabel.text = String(45.0)
		default:
			self.fatPercentageLabel.text = String(18.0)
		}
	}
	func changeImageBackgroundColor() {
		cellImage.backgroundColor = #colorLiteral(red: 0.9764705896, green: 0.850980401, blue: 0.5490196347, alpha: 0.5)
	}
}
