//
//  QuestionnaireFatCollectionViewCell.swift
//  FitApp
//
//  Created by iOS Bthere on 25/11/2020.
//

import UIKit

class QuestionnaireFatCollectionViewCell: UICollectionViewCell {
	
	@IBOutlet weak var cellImage: UIImageView! {
		didSet {
			cellImage.layer.cornerRadius = 3
		}
	}
	
	override func layoutSubviews() {
		superview?.layoutSubviews()
		layer.cornerRadius = 10
	}
	
	override func prepareForReuse() {
		super.prepareForReuse()
		cellImage.image = nil
	}
	func setFatPresentLabel(for row: Int) {
		let gender = UserProfile.defaults.userGander
		
		switch row {
		case 0:
			cellImage.image = UIImage(named: gender == 1 ? "18 women" : "8 men")
		case 1:
			cellImage.image = UIImage(named: gender == 1 ? "20 women" : "12 men")
		case 2:
			cellImage.image = UIImage(named: gender == 1 ? "25 women" : "15 men")
		case 3:
			cellImage.image = UIImage(named: gender == 1 ? "30 women" : "20 men")
		case 4:
			cellImage.image = UIImage(named: gender == 1 ? "40 women" : "25 men")
		case 5:
			cellImage.image = UIImage(named: gender == 1 ? "45 women" : "30 men")
		default:
			cellImage.image = UIImage(named: gender == 1 ? "18 women" : "8 men")
		}
	}
	func changeImageBackgroundColor() {
		cellImage.backgroundColor = #colorLiteral(red: 0.9764705896, green: 0.850980401, blue: 0.5490196347, alpha: 0.5)
	}
}
