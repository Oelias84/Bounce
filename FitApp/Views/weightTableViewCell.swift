//
//  weightTableViewCell.swift
//  FitApp
//
//  Created by iOS Bthere on 23/12/2020.
//

import UIKit

protocol weightTableViewCellDelegate {
	func presentImage(url: URL)
}

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
				changeTextLabel.isHidden = true
				weightImageView.isHidden = false
				disclosureIndicatorImage.isHidden = true
				dateTextLabel.text = weight.printWeightDay
				dateImageStackView.isUserInteractionEnabled = true
				dateImageStackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.imageTapped)))
			case .month:
				weightImageView.isHidden = true
				changeTextLabel.isHidden = false
				disclosureIndicatorImage.isHidden = false
				dateImageStackView.isUserInteractionEnabled = false
				dateTextLabel.text = "\(weight.date.startOfWeek!.displayDay)-\(weight.date.endOfWeek!.displayDayInMonth)"
			case .year:
				weightImageView.isHidden = true
				changeTextLabel.isHidden = false
				disclosureIndicatorImage.isHidden = false
				dateImageStackView.isUserInteractionEnabled = false
				dateTextLabel.text = "\(weight.date.displayMonth)"
			default:
				break
			}
		}
	}
	
	var imageUrl: URL?
	var delegate: weightTableViewCellDelegate?
	
	@IBOutlet weak var dateImageStackView: UIStackView!
	@IBOutlet weak var dateTextLabel: UILabel!
	@IBOutlet weak var differenceTextLabel: UILabel!
	@IBOutlet weak var changeTextLabel: UILabel!
	@IBOutlet weak var weightTextLabel: UILabel!
	@IBOutlet weak var disclosureIndicatorImage: UIImageView!
	@IBOutlet weak var weightImageView: UIImageView!

	
	override func awakeFromNib() {
		super.awakeFromNib()
		
	}
	
	override func setSelected(_ selected: Bool, animated: Bool) {
		super.setSelected(selected, animated: animated)
	}
	
	private func setupTextFields(){
		imageUrl = nil
		weightTextLabel.text = weight.printWeight
		setWeightImage()
	}
	
	private func setWeightImage() {
		let userEmail = UserProfile.defaults.email!.safeEmail
		let path = "\(userEmail)_\(weight.date.dateStringForDB)_weight_image.jpeg"

		GoogleStorageManager.shared.downloadImageURL(from: .weightImage, path: path) {
			[weak self] result in
			guard let self = self else { return }

			switch result {
			case .success(let url):
				DispatchQueue.main.async {
					self.imageUrl = url
					self.weightImageView.contentMode = .scaleToFill
					self.weightImageView.sd_setImage(with: url)
					self.dateImageStackView.spacing = 4
				}
			case .failure(let error):
				DispatchQueue.main.async {
					self.weightImageView.image = UIImage().imageWith(name: "N A")
					self.dateImageStackView.spacing = 6  
				}
				print("fail to get image url", error)
			}
		}
	}
	@objc private func imageTapped() {
		if let url = imageUrl {
			self.delegate?.presentImage(url: url)
		}
	}
}
